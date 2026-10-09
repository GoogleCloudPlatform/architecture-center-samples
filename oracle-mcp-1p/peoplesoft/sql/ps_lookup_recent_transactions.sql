-- Tool: ps_lookup_recent_transactions
-- Skill: schema_discovery_and_lovs
-- Oracle Bind Variables:
--   :business_unit (string): Business unit identifier.
--   :doc_type (string): Document type filter: 'VOUCHER', 'PO', 'EVENT', or 'EXPENSE'.
--   :doc_id (string): Optional partial document identifier or sequence number.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :business_unit AS business_unit,
        :doc_type AS doc_type,
        :doc_id AS doc_id
    FROM dual
)
SELECT * FROM (
    SELECT
        'VOUCHER' AS doc_type,
        v.business_unit,
        v.voucher_id AS doc_id,
        v.invoice_id AS alt_number,
        TO_CHAR(v.invoice_dt, 'YYYY-MM-DD') AS doc_date,
        v.entry_status AS doc_status,
        v.gross_amt AS total_amt
    FROM sysadm.ps_voucher v, params p
    WHERE UPPER(p.doc_type) = 'VOUCHER'
      AND v.business_unit = p.business_unit
      AND (p.doc_id IS NULL OR v.voucher_id LIKE '%' || p.doc_id || '%')
    UNION ALL
    SELECT
        'PO' AS doc_type,
        po.business_unit,
        po.po_id AS doc_id,
        po.po_id AS alt_number,
        TO_CHAR(po.po_dt, 'YYYY-MM-DD') AS doc_date,
        po.po_status AS doc_status,
        0 AS total_amt
    FROM sysadm.ps_po_hdr po, params p
    WHERE UPPER(p.doc_type) = 'PO'
      AND po.business_unit = p.business_unit
      AND (p.doc_id IS NULL OR po.po_id LIKE '%' || p.doc_id || '%')
    UNION ALL
    SELECT
        'EVENT' AS doc_type,
        auc.business_unit,
        auc.auc_event_id AS doc_id,
        auc.auc_event_id AS alt_number,
        TO_CHAR(auc.event_dttm, 'YYYY-MM-DD') AS doc_date,
        auc.event_status AS doc_status,
        0 AS total_amt
    FROM sysadm.ps_auc_event_hdr auc, params p
    WHERE UPPER(p.doc_type) = 'EVENT'
      AND auc.business_unit = p.business_unit
      AND (p.doc_id IS NULL OR auc.auc_event_id LIKE '%' || p.doc_id || '%')
    UNION ALL
    SELECT
        'EXPENSE' AS doc_type,
        p.business_unit,
        ex.sheet_id AS doc_id,
        ex.emplid AS alt_number,
        TO_CHAR(ex.sheet_dttm, 'YYYY-MM-DD') AS doc_date,
        ex.sheet_status AS doc_status,
        ex.total_amt AS total_amt
    FROM sysadm.ps_ex_sheet_hdr ex, params p
    WHERE UPPER(p.doc_type) = 'EXPENSE'
      AND (p.doc_id IS NULL OR ex.sheet_id LIKE '%' || p.doc_id || '%')
)
ORDER BY doc_date DESC
FETCH FIRST 25 ROWS ONLY;
