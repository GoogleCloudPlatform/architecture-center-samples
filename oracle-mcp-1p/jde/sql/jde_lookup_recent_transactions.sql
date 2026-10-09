-- Tool: jde_lookup_recent_transactions
-- Skill: schema_discovery_and_lovs
-- Oracle Bind Variables:
--   :doc_type (string): Document type filter: 'PO', 'QUOTE', 'VOUCHER', 'INVOICE' or 'EXPENSE'.
--   :doc_number (string): Optional partial document or report number; without it only the last 365 days are searched.
--   :company (string): Optional JDE company (e.g. '00001').
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :doc_type AS doc_type,
        TO_CHAR(:doc_number) AS doc_number,
        TO_CHAR(:company) AS company
    FROM dual
)
SELECT * FROM (
    SELECT
        CASE WHEN ph.phdcto = 'OQ' THEN 'QUOTE' ELSE 'PO' END AS doc_type,
        TO_CHAR(ph.phdoco) AS doc_number,
        TO_CHAR(ph.phdcto) AS jde_doc_type,
        TO_CHAR(ph.phkcoo) AS company,
        CASE WHEN ph.phtrdj > 0 THEN TO_CHAR(TO_DATE(TO_CHAR(ph.phtrdj + 1900000), 'YYYYDDD'), 'YYYY-MM-DD') END AS doc_date,
        TO_CHAR(TRIM(ph.phdesc)) AS doc_description,
        ph.photot / 100 AS total_amount,
        ph.phan8 AS party_an8
    FROM proddta.f4301 ph
    CROSS JOIN params p
    WHERE ((UPPER(p.doc_type) = 'PO' AND ph.phdcto <> 'OQ') OR (UPPER(p.doc_type) = 'QUOTE' AND ph.phdcto = 'OQ'))
      AND (p.company IS NULL OR ph.phkcoo = LPAD(p.company, 5, '0'))
      AND (p.doc_number IS NULL OR TO_CHAR(ph.phdoco) LIKE '%' || p.doc_number || '%')
      AND (p.doc_number IS NOT NULL OR ph.phtrdj >= TO_NUMBER(TO_CHAR(SYSDATE - 365, 'YYYYDDD')) - 1900000)
    UNION ALL
    SELECT
        'VOUCHER' AS doc_type,
        TO_CHAR(ap.rpdoc) AS doc_number,
        TO_CHAR(ap.rpdct) AS jde_doc_type,
        TO_CHAR(ap.rpkco) AS company,
        CASE WHEN ap.rpdivj > 0 THEN TO_CHAR(TO_DATE(TO_CHAR(ap.rpdivj + 1900000), 'YYYYDDD'), 'YYYY-MM-DD') END AS doc_date,
        TO_CHAR('Invoice ' || TRIM(ap.rpvinv)) AS doc_description,
        ap.rpag / 100 AS total_amount,
        ap.rpan8 AS party_an8
    FROM proddta.f0411 ap
    CROSS JOIN params p
    WHERE UPPER(p.doc_type) = 'VOUCHER'
      AND ap.rpsfx = '001'
      AND (p.company IS NULL OR ap.rpkco = LPAD(p.company, 5, '0'))
      AND (p.doc_number IS NULL OR TO_CHAR(ap.rpdoc) LIKE '%' || p.doc_number || '%' OR UPPER(ap.rpvinv) LIKE UPPER('%' || p.doc_number || '%'))
      AND (p.doc_number IS NOT NULL OR ap.rpdivj >= TO_NUMBER(TO_CHAR(SYSDATE - 365, 'YYYYDDD')) - 1900000)
    UNION ALL
    SELECT
        'INVOICE' AS doc_type,
        TO_CHAR(ar.rpdoc) AS doc_number,
        TO_CHAR(ar.rpdct) AS jde_doc_type,
        TO_CHAR(ar.rpkco) AS company,
        CASE WHEN ar.rpdivj > 0 THEN TO_CHAR(TO_DATE(TO_CHAR(ar.rpdivj + 1900000), 'YYYYDDD'), 'YYYY-MM-DD') END AS doc_date,
        TO_CHAR(TRIM(ar.rprmk)) AS doc_description,
        ar.rpag / 100 AS total_amount,
        ar.rpan8 AS party_an8
    FROM proddta.f03b11 ar
    CROSS JOIN params p
    WHERE UPPER(p.doc_type) = 'INVOICE'
      AND ar.rpsfx = '001'
      AND (p.company IS NULL OR ar.rpkco = LPAD(p.company, 5, '0'))
      AND (p.doc_number IS NULL OR TO_CHAR(ar.rpdoc) LIKE '%' || p.doc_number || '%')
      AND (p.doc_number IS NOT NULL OR ar.rpdivj >= TO_NUMBER(TO_CHAR(SYSDATE - 365, 'YYYYDDD')) - 1900000)
    UNION ALL
    SELECT
        'EXPENSE' AS doc_type,
        TO_CHAR(TRIM(eh.ehexrptnum)) AS doc_number,
        TO_CHAR(eh.ehexrpttyp) AS jde_doc_type,
        TO_CHAR(TRIM(eh.ehco)) AS company,
        CASE WHEN eh.ehdatesub > 0 THEN TO_CHAR(TO_DATE(TO_CHAR(eh.ehdatesub + 1900000), 'YYYYDDD'), 'YYYY-MM-DD') END AS doc_date,
        TO_CHAR(TRIM(eh.ehexrptdes) || ' [' || TRIM(eh.ehexrptsta) || ']') AS doc_description,
        eh.ehtotexp / 100 AS total_amount,
        eh.ehemployid AS party_an8
    FROM proddta.f20111 eh
    CROSS JOIN params p
    WHERE UPPER(p.doc_type) = 'EXPENSE'
      AND (p.company IS NULL OR eh.ehco = LPAD(p.company, 5, '0'))
      AND (p.doc_number IS NULL OR UPPER(eh.ehexrptnum) LIKE UPPER('%' || p.doc_number || '%'))
      AND (p.doc_number IS NOT NULL OR eh.ehdatesub >= TO_NUMBER(TO_CHAR(SYSDATE - 365, 'YYYYDDD')) - 1900000)
)
ORDER BY doc_date DESC NULLS LAST
FETCH FIRST 25 ROWS ONLY;
