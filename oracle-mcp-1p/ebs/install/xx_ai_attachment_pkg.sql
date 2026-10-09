-- =============================================================================
-- xx_ai_attachment_pkg (EBS): text and Base64 of stored attachments for MCP tools
-- =============================================================================
-- Run as APPS in SQL*Plus or SQLcl (EBS R12.2 on Oracle Database 19c), through the
-- site's normal process for custom code (on R12.2, an adop hotpatch or patch cycle,
-- because APPS code objects are editioned). See ebs/install/README.md.
--
-- What it creates (all read-only at run time):
--   * Oracle Text preference XX_AI_ATTACH_TEXT_FILTER (AUTO_FILTER) and policy
--     XX_AI_ATTACH_TEXT_POLICY, owned by APPS. A policy is not an index: nothing is
--     indexed, synchronized or stored.
--   * Package APPS.XX_AI_ATTACHMENT_PKG (definer's rights) with six functions callable from
--     SQL, for one FND_LOBS file: its status and size, its bytes as Base64 text in fixed-size
--     chunks (for files only a client can read), and plain text of PDF, Word, Excel,
--     PowerPoint, RTF and the other formats Oracle Text's AUTO_FILTER supports. The same six
--     functions exist in the PeopleSoft and JD Edwards packages (only the key columns differ).
--   * EXECUTE on the package to the MCP Toolbox database user (APPS_AI by default;
--     change the GRANT at the end if yours differs).
--
-- Prerequisites: APPS can use CTX_DDL and CTX_DOC (the CTXAPP role or EXECUTE on both;
-- EBS grants this for its own text indexes), and the database home has the Oracle Text
-- filter binaries ($ORACLE_HOME/ctx/bin/ctxhx), which a standard 19c home includes.
-- Remove everything with ebs/install/xx_ai_attachment_pkg_uninstall.sql. This package replaces
-- XX_AI_ATTACHMENT_TEXT_PKG: see the migration steps in ebs/install/README.md.
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
    -- OK, NOT_FOUND (no FND_LOBS row with that id), NO_CONTENT (row without data) or TOO_LARGE
    -- (over 50 MB). Describes the file itself; for text use get_text_status.
    FUNCTION get_status(p_file_id IN NUMBER) RETURN VARCHAR2;

    -- Size of the file in bytes; 0 if none.
    FUNCTION get_bytes(p_file_id IN NUMBER) RETURN NUMBER;

    -- Base64 text of bytes (p_chunk - 1) * n + 1 .. p_chunk * n of the file, where n is
    -- p_chunk_bytes rounded down to a multiple of 3 (default 1500, at most 2800), so the chunks
    -- join into valid Base64 and every chunk fits a SQL VARCHAR2. Use the same n for every chunk
    -- of one file. NULL when the file is not OK or the chunk is past the end.
    FUNCTION get_base64_chunk(p_file_id IN NUMBER, p_chunk IN NUMBER, p_chunk_bytes IN NUMBER DEFAULT 1500) RETURN VARCHAR2;

    -- OK, NO_TEXT (filtered but empty, e.g. a scanned image), or ERROR: <Oracle Text message>
    -- (e.g. encrypted or unsupported file); NOT_FOUND, NO_CONTENT and TOO_LARGE as for get_status.
    FUNCTION get_text_status(p_file_id IN NUMBER) RETURN VARCHAR2;

    -- Number of characters of plain text; 0 when there is none.
    FUNCTION get_text_length(p_file_id IN NUMBER) RETURN NUMBER;

    -- Plain text of FND_LOBS file p_file_id, from character (p_chunk - 1) * p_chunk_chars + 1,
    -- at most p_chunk_chars characters (default and maximum 1000, so the result always fits a
    -- 4000-byte SQL VARCHAR2). NULL when the text status is not OK or the chunk is past the end.
    FUNCTION get_text_chunk(p_file_id IN NUMBER, p_chunk IN NUMBER, p_chunk_chars IN NUMBER DEFAULT 1000) RETURN VARCHAR2;
END xx_ai_attachment_pkg;
/

CREATE OR REPLACE PACKAGE BODY xx_ai_attachment_pkg AS
    c_policy    CONSTANT VARCHAR2(30) := 'XX_AI_ATTACH_TEXT_POLICY';
    c_max_bytes CONSTANT NUMBER := 52428800;   -- 50 MB: larger files are not filtered
    c_max_chunk CONSTANT NUMBER := 1000;
    c_b64_def   CONSTANT NUMBER := 1500;   -- default Base64 chunk: bytes of file per call
    c_b64_max   CONSTANT NUMBER := 2800;   -- 2800 bytes = 3736 Base64 characters: fits a 4000-byte VARCHAR2

    -- The last filtered file is cached for the session, so paging through a document
    -- (one call per chunk) filters it only once.
    g_file_id NUMBER;
    g_status  VARCHAR2(4000);
    g_text    CLOB;

    PROCEDURE load(p_file_id IN NUMBER) IS
        PRAGMA AUTONOMOUS_TRANSACTION;   -- keeps any Oracle Text work out of the caller's query
        l_data BLOB;
    BEGIN
        IF g_file_id = p_file_id THEN
            RETURN;
        END IF;
        IF g_text IS NOT NULL AND DBMS_LOB.ISTEMPORARY(g_text) = 1 THEN
            DBMS_LOB.FREETEMPORARY(g_text);
        END IF;
        g_text := NULL;
        g_file_id := p_file_id;

        BEGIN
            SELECT file_data INTO l_data FROM fnd_lobs WHERE file_id = p_file_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                g_status := 'NOT_FOUND';
                COMMIT;
                RETURN;
        END;

        IF l_data IS NULL THEN
            g_status := 'NO_CONTENT';
        ELSIF DBMS_LOB.GETLENGTH(l_data) > c_max_bytes THEN
            g_status := 'TOO_LARGE';
        ELSE
            BEGIN
                DBMS_LOB.CREATETEMPORARY(g_text, TRUE, DBMS_LOB.SESSION);
                ctx_doc.policy_filter(policy_name => c_policy,
                                      document    => l_data,
                                      restab      => g_text,
                                      plaintext   => TRUE);
                -- Only whitespace (typical of a scanned, image-only PDF) counts as no text.
                g_status := CASE
                                WHEN NVL(DBMS_LOB.GETLENGTH(g_text), 0) = 0 THEN 'NO_TEXT'
                                WHEN DBMS_LOB.GETLENGTH(g_text) <= 32000
                                     AND NOT REGEXP_LIKE(DBMS_LOB.SUBSTR(g_text, 32000, 1), '[^[:space:]]') THEN 'NO_TEXT'
                                ELSE 'OK'
                            END;
            EXCEPTION
                WHEN OTHERS THEN
                    g_status := 'ERROR: ' || SUBSTR(REPLACE(SQLERRM, CHR(10), ' '), 1, 3900);
            END;
        END IF;
        COMMIT;
    END load;

    FUNCTION get_text_chunk(p_file_id IN NUMBER, p_chunk IN NUMBER, p_chunk_chars IN NUMBER DEFAULT 1000) RETURN VARCHAR2 IS
        l_size NUMBER := LEAST(GREATEST(NVL(p_chunk_chars, c_max_chunk), 1), c_max_chunk);
    BEGIN
        IF p_file_id IS NULL OR NVL(p_chunk, 0) < 1 THEN
            RETURN NULL;
        END IF;
        load(p_file_id);
        IF g_status <> 'OK' THEN
            RETURN NULL;
        END IF;
        RETURN DBMS_LOB.SUBSTR(g_text, l_size, (p_chunk - 1) * l_size + 1);
    END get_text_chunk;

    FUNCTION get_text_length(p_file_id IN NUMBER) RETURN NUMBER IS
    BEGIN
        IF p_file_id IS NULL THEN
            RETURN 0;
        END IF;
        load(p_file_id);
        RETURN CASE WHEN g_status = 'OK' THEN DBMS_LOB.GETLENGTH(g_text) ELSE 0 END;
    END get_text_length;

    FUNCTION get_status(p_file_id IN NUMBER) RETURN VARCHAR2 IS
        l_len NUMBER;
    BEGIN
        IF p_file_id IS NULL THEN
            RETURN 'NOT_FOUND';
        END IF;
        BEGIN
            SELECT NVL(DBMS_LOB.GETLENGTH(file_data), 0) INTO l_len FROM fnd_lobs WHERE file_id = p_file_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RETURN 'NOT_FOUND';
        END;
        RETURN CASE WHEN l_len = 0 THEN 'NO_CONTENT' WHEN l_len > c_max_bytes THEN 'TOO_LARGE' ELSE 'OK' END;
    END get_status;

    FUNCTION get_bytes(p_file_id IN NUMBER) RETURN NUMBER IS
        l_len NUMBER;
    BEGIN
        IF p_file_id IS NULL THEN
            RETURN 0;
        END IF;
        BEGIN
            SELECT NVL(DBMS_LOB.GETLENGTH(file_data), 0) INTO l_len FROM fnd_lobs WHERE file_id = p_file_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RETURN 0;
        END;
        RETURN l_len;
    END get_bytes;

    FUNCTION get_base64_chunk(p_file_id IN NUMBER, p_chunk IN NUMBER, p_chunk_bytes IN NUMBER DEFAULT 1500) RETURN VARCHAR2 IS
        l_size NUMBER := FLOOR(LEAST(GREATEST(NVL(p_chunk_bytes, c_b64_def), 3), c_b64_max) / 3) * 3;
        l_raw  RAW(2800);
    BEGIN
        IF p_file_id IS NULL OR NVL(p_chunk, 0) < 1 OR get_status(p_file_id) <> 'OK' THEN
            RETURN NULL;
        END IF;
        SELECT DBMS_LOB.SUBSTR(file_data, l_size, (p_chunk - 1) * l_size + 1) INTO l_raw
          FROM fnd_lobs WHERE file_id = p_file_id;
        IF l_raw IS NULL THEN
            RETURN NULL;
        END IF;
        -- BASE64_ENCODE adds a line break every 64 characters; remove them.
        RETURN REPLACE(REPLACE(UTL_RAW.CAST_TO_VARCHAR2(UTL_ENCODE.BASE64_ENCODE(l_raw)), CHR(13)), CHR(10));
    END get_base64_chunk;

    FUNCTION get_text_status(p_file_id IN NUMBER) RETURN VARCHAR2 IS
    BEGIN
        IF p_file_id IS NULL THEN
            RETURN 'NOT_FOUND';
        END IF;
        load(p_file_id);
        RETURN g_status;
    END get_text_status;
END xx_ai_attachment_pkg;
/

SHOW ERRORS PACKAGE BODY xx_ai_attachment_pkg

-- 3. Access for the MCP Toolbox user
GRANT EXECUTE ON xx_ai_attachment_pkg TO apps_ai;
