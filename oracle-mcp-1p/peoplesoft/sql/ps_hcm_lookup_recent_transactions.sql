-- Tool: ps_hcm_lookup_recent_transactions
-- Skill: ps_hcm_schema_discovery_and_lovs
-- Oracle Bind Variables:
--   :doc_type (string): PAYCHECK, PROJECT or VENDOR. Required.
--   :org_code (string): Company (PAYCHECK), Project Costing business unit (PROJECT) or SetID (VENDOR). Empty = any.
--   :doc_id (string): Start of the ID: paycheck number or EMPLID (PAYCHECK), project ID (PROJECT), vendor ID (VENDOR). Empty = latest records.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :doc_type AS doc_type,
        :org_code AS org_code,
        :doc_id AS doc_id
    FROM dual
)
SELECT * FROM (
    SELECT
        'PAYCHECK' AS doc_type,
        c.company AS org_code,
        TO_CHAR(c.paycheck_nbr) AS doc_id,
        c.emplid AS alt_number,
        TO_CHAR(c.check_dt, 'YYYY-MM-DD') AS doc_date,
        c.paycheck_status AS doc_status,
        c.total_gross AS total_amt
    FROM params p
    JOIN sysadm.ps_pay_check c
        ON UPPER(p.doc_type) = 'PAYCHECK'
       AND (p.org_code IS NULL OR c.company = p.org_code)
       AND (p.doc_id IS NULL OR TO_CHAR(c.paycheck_nbr) LIKE p.doc_id || '%' OR c.emplid = p.doc_id)
    UNION ALL
    SELECT
        'PROJECT',
        pr.business_unit,
        pr.project_id,
        pr.descr,
        TO_CHAR(pr.dttm_stamp, 'YYYY-MM-DD'),
        pr.eff_status,
        CAST(NULL AS NUMBER)
    FROM params p
    JOIN sysadm.ps_project pr
        ON UPPER(p.doc_type) = 'PROJECT'
       AND (p.org_code IS NULL OR pr.business_unit = p.org_code)
       AND (p.doc_id IS NULL OR pr.project_id LIKE p.doc_id || '%')
    UNION ALL
    SELECT
        'VENDOR',
        v.setid,
        v.vendor_id,
        v.name1,
        TO_CHAR(v.last_activity_dt, 'YYYY-MM-DD'),
        v.vendor_status,
        CAST(NULL AS NUMBER)
    FROM params p
    JOIN sysadm.ps_vendor v
        ON UPPER(p.doc_type) = 'VENDOR'
       AND (p.org_code IS NULL OR v.setid = p.org_code)
       AND (p.doc_id IS NULL OR v.vendor_id LIKE p.doc_id || '%')
    ORDER BY 5 DESC NULLS LAST
)
WHERE ROWNUM <= 25;
