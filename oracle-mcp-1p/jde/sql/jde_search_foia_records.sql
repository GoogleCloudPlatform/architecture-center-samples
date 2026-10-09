-- Tool: jde_search_foia_records
-- Skill: redaction_and_foia_compliance
-- Oracle Bind Variables:
--   :search_keyword (string): Keyword, party name, document number or supplier invoice number to search for.
--   :category (string): Record category filter: 'HR', 'PO', 'AP' or 'ALL'.
--   :start_date (string): Record date window start in YYYY-MM-DD format.
--   :end_date (string): Record date window end in YYYY-MM-DD format.
--   :company (string): Optional JDE company (e.g. '00001') to scope the search to one agency.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :search_keyword AS search_keyword,
        :category AS category,
        :start_date AS start_date,
        :end_date AS end_date,
        TO_CHAR(:company) AS company
    FROM dual
)
SELECT * FROM (
    -- HR employee master records
    SELECT
        'HR' AS record_category,
        TO_CHAR(ya.yaan8) AS reference_id,
        'F060116' AS source_table,
        'EMPLOYEE' AS document_type,
        TO_CHAR(TRIM(ya.yahmco)) AS company,
        TO_CHAR(TRIM(ya.yaalph)) AS party_name,
        TO_CHAR(RTRIM('Employee ' || TRIM(ya.yaoemp) || ' | Job ' || TRIM(ya.yajbcd) || ' ' || TRIM(ya.yajbst) || ' | BU ' || TRIM(ya.yahmcu), ' |')) AS record_summary,
        CASE WHEN ya.yadst > 0 THEN TO_CHAR(TO_DATE(TO_CHAR(ya.yadst + 1900000), 'YYYYDDD'), 'YYYY-MM-DD') END AS record_date
    FROM params p
    JOIN proddta.f060116 ya
        ON (p.category IS NULL OR UPPER(p.category) IN ('HR', 'ALL'))
       AND (p.company IS NULL OR ya.yahmco = LPAD(p.company, 5, '0'))
       AND (p.start_date IS NULL OR ya.yadst >= TO_NUMBER(TO_CHAR(TO_DATE(p.start_date, 'YYYY-MM-DD'), 'YYYYDDD')) - 1900000)
       AND (p.end_date IS NULL OR ya.yadst <= TO_NUMBER(TO_CHAR(TO_DATE(p.end_date, 'YYYY-MM-DD'), 'YYYYDDD')) - 1900000)
    WHERE (p.search_keyword IS NULL
        OR UPPER(ya.yaalph) LIKE UPPER('%' || p.search_keyword || '%')
        OR TO_CHAR(ya.yaan8) = p.search_keyword
        OR TRIM(ya.yaoemp) = p.search_keyword)

    UNION ALL

    -- Purchase orders and contracts
    SELECT
        'PO' AS record_category,
        TO_CHAR(ph.phdoco) AS reference_id,
        'F4301' AS source_table,
        TO_CHAR(ph.phdcto) AS document_type,
        TO_CHAR(ph.phkcoo) AS company,
        TO_CHAR(TRIM(ab.abalph)) AS party_name,
        TO_CHAR(RTRIM('Order ' || TRIM(ph.phdesc) || ' | Ref ' || TRIM(ph.phvr01) || ' | ' || TRIM(ph.phrmk), ' |')) AS record_summary,
        CASE WHEN ph.phtrdj > 0 THEN TO_CHAR(TO_DATE(TO_CHAR(ph.phtrdj + 1900000), 'YYYYDDD'), 'YYYY-MM-DD') END AS record_date
    FROM params p
    JOIN proddta.f4301 ph
        ON (p.category IS NULL OR UPPER(p.category) IN ('PO', 'ALL'))
       AND (p.company IS NULL OR ph.phkcoo = LPAD(p.company, 5, '0'))
       AND (p.start_date IS NULL OR ph.phtrdj >= TO_NUMBER(TO_CHAR(TO_DATE(p.start_date, 'YYYY-MM-DD'), 'YYYYDDD')) - 1900000)
       AND (p.end_date IS NULL OR ph.phtrdj <= TO_NUMBER(TO_CHAR(TO_DATE(p.end_date, 'YYYY-MM-DD'), 'YYYYDDD')) - 1900000)
    LEFT JOIN proddta.f0101 ab
        ON ab.aban8 = ph.phan8
    WHERE (p.search_keyword IS NULL
        OR TO_CHAR(ph.phdoco) = p.search_keyword
        OR UPPER(ph.phdesc) LIKE UPPER('%' || p.search_keyword || '%')
        OR UPPER(ph.phvr01) LIKE UPPER('%' || p.search_keyword || '%')
        OR UPPER(ab.abalph) LIKE UPPER('%' || p.search_keyword || '%'))

    UNION ALL

    -- A/P vouchers (first pay item only, one row per voucher)
    SELECT
        'AP' AS record_category,
        TO_CHAR(ap.rpdoc) AS reference_id,
        'F0411' AS source_table,
        TO_CHAR(ap.rpdct) AS document_type,
        TO_CHAR(ap.rpkco) AS company,
        TO_CHAR(TRIM(ab.abalph)) AS party_name,
        TO_CHAR(RTRIM('Voucher for invoice ' || TRIM(ap.rpvinv) || ' | ' || TRIM(ap.rprmk), ' |')) AS record_summary,
        CASE WHEN ap.rpdivj > 0 THEN TO_CHAR(TO_DATE(TO_CHAR(ap.rpdivj + 1900000), 'YYYYDDD'), 'YYYY-MM-DD') END AS record_date
    FROM params p
    JOIN proddta.f0411 ap
        ON ap.rpsfx = '001'
       AND (p.category IS NULL OR UPPER(p.category) IN ('AP', 'ALL'))
       AND (p.company IS NULL OR ap.rpkco = LPAD(p.company, 5, '0'))
       AND (p.start_date IS NULL OR ap.rpdivj >= TO_NUMBER(TO_CHAR(TO_DATE(p.start_date, 'YYYY-MM-DD'), 'YYYYDDD')) - 1900000)
       AND (p.end_date IS NULL OR ap.rpdivj <= TO_NUMBER(TO_CHAR(TO_DATE(p.end_date, 'YYYY-MM-DD'), 'YYYYDDD')) - 1900000)
    LEFT JOIN proddta.f0101 ab
        ON ab.aban8 = ap.rpan8
    WHERE (p.search_keyword IS NULL
        OR TO_CHAR(ap.rpdoc) = p.search_keyword
        OR UPPER(ap.rpvinv) LIKE UPPER('%' || p.search_keyword || '%')
        OR UPPER(ap.rprmk) LIKE UPPER('%' || p.search_keyword || '%')
        OR UPPER(ab.abalph) LIKE UPPER('%' || p.search_keyword || '%'))
)
ORDER BY record_date DESC
FETCH FIRST 100 ROWS ONLY;
