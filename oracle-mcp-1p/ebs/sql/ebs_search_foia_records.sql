-- Tool: ebs_search_foia_records
-- Skill: redaction_and_foia_compliance
-- Oracle Bind Variables:
--   :query_keyword (string): Keyword, party name, or solicitation identifier for discovery search.
--   :start_date (string): Discovery date window start in YYYY-MM-DD format.
--   :end_date (string): Discovery date window end in YYYY-MM-DD format.
--   :org_id (integer): Agency tenant Operating Unit / Organization ID to filter discovery.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :query_keyword AS query_keyword,
        :start_date AS start_date,
        :end_date AS end_date,
        :org_id AS org_id
    FROM dual
)
SELECT * FROM (
    SELECT
        'PO' AS source_module,
        TO_CHAR(po.po_header_id) AS record_id,
        po.segment1 AS document_number,
        po.type_lookup_code AS document_type,
        TO_CHAR(po.creation_date, 'YYYY-MM-DD') AS creation_date,
        po.org_id,
        vend.vendor_name AS party_name,
        po.comments AS record_summary
    FROM params p
    JOIN apps.po_headers_all po
        ON (p.start_date IS NULL OR po.creation_date >= TO_DATE(p.start_date, 'YYYY-MM-DD'))
       AND (p.end_date IS NULL OR po.creation_date <= TO_DATE(p.end_date, 'YYYY-MM-DD') + 1)
       AND (p.org_id IS NULL OR po.org_id = TO_NUMBER(p.org_id))
    LEFT JOIN apps.ap_suppliers vend
        ON po.vendor_id = vend.vendor_id
    WHERE (p.query_keyword IS NULL
        OR UPPER(po.segment1) LIKE UPPER('%' || p.query_keyword || '%')
        OR UPPER(po.comments) LIKE UPPER('%' || p.query_keyword || '%')
        OR UPPER(vend.vendor_name) LIKE UPPER('%' || p.query_keyword || '%'))

    UNION ALL

    SELECT
        'AP' AS source_module,
        TO_CHAR(inv.invoice_id) AS record_id,
        inv.invoice_num AS document_number,
        inv.invoice_type_lookup_code AS document_type,
        TO_CHAR(inv.creation_date, 'YYYY-MM-DD') AS creation_date,
        inv.org_id,
        inv_vend.vendor_name AS party_name,
        inv.description AS record_summary
    FROM params p
    JOIN apps.ap_invoices_all inv
        ON (p.start_date IS NULL OR inv.creation_date >= TO_DATE(p.start_date, 'YYYY-MM-DD'))
       AND (p.end_date IS NULL OR inv.creation_date <= TO_DATE(p.end_date, 'YYYY-MM-DD') + 1)
       AND (p.org_id IS NULL OR inv.org_id = TO_NUMBER(p.org_id))
    LEFT JOIN apps.ap_suppliers inv_vend
        ON inv.vendor_id = inv_vend.vendor_id
    WHERE (p.query_keyword IS NULL
        OR UPPER(inv.invoice_num) LIKE UPPER('%' || p.query_keyword || '%')
        OR UPPER(inv.description) LIKE UPPER('%' || p.query_keyword || '%')
        OR UPPER(inv_vend.vendor_name) LIKE UPPER('%' || p.query_keyword || '%'))

    UNION ALL

    SELECT
        'HR' AS source_module,
        TO_CHAR(papf.person_id) AS record_id,
        papf.employee_number AS document_number,
        'PERSONNEL' AS document_type,
        TO_CHAR(papf.creation_date, 'YYYY-MM-DD') AS creation_date,
        papf.business_group_id AS org_id,
        papf.full_name AS party_name,
        'Title: ' || paaf.title || ' | Assignment: ' || paaf.assignment_number AS record_summary
    FROM params p
    JOIN apps.per_all_people_f papf
        ON TRUNC(SYSDATE) BETWEEN papf.effective_start_date AND papf.effective_end_date
       AND (p.start_date IS NULL OR papf.creation_date >= TO_DATE(p.start_date, 'YYYY-MM-DD'))
       AND (p.end_date IS NULL OR papf.creation_date <= TO_DATE(p.end_date, 'YYYY-MM-DD') + 1)
    LEFT JOIN apps.per_all_assignments_f paaf
        ON papf.person_id = paaf.person_id
       AND TRUNC(SYSDATE) BETWEEN paaf.effective_start_date AND paaf.effective_end_date
    WHERE (p.query_keyword IS NULL
        OR UPPER(papf.full_name) LIKE UPPER('%' || p.query_keyword || '%')
        OR UPPER(papf.employee_number) LIKE UPPER('%' || p.query_keyword || '%'))
)
ORDER BY creation_date DESC
FETCH FIRST 100 ROWS ONLY;
