-- Tool: jde_get_media_object_base64
-- Skill: plain_language_notice_generator
-- Oracle Bind Variables:
--   :object_name (string): Media object name (F00165.GDOBNM) exactly as returned by jde_get_media_object_attachment. Required.
--   :text_key (string): Media object text key (F00165.GDTXKY) exactly as returned by jde_get_media_object_attachment. Required.
--   :sequence (string): Media object sequence number (F00165.GDMOSEQN). Required.
--   :chunk (string): Which piece of the stored bytes to return, starting at 1. Empty = 1. Repeat until has_more is N.
--   :chunk_bytes (string): Stored bytes per piece, rounded down to a multiple of 3 (default 1500, at most 2800). Use the same value for every call for one object.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :object_name AS object_name,
        :text_key AS text_key,
        :sequence AS sequence,
        :chunk AS chunk,
        :chunk_bytes AS chunk_bytes
    FROM dual
),
info AS (
    SELECT
        p.object_name,
        p.text_key,
        TO_NUMBER(p.sequence) AS seq,
        GREATEST(NVL(TO_NUMBER(p.chunk), 1), 1) AS chunk_no,
        FLOOR(LEAST(GREATEST(NVL(TO_NUMBER(p.chunk_bytes), 1500), 3), 2800) / 3) * 3 AS bytes_per_chunk,
        jde_ai.xx_ai_attachment_pkg.get_bytes(p.object_name, p.text_key, TO_NUMBER(p.sequence)) AS stored_bytes
    FROM params p
    WHERE p.object_name IS NOT NULL AND p.text_key IS NOT NULL AND p.sequence IS NOT NULL
)
SELECT
    UPPER(i.object_name) AS object_name,
    i.text_key,
    i.seq AS sequence,
    jde_ai.xx_ai_attachment_pkg.get_status(i.object_name, i.text_key, i.seq) AS media_object_status,
    jde_ai.xx_ai_attachment_pkg.get_encoding(i.object_name, i.text_key, i.seq) AS stored_encoding,
    i.stored_bytes,
    i.bytes_per_chunk AS chunk_bytes,
    CEIL(i.stored_bytes / i.bytes_per_chunk) AS chunk_count,
    i.chunk_no AS chunk,
    CASE WHEN i.chunk_no * i.bytes_per_chunk < i.stored_bytes THEN 'Y' ELSE 'N' END AS has_more,
    jde_ai.xx_ai_attachment_pkg.get_base64_chunk(i.object_name, i.text_key, i.seq, i.chunk_no, i.bytes_per_chunk) AS base64_chunk
FROM info i;
