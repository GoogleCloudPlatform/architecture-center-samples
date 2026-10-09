-- Tool: jde_get_media_object_text
-- Skill: plain_language_notice_generator
-- Oracle Bind Variables:
--   :object_name (string): Media object name (F00165.GDOBNM) exactly as returned by jde_get_media_object_attachment, e.g. 'GT03B11'. Required.
--   :text_key (string): Media object text key (F00165.GDTXKY) exactly as returned by jde_get_media_object_attachment. Required.
--   :sequence (string): Media object sequence number (F00165.GDMOSEQN). Required.
--   :chunk (string): Which 1,000-character piece of the text to return, starting at 1. Empty = 1. Repeat with 2, 3 ... until has_more is N.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :object_name AS object_name,
        :text_key AS text_key,
        :sequence AS sequence,
        :chunk AS chunk
    FROM dual
),
info AS (
    SELECT
        p.object_name,
        p.text_key,
        TO_NUMBER(p.sequence) AS seq,
        GREATEST(NVL(TO_NUMBER(p.chunk), 1), 1) AS chunk_no,
        jde_ai.xx_ai_attachment_pkg.get_text_length(p.object_name, p.text_key, TO_NUMBER(p.sequence)) AS text_characters
    FROM params p
    WHERE p.object_name IS NOT NULL AND p.text_key IS NOT NULL AND p.sequence IS NOT NULL
)
SELECT
    UPPER(i.object_name) AS object_name,
    i.text_key,
    i.seq AS sequence,
    jde_ai.xx_ai_attachment_pkg.get_status(i.object_name, i.text_key, i.seq) AS media_object_status,
    jde_ai.xx_ai_attachment_pkg.get_encoding(i.object_name, i.text_key, i.seq) AS stored_encoding,
    jde_ai.xx_ai_attachment_pkg.get_bytes(i.object_name, i.text_key, i.seq) AS stored_bytes,
    jde_ai.xx_ai_attachment_pkg.get_text_status(i.object_name, i.text_key, i.seq) AS text_status,
    i.text_characters,
    CEIL(i.text_characters / 1000) AS chunk_count,
    i.chunk_no AS chunk,
    CASE WHEN i.chunk_no * 1000 < i.text_characters THEN 'Y' ELSE 'N' END AS has_more,
    jde_ai.xx_ai_attachment_pkg.get_text_chunk(i.object_name, i.text_key, i.seq, i.chunk_no, 1000) AS text_chunk
FROM info i;
