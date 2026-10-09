-- =============================================================================
-- xx_ai_attachment_pkg (JD Edwards): text and Base64 of media objects for MCP tools
-- =============================================================================
-- Run as JDE_AI (JD Edwards EnterpriseOne on Oracle Database 19c) after jde_ai_grants.sql, through
-- the site's normal process for custom database code. See jde/install/README.md.
--
-- JDE media objects live in F00165 (key GDOBNM, GDTXKY, GDMOSEQN; content in the BLOB GDTXFT):
--   * text media objects (type 0, and some OLE-style type 3) hold their text as UTF-16, very often as
--     RTF. The package converts them to readable text.
--   * file, image and link media objects (types 1, 2, 5) keep only a file name or URL in F00165; the file
--     itself is on the JDE server's media object queue and is NOT in the database. For those the status
--     is NO_CONTENT.
-- Two kinds of answer, all callable from SQL and read-only:
--   * plain text (RTF and text decoded; any other file type that is stored in the BLOB, such as PDF or
--     Word, goes through Oracle Text AUTO_FILTER),
--   * the stored bytes as Base64 text, in fixed-size chunks.
-- Reuses the approach of ebs/install.
--
-- What it creates:
--   * Oracle Text preference XX_AI_ATTACH_TEXT_FILTER (AUTO_FILTER) and policy XX_AI_ATTACH_TEXT_POLICY,
--     owned by JDE_AI. A policy is not an index: nothing is indexed.
--   * Package JDE_AI.XX_AI_ATTACHMENT_PKG (definer's rights).
--   * EXECUTE on the package to the MCP Toolbox user (see jde_install_config.sql).
-- Prerequisites: jde_ai_grants.sql has been run, and the database home has the Oracle Text filter
-- binaries ($ORACLE_HOME/ctx/bin/ctxhx).
-- Remove everything with xx_ai_attachment_pkg_uninstall.sql.
-- =============================================================================

WHENEVER SQLERROR EXIT FAILURE
@@jde_install_config.sql

-- 1. Oracle Text filter preference and policy (skipped if they already exist)
DECLARE
    l_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO l_count FROM ctx_user_preferences WHERE pre_name = 'XX_AI_ATTACH_TEXT_FILTER';
    IF l_count = 0 THEN
        ctx_ddl.create_preference('XX_AI_ATTACH_TEXT_FILTER', 'AUTO_FILTER');
    END IF;
    SELECT COUNT(*) INTO l_count FROM ctx_user_indexes WHERE idx_name = 'XX_AI_ATTACH_TEXT_POLICY';
    IF l_count = 0 THEN
        ctx_ddl.create_policy(policy_name => 'XX_AI_ATTACH_TEXT_POLICY',
                              filter      => 'XX_AI_ATTACH_TEXT_FILTER');
    END IF;
END;
/

-- 2. Package
CREATE OR REPLACE PACKAGE xx_ai_attachment_pkg AUTHID DEFINER AS
    -- All functions identify one media object by F00165 key: object name (GDOBNM, for example GT03B11),
    -- text key (GDTXKY) and sequence (GDMOSEQN).

    -- OK, NOT_FOUND (no such media object), NO_CONTENT (no BLOB: a file or link kept outside the
    -- database) or TOO_LARGE (over 50 MB).
    FUNCTION get_status(p_object IN VARCHAR2, p_key IN VARCHAR2, p_seq IN NUMBER) RETURN VARCHAR2;

    -- Size of the stored BLOB in bytes; 0 if none.
    FUNCTION get_bytes(p_object IN VARCHAR2, p_key IN VARCHAR2, p_seq IN NUMBER) RETURN NUMBER;

    -- UTF-16LE when the BLOB is UTF-16 text, otherwise OTHER (a binary file, or NONE when there is no BLOB).
    FUNCTION get_encoding(p_object IN VARCHAR2, p_key IN VARCHAR2, p_seq IN NUMBER) RETURN VARCHAR2;

    -- Base64 text of the stored bytes (p_chunk - 1) * n + 1 .. p_chunk * n, where n is p_chunk_bytes rounded
    -- down to a multiple of 3 (default 1500, at most 2800). Use the same n for every chunk of one object.
    -- NULL when the status is not OK or the chunk is past the end.
    FUNCTION get_base64_chunk(p_object IN VARCHAR2, p_key IN VARCHAR2, p_seq IN NUMBER,
                              p_chunk IN NUMBER, p_chunk_bytes IN NUMBER DEFAULT 1500) RETURN VARCHAR2;

    -- OK, NO_TEXT (decoded but empty), or ERROR: <message> (unsupported or damaged file); the other
    -- values as for get_status.
    FUNCTION get_text_status(p_object IN VARCHAR2, p_key IN VARCHAR2, p_seq IN NUMBER) RETURN VARCHAR2;

    -- Number of characters of plain text; 0 when there is none.
    FUNCTION get_text_length(p_object IN VARCHAR2, p_key IN VARCHAR2, p_seq IN NUMBER) RETURN NUMBER;

    -- Plain text from character (p_chunk - 1) * p_chunk_chars + 1, at most p_chunk_chars characters
    -- (default and maximum 1000). NULL when no text.
    FUNCTION get_text_chunk(p_object IN VARCHAR2, p_key IN VARCHAR2, p_seq IN NUMBER,
                            p_chunk IN NUMBER, p_chunk_chars IN NUMBER DEFAULT 1000) RETURN VARCHAR2;
END xx_ai_attachment_pkg;
/

CREATE OR REPLACE PACKAGE BODY xx_ai_attachment_pkg AS
    c_policy    CONSTANT VARCHAR2(30) := 'XX_AI_ATTACH_TEXT_POLICY';
    c_max_bytes CONSTANT NUMBER := 52428800;   -- 50 MB: larger objects are not read
    c_max_chars CONSTANT NUMBER := 1000;
    c_b64_max   CONSTANT NUMBER := 2800;       -- raw bytes per Base64 chunk: 2800 -> 3732 characters
    c_b64_def   CONSTANT NUMBER := 1500;
    c_utf16_chunk CONSTANT NUMBER := 16000;    -- bytes converted at a time (even)

    -- The last media object used is cached for the session, so paging through it reads it only once.
    g_cache_key   VARCHAR2(600);
    g_status      VARCHAR2(30);
    g_blob        BLOB;            -- the BLOB as stored
    g_encoding    VARCHAR2(10);
    g_text_done   BOOLEAN := FALSE;
    g_text_status VARCHAR2(4000);
    g_text        CLOB;

    PROCEDURE free_cache IS
    BEGIN
        IF g_blob IS NOT NULL AND DBMS_LOB.ISTEMPORARY(g_blob) = 1 THEN
            DBMS_LOB.FREETEMPORARY(g_blob);
        END IF;
        IF g_text IS NOT NULL AND DBMS_LOB.ISTEMPORARY(g_text) = 1 THEN
            DBMS_LOB.FREETEMPORARY(g_text);
        END IF;
        g_blob := NULL;
        g_text := NULL;
        g_text_done := FALSE;
        g_text_status := NULL;
    END free_cache;

    PROCEDURE load_blob(p_object IN VARCHAR2, p_key IN VARCHAR2, p_seq IN NUMBER) IS
        l_key  VARCHAR2(600) := UPPER(TRIM(p_object)) || '|' || p_key || '|' || p_seq;
        l_data BLOB;
        l_head VARCHAR2(8);
    BEGIN
        IF g_cache_key = l_key THEN
            RETURN;
        END IF;
        free_cache;
        g_cache_key := l_key;
        g_encoding := 'NONE';
        BEGIN
            SELECT gdtxft INTO l_data
              FROM &&jde_data_schema..f00165
             WHERE TRIM(gdobnm) = UPPER(TRIM(p_object)) AND TRIM(gdtxky) = TRIM(p_key) AND gdmoseqn = p_seq;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                g_status := 'NOT_FOUND';
                RETURN;
            WHEN TOO_MANY_ROWS THEN
                g_status := 'NOT_FOUND';   -- the key is not unique after trimming; refuse rather than guess
                RETURN;
        END;
        IF l_data IS NULL OR DBMS_LOB.GETLENGTH(l_data) = 0 THEN
            g_status := 'NO_CONTENT';
        ELSIF DBMS_LOB.GETLENGTH(l_data) > c_max_bytes THEN
            g_status := 'TOO_LARGE';
        ELSE
            g_status := 'OK';
            g_blob := l_data;
            -- UTF-16LE text: a byte order mark, or a printable first character with 00 as the second byte
            -- of each of the first two characters.
            l_head := RAWTOHEX(DBMS_LOB.SUBSTR(l_data, 4, 1));
            g_encoding := CASE
                              WHEN l_head LIKE 'FFFE%' THEN 'UTF-16LE'
                              WHEN LENGTH(l_head) = 8 AND SUBSTR(l_head, 3, 2) = '00' AND SUBSTR(l_head, 7, 2) = '00'
                                   AND SUBSTR(l_head, 1, 2) <> '00' THEN 'UTF-16LE'
                              WHEN l_head = '0000' THEN 'UTF-16LE'   -- an empty text object
                              ELSE 'OTHER'
                          END;
        END IF;
    END load_blob;

    PROCEDURE load_text(p_object IN VARCHAR2, p_key IN VARCHAR2, p_seq IN NUMBER) IS
        PRAGMA AUTONOMOUS_TRANSACTION;   -- keeps any Oracle Text work out of the caller's query
        l_utf8   BLOB;
        l_pos    NUMBER;
        l_len    NUMBER;
        l_amount NUMBER;
        l_conv   RAW(32767);
        l_dest   INTEGER := 1;
        l_src    INTEGER := 1;
        l_ctx    INTEGER := DBMS_LOB.DEFAULT_LANG_CTX;
        l_warn   INTEGER;
        l_rtf    BOOLEAN;
    BEGIN
        load_blob(p_object, p_key, p_seq);
        IF g_text_done THEN
            COMMIT;
            RETURN;
        END IF;
        g_text_done := TRUE;
        IF g_status <> 'OK' THEN
            g_text_status := g_status;
            COMMIT;
            RETURN;
        END IF;
        BEGIN
            DBMS_LOB.CREATETEMPORARY(g_text, TRUE, DBMS_LOB.SESSION);
            IF g_encoding = 'UTF-16LE' THEN
                -- Convert to UTF-8 in pieces, then take it as text; RTF goes through Oracle Text.
                DBMS_LOB.CREATETEMPORARY(l_utf8, TRUE, DBMS_LOB.SESSION);
                l_len := DBMS_LOB.GETLENGTH(g_blob);
                l_pos := CASE WHEN RAWTOHEX(DBMS_LOB.SUBSTR(g_blob, 2, 1)) = 'FFFE' THEN 3 ELSE 1 END;
                WHILE l_pos < l_len LOOP
                    l_amount := LEAST(c_utf16_chunk, l_len - l_pos + 1);
                    l_amount := l_amount - MOD(l_amount, 2);   -- whole UTF-16 code units only
                    EXIT WHEN l_amount < 2;
                    l_conv := UTL_RAW.CONVERT(DBMS_LOB.SUBSTR(g_blob, l_amount, l_pos),
                                              'AL32UTF8', 'AL16UTF16LE');
                    DBMS_LOB.WRITEAPPEND(l_utf8, UTL_RAW.LENGTH(l_conv), l_conv);
                    l_pos := l_pos + l_amount;
                END LOOP;
                l_rtf := UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(l_utf8, 8, 1)) LIKE '{\rtf%';
                IF l_rtf THEN
                    ctx_doc.policy_filter(policy_name => c_policy, document => l_utf8,
                                          restab => g_text, plaintext => TRUE);
                ELSIF DBMS_LOB.GETLENGTH(l_utf8) > 0 THEN
                    DBMS_LOB.CONVERTTOCLOB(g_text, l_utf8, DBMS_LOB.LOBMAXSIZE, l_dest, l_src,
                                           NLS_CHARSET_ID('AL32UTF8'), l_ctx, l_warn);
                END IF;
                DBMS_LOB.FREETEMPORARY(l_utf8);
            ELSE
                ctx_doc.policy_filter(policy_name => c_policy, document => g_blob,
                                      restab => g_text, plaintext => TRUE);
            END IF;
            -- Only whitespace (typical of a scanned, image-only file) counts as no text.
            g_text_status := CASE
                                 WHEN NVL(DBMS_LOB.GETLENGTH(g_text), 0) = 0 THEN 'NO_TEXT'
                                 WHEN DBMS_LOB.GETLENGTH(g_text) <= 32000
                                      AND NOT REGEXP_LIKE(DBMS_LOB.SUBSTR(g_text, 32000, 1), '[^[:space:][:cntrl:]]') THEN 'NO_TEXT'
                                 ELSE 'OK'
                             END;
        EXCEPTION
            WHEN OTHERS THEN
                g_text_status := 'ERROR: ' || SUBSTR(REPLACE(SQLERRM, CHR(10), ' '), 1, 3900);
        END;
        COMMIT;
    END load_text;

    FUNCTION get_status(p_object IN VARCHAR2, p_key IN VARCHAR2, p_seq IN NUMBER) RETURN VARCHAR2 IS
    BEGIN
        IF p_object IS NULL OR p_key IS NULL OR p_seq IS NULL THEN
            RETURN 'NOT_FOUND';
        END IF;
        load_blob(p_object, p_key, p_seq);
        RETURN g_status;
    END get_status;

    FUNCTION get_bytes(p_object IN VARCHAR2, p_key IN VARCHAR2, p_seq IN NUMBER) RETURN NUMBER IS
    BEGIN
        IF p_object IS NULL OR p_key IS NULL OR p_seq IS NULL THEN
            RETURN 0;
        END IF;
        load_blob(p_object, p_key, p_seq);
        RETURN CASE WHEN g_status = 'OK' THEN DBMS_LOB.GETLENGTH(g_blob) ELSE 0 END;
    END get_bytes;

    FUNCTION get_encoding(p_object IN VARCHAR2, p_key IN VARCHAR2, p_seq IN NUMBER) RETURN VARCHAR2 IS
    BEGIN
        IF p_object IS NULL OR p_key IS NULL OR p_seq IS NULL THEN
            RETURN 'NONE';
        END IF;
        load_blob(p_object, p_key, p_seq);
        RETURN g_encoding;
    END get_encoding;

    FUNCTION get_base64_chunk(p_object IN VARCHAR2, p_key IN VARCHAR2, p_seq IN NUMBER,
                              p_chunk IN NUMBER, p_chunk_bytes IN NUMBER DEFAULT 1500) RETURN VARCHAR2 IS
        l_size NUMBER := FLOOR(LEAST(GREATEST(NVL(p_chunk_bytes, c_b64_def), 3), c_b64_max) / 3) * 3;
        l_raw  RAW(2800);
    BEGIN
        IF p_object IS NULL OR p_key IS NULL OR p_seq IS NULL OR NVL(p_chunk, 0) < 1 THEN
            RETURN NULL;
        END IF;
        load_blob(p_object, p_key, p_seq);
        IF g_status <> 'OK' THEN
            RETURN NULL;
        END IF;
        l_raw := DBMS_LOB.SUBSTR(g_blob, l_size, (p_chunk - 1) * l_size + 1);
        IF l_raw IS NULL THEN
            RETURN NULL;
        END IF;
        -- BASE64_ENCODE adds a line break every 64 characters; remove them.
        RETURN REPLACE(REPLACE(UTL_RAW.CAST_TO_VARCHAR2(UTL_ENCODE.BASE64_ENCODE(l_raw)), CHR(13)), CHR(10));
    END get_base64_chunk;

    FUNCTION get_text_status(p_object IN VARCHAR2, p_key IN VARCHAR2, p_seq IN NUMBER) RETURN VARCHAR2 IS
    BEGIN
        IF p_object IS NULL OR p_key IS NULL OR p_seq IS NULL THEN
            RETURN 'NOT_FOUND';
        END IF;
        load_text(p_object, p_key, p_seq);
        RETURN g_text_status;
    END get_text_status;

    FUNCTION get_text_length(p_object IN VARCHAR2, p_key IN VARCHAR2, p_seq IN NUMBER) RETURN NUMBER IS
    BEGIN
        IF p_object IS NULL OR p_key IS NULL OR p_seq IS NULL THEN
            RETURN 0;
        END IF;
        load_text(p_object, p_key, p_seq);
        RETURN CASE WHEN g_text_status = 'OK' THEN DBMS_LOB.GETLENGTH(g_text) ELSE 0 END;
    END get_text_length;

    FUNCTION get_text_chunk(p_object IN VARCHAR2, p_key IN VARCHAR2, p_seq IN NUMBER,
                            p_chunk IN NUMBER, p_chunk_chars IN NUMBER DEFAULT 1000) RETURN VARCHAR2 IS
        l_size NUMBER := LEAST(GREATEST(NVL(p_chunk_chars, c_max_chars), 1), c_max_chars);
    BEGIN
        IF p_object IS NULL OR p_key IS NULL OR p_seq IS NULL OR NVL(p_chunk, 0) < 1 THEN
            RETURN NULL;
        END IF;
        load_text(p_object, p_key, p_seq);
        IF g_text_status <> 'OK' THEN
            RETURN NULL;
        END IF;
        RETURN DBMS_LOB.SUBSTR(g_text, l_size, (p_chunk - 1) * l_size + 1);
    END get_text_chunk;
END xx_ai_attachment_pkg;
/

SHOW ERRORS PACKAGE BODY xx_ai_attachment_pkg

-- 3. Access for the MCP Toolbox user
GRANT EXECUTE ON xx_ai_attachment_pkg TO &&jde_toolbox_user;
