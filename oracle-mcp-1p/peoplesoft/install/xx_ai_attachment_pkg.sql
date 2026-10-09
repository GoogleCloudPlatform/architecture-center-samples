-- =============================================================================
-- xx_ai_attachment_pkg (PeopleSoft): text and Base64 of stored attachments for MCP tools
-- =============================================================================
-- Run as SYSADM (PeopleSoft on Oracle Database 19c) through the site's normal process for
-- custom database code. See peoplesoft/install/README.md.
--
-- PeopleSoft stores an attachment as one or more parts (rows with the same ATTACHSYSFILENAME
-- and FILE_SEQ 0, 1, 2 ... of about 28,000 bytes each) in PS_HR_ATT_FILES or PSFILE_ATTDET.
-- This package joins the parts of the newest version into one file in the session, then offers:
--   * plain text of PDF, Word, Excel, PowerPoint, RTF, HTML and text files (Oracle Text AUTO_FILTER),
--   * the file itself as Base64 text, in fixed-size chunks, for files that only a client can read.
-- All functions are callable from SQL and read-only. Reuses the approach of ebs/install.
--
-- What it creates:
--   * Oracle Text preference XX_AI_ATTACH_TEXT_FILTER (AUTO_FILTER) and policy
--     XX_AI_ATTACH_TEXT_POLICY, owned by SYSADM. A policy is not an index: nothing is indexed.
--   * Package SYSADM.XX_AI_ATTACHMENT_PKG (definer's rights).
--   * EXECUTE on the package to the MCP Toolbox user (SYSADM_AI; change the GRANT if yours differs).
-- Prerequisites: SYSADM can use CTX_DDL and CTX_DOC (CTXAPP role or EXECUTE on both) and the
-- database home has the Oracle Text filter binaries ($ORACLE_HOME/ctx/bin/ctxhx).
-- Remove everything with xx_ai_attachment_pkg_uninstall.sql.
-- =============================================================================

WHENEVER SQLERROR EXIT FAILURE

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
    -- OK, NOT_FOUND (no stored file with that name), NO_CONTENT (stored but empty) or TOO_LARGE
    -- (over 50 MB). Describes the file itself; for text use get_text_status.
    FUNCTION get_status(p_name IN VARCHAR2) RETURN VARCHAR2;

    -- Size of the whole file in bytes (all parts of the newest version); 0 if none.
    FUNCTION get_bytes(p_name IN VARCHAR2) RETURN NUMBER;

    -- Base64 text of bytes (p_chunk - 1) * n + 1 .. p_chunk * n of the file, where n is
    -- p_chunk_bytes rounded down to a multiple of 3 (default 1500, at most 2800), so the chunks
    -- join into valid Base64 and every chunk fits a SQL VARCHAR2. Use the same n for every chunk
    -- of one file. NULL when the file is not OK or the chunk is past the end.
    FUNCTION get_base64_chunk(p_name IN VARCHAR2, p_chunk IN NUMBER, p_chunk_bytes IN NUMBER DEFAULT 1500) RETURN VARCHAR2;

    -- OK, NO_TEXT (filtered but empty, e.g. a scanned image), or ERROR: <Oracle Text message>
    -- (encrypted or unsupported file); NOT_FOUND, NO_CONTENT and TOO_LARGE as for get_status.
    FUNCTION get_text_status(p_name IN VARCHAR2) RETURN VARCHAR2;

    -- Number of characters of plain text; 0 when there is none.
    FUNCTION get_text_length(p_name IN VARCHAR2) RETURN NUMBER;

    -- Plain text from character (p_chunk - 1) * p_chunk_chars + 1, at most p_chunk_chars characters
    -- (default and maximum 1000, so the result fits a 4000-byte SQL VARCHAR2). NULL when no text.
    FUNCTION get_text_chunk(p_name IN VARCHAR2, p_chunk IN NUMBER, p_chunk_chars IN NUMBER DEFAULT 1000) RETURN VARCHAR2;
END xx_ai_attachment_pkg;
/

CREATE OR REPLACE PACKAGE BODY xx_ai_attachment_pkg AS
    c_policy     CONSTANT VARCHAR2(30) := 'XX_AI_ATTACH_TEXT_POLICY';
    c_max_bytes  CONSTANT NUMBER := 52428800;   -- 50 MB: larger files are not read
    c_max_chars  CONSTANT NUMBER := 1000;
    c_b64_max    CONSTANT NUMBER := 2800;       -- raw bytes per Base64 chunk: 2800 -> 3732 characters
    c_b64_def    CONSTANT NUMBER := 1500;

    -- The last file used is cached for the session, so paging through it (one call per chunk)
    -- reads it only once.
    g_name        VARCHAR2(200);
    g_status      VARCHAR2(30);
    g_blob        BLOB;
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

    -- Joins the parts (FILE_SEQ order) of the newest version, from PS_HR_ATT_FILES first, then PSFILE_ATTDET.
    PROCEDURE load_blob(p_name IN VARCHAR2) IS
        l_found BOOLEAN := FALSE;
    BEGIN
        IF g_name = p_name THEN
            RETURN;
        END IF;
        free_cache;
        g_name := p_name;
        g_status := 'NOT_FOUND';
        DBMS_LOB.CREATETEMPORARY(g_blob, TRUE, DBMS_LOB.SESSION);
        FOR r IN (SELECT file_data FROM ps_hr_att_files
                   WHERE attachsysfilename = p_name
                     AND version = (SELECT MAX(version) FROM ps_hr_att_files WHERE attachsysfilename = p_name)
                   ORDER BY file_seq) LOOP
            l_found := TRUE;
            IF r.file_data IS NOT NULL AND DBMS_LOB.GETLENGTH(r.file_data) > 0 THEN
                DBMS_LOB.APPEND(g_blob, r.file_data);
            END IF;
        END LOOP;
        IF NOT l_found THEN
            FOR r IN (SELECT file_data FROM psfile_attdet
                       WHERE attachsysfilename = p_name
                         AND version = (SELECT MAX(version) FROM psfile_attdet WHERE attachsysfilename = p_name)
                       ORDER BY file_seq) LOOP
                l_found := TRUE;
                IF r.file_data IS NOT NULL AND DBMS_LOB.GETLENGTH(r.file_data) > 0 THEN
                    DBMS_LOB.APPEND(g_blob, r.file_data);
                END IF;
            END LOOP;
        END IF;
        g_status := CASE
                        WHEN NOT l_found THEN 'NOT_FOUND'
                        WHEN DBMS_LOB.GETLENGTH(g_blob) = 0 THEN 'NO_CONTENT'
                        WHEN DBMS_LOB.GETLENGTH(g_blob) > c_max_bytes THEN 'TOO_LARGE'
                        ELSE 'OK'
                    END;
    END load_blob;

    PROCEDURE load_text(p_name IN VARCHAR2) IS
        PRAGMA AUTONOMOUS_TRANSACTION;   -- keeps any Oracle Text work out of the caller's query
    BEGIN
        load_blob(p_name);
        IF g_text_done THEN
            COMMIT;
            RETURN;
        END IF;
        g_text_done := TRUE;
        IF g_status <> 'OK' THEN
            g_text_status := g_status;
        ELSE
            BEGIN
                DBMS_LOB.CREATETEMPORARY(g_text, TRUE, DBMS_LOB.SESSION);
                ctx_doc.policy_filter(policy_name => c_policy,
                                      document    => g_blob,
                                      restab      => g_text,
                                      plaintext   => TRUE);
                -- Only whitespace (typical of a scanned, image-only PDF) counts as no text.
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
        END IF;
        COMMIT;
    END load_text;

    FUNCTION get_status(p_name IN VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
        IF p_name IS NULL THEN
            RETURN 'NOT_FOUND';
        END IF;
        load_blob(p_name);
        RETURN g_status;
    END get_status;

    FUNCTION get_bytes(p_name IN VARCHAR2) RETURN NUMBER IS
    BEGIN
        IF p_name IS NULL THEN
            RETURN 0;
        END IF;
        load_blob(p_name);
        RETURN CASE WHEN g_status IN ('OK', 'TOO_LARGE') THEN DBMS_LOB.GETLENGTH(g_blob) ELSE 0 END;
    END get_bytes;

    FUNCTION get_base64_chunk(p_name IN VARCHAR2, p_chunk IN NUMBER, p_chunk_bytes IN NUMBER DEFAULT 1500) RETURN VARCHAR2 IS
        l_size NUMBER := FLOOR(LEAST(GREATEST(NVL(p_chunk_bytes, c_b64_def), 3), c_b64_max) / 3) * 3;
        l_raw  RAW(2800);
    BEGIN
        IF p_name IS NULL OR NVL(p_chunk, 0) < 1 THEN
            RETURN NULL;
        END IF;
        load_blob(p_name);
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

    FUNCTION get_text_status(p_name IN VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
        IF p_name IS NULL THEN
            RETURN 'NOT_FOUND';
        END IF;
        load_text(p_name);
        RETURN g_text_status;
    END get_text_status;

    FUNCTION get_text_length(p_name IN VARCHAR2) RETURN NUMBER IS
    BEGIN
        IF p_name IS NULL THEN
            RETURN 0;
        END IF;
        load_text(p_name);
        RETURN CASE WHEN g_text_status = 'OK' THEN DBMS_LOB.GETLENGTH(g_text) ELSE 0 END;
    END get_text_length;

    FUNCTION get_text_chunk(p_name IN VARCHAR2, p_chunk IN NUMBER, p_chunk_chars IN NUMBER DEFAULT 1000) RETURN VARCHAR2 IS
        l_size NUMBER := LEAST(GREATEST(NVL(p_chunk_chars, c_max_chars), 1), c_max_chars);
    BEGIN
        IF p_name IS NULL OR NVL(p_chunk, 0) < 1 THEN
            RETURN NULL;
        END IF;
        load_text(p_name);
        IF g_text_status <> 'OK' THEN
            RETURN NULL;
        END IF;
        RETURN DBMS_LOB.SUBSTR(g_text, l_size, (p_chunk - 1) * l_size + 1);
    END get_text_chunk;
END xx_ai_attachment_pkg;
/

SHOW ERRORS PACKAGE BODY xx_ai_attachment_pkg

-- 3. Access for the MCP Toolbox user
GRANT EXECUTE ON xx_ai_attachment_pkg TO sysadm_ai;
