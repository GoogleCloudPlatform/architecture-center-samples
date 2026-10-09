-- Tool: jde_search_policy_documents
-- Skill: policy_and_statute_assistant
-- Oracle Bind Variables:
--   :keyword (string): Search keyword or policy title (matched against attachment name, file name and document description).
--   :object_name (string): Optional media object name the agency uses for policy documents (F00165.GDOBNM). Use jde_list_media_object_types to discover it.
--   :document_type (string): Optional media object document type (F00166.GTMODOCTP), e.g. 'POLICY' or 'SOP' as configured by the agency.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :keyword AS keyword,
        :object_name AS object_name,
        :document_type AS document_type
    FROM dual
)
SELECT
    TRIM(mo.gdobnm) AS object_name,
    mo.gdtxky AS text_key,
    mo.gdmoseqn AS sequence,
    CASE WHEN mo.gdgtmotype = 0 THEN 'TEXT' ELSE 'FILE_OR_LINK' END AS content_kind,
    TRIM(mo.gdgtitnm) AS policy_title,
    TRIM(mo.gdgtfilenm) AS file_name_or_url,
    TRIM(cat.gtmodoctp) AS document_type,
    TRIM(cat.gtmodl01) AS policy_summary,
    TRIM(cat.gtmoauthor) AS author,
    TRIM(cat.gtmostatus) AS policy_status,
    CASE WHEN cat.gtmoefdtfr > 0 THEN TO_CHAR(TO_DATE(TO_CHAR(cat.gtmoefdtfr + 1900000), 'YYYYDDD'), 'YYYY-MM-DD') END AS effective_from,
    CASE WHEN cat.gtmoefdtto > 0 THEN TO_CHAR(TO_DATE(TO_CHAR(cat.gtmoefdtto + 1900000), 'YYYYDDD'), 'YYYY-MM-DD') END AS effective_to,
    CASE WHEN cat.gtmorevdt > 0 THEN TO_CHAR(TO_DATE(TO_CHAR(cat.gtmorevdt + 1900000), 'YYYYDDD'), 'YYYY-MM-DD') END AS next_review_date,
    CASE WHEN mo.gdupmj > 0 THEN TO_CHAR(TO_DATE(TO_CHAR(mo.gdupmj + 1900000), 'YYYYDDD'), 'YYYY-MM-DD') END AS updated_date
FROM params p
JOIN proddta.f00165 mo
    ON (p.object_name IS NULL OR mo.gdobnm = RPAD(UPPER(p.object_name), 10))
LEFT JOIN proddta.f00166 cat
    ON cat.gtobnm = mo.gdobnm
   AND cat.gttxky = mo.gdtxky
   AND cat.gtmoseqn = mo.gdmoseqn
WHERE (p.document_type IS NULL OR TRIM(cat.gtmodoctp) = UPPER(p.document_type))
  AND (p.keyword IS NULL
    OR UPPER(mo.gdgtitnm) LIKE UPPER('%' || p.keyword || '%')
    OR UPPER(mo.gdgtfilenm) LIKE UPPER('%' || p.keyword || '%')
    OR UPPER(cat.gtmodl01) LIKE UPPER('%' || p.keyword || '%'))
ORDER BY mo.gdupmj DESC
FETCH FIRST 20 ROWS ONLY;
