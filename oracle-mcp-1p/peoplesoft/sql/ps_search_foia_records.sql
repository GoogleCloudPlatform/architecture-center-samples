-- Tool: ps_search_foia_records
-- Skill: redaction_and_foia_compliance
-- Oracle Bind Variables:
--   :search_keyword (string): Search term, name, or contract identifier.
--   :category (string): Record category filter (e.g., 'HR', 'PO', 'AP', 'ALL').
--   :start_date (string): Date range filter start (YYYY-MM-DD).
--   :end_date (string): Date range filter end (YYYY-MM-DD).
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :search_keyword AS search_keyword,
        :category AS category,
        :start_date AS start_date,
        :end_date AS end_date
    FROM dual
)
SELECT * FROM (
    -- HCM Employee Records
    SELECT
        'HR' AS record_category,
        nm.emplid AS reference_id,
        nm.name_display AS party_name,
        'HCM Personnel Record' AS record_title,
        TO_CHAR(pers.birthdate, 'YYYY-MM-DD') AS record_date,
        (SELECT COUNT(*) FROM sysadm.ps_attachment_tbl att WHERE att.attachsysfilename LIKE nm.emplid || '%') AS attachment_count
    FROM params p
    JOIN sysadm.ps_names nm
        ON nm.name_type = 'PRI'
       AND (p.category IS NULL OR UPPER(p.category) IN ('HR', 'ALL'))
       AND (p.search_keyword IS NULL OR UPPER(nm.name_display) LIKE UPPER('%' || p.search_keyword || '%') OR UPPER(nm.emplid) LIKE UPPER('%' || p.search_keyword || '%'))
    JOIN sysadm.ps_personal_data pers
        ON nm.emplid = pers.emplid

    UNION ALL

    -- FSCM Purchase Orders
    SELECT
        'PO' AS record_category,
        po.po_id AS reference_id,
        po.vendor_setid || '-' || po.vendor_id AS party_name,
        'Purchase Order: ' || po.descr254_mixed AS record_title,
        TO_CHAR(po.po_dt, 'YYYY-MM-DD') AS record_date,
        (SELECT COUNT(*) FROM sysadm.ps_attachment_tbl att WHERE att.attachsysfilename LIKE po.po_id || '%') AS attachment_count
    FROM params p
    JOIN sysadm.ps_po_hdr po
        ON (p.category IS NULL OR UPPER(p.category) IN ('PO', 'ALL'))
       AND (p.search_keyword IS NULL OR UPPER(po.po_id) LIKE UPPER('%' || p.search_keyword || '%') OR UPPER(po.descr254_mixed) LIKE UPPER('%' || p.search_keyword || '%'))
       AND (p.start_date IS NULL OR po.po_dt >= TO_DATE(p.start_date, 'YYYY-MM-DD'))
       AND (p.end_date IS NULL OR po.po_dt <= TO_DATE(p.end_date, 'YYYY-MM-DD'))

    UNION ALL

    -- FSCM AP Vouchers
    SELECT
        'AP' AS record_category,
        vchr.voucher_id AS reference_id,
        vchr.vendor_setid || '-' || vchr.vendor_id AS party_name,
        'AP Voucher: ' || vchr.invoice_id AS record_title,
        TO_CHAR(vchr.invoice_dt, 'YYYY-MM-DD') AS record_date,
        (SELECT COUNT(*) FROM sysadm.ps_attachment_tbl att WHERE att.attachsysfilename LIKE vchr.voucher_id || '%') AS attachment_count
    FROM params p
    JOIN sysadm.ps_voucher vchr
        ON (p.category IS NULL OR UPPER(p.category) IN ('AP', 'ALL'))
       AND (p.search_keyword IS NULL OR UPPER(vchr.voucher_id) LIKE UPPER('%' || p.search_keyword || '%') OR UPPER(vchr.invoice_id) LIKE UPPER('%' || p.search_keyword || '%'))
       AND (p.start_date IS NULL OR vchr.invoice_dt >= TO_DATE(p.start_date, 'YYYY-MM-DD'))
       AND (p.end_date IS NULL OR vchr.invoice_dt <= TO_DATE(p.end_date, 'YYYY-MM-DD'))
)
ORDER BY record_date DESC
FETCH FIRST 100 ROWS ONLY;
