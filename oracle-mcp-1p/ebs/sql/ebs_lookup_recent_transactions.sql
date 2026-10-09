-- Tool: ebs_lookup_recent_transactions
-- Skill: schema_discovery_and_lovs
-- Oracle Bind Variables:
--   :doc_type (string): Document type filter: 'PO', 'INVOICE', 'NOTICE', 'RFP', or 'EXPENSE'.
--   :doc_number (string): Optional partial document or invoice number.
--   :org_id (string): Optional operating unit ID. Empty string = all operating units.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :doc_type AS doc_type,
        :doc_number AS doc_number,
        :org_id AS org_id
    FROM dual
)
SELECT * FROM (
    SELECT
        'PO' AS doc_type,
        po.po_header_id AS header_id,
        po.segment1 AS doc_number,
        TO_CHAR(po.creation_date, 'YYYY-MM-DD') AS doc_date,
        po.authorization_status AS doc_status,
        po.org_id
    FROM apps.po_headers_all po, params p
    WHERE UPPER(p.doc_type) = 'PO'
      AND (p.doc_number IS NULL OR po.segment1 LIKE '%' || p.doc_number || '%')
      AND (p.org_id IS NULL OR po.org_id = TO_NUMBER(p.org_id))
    UNION ALL
    SELECT
        'INVOICE' AS doc_type,
        inv.invoice_id AS header_id,
        inv.invoice_num AS doc_number,
        TO_CHAR(inv.invoice_date, 'YYYY-MM-DD') AS doc_date,
        inv.payment_status_flag AS doc_status,
        inv.org_id
    FROM apps.ap_invoices_all inv, params p
    WHERE UPPER(p.doc_type) = 'INVOICE'
      AND (p.doc_number IS NULL OR inv.invoice_num LIKE '%' || p.doc_number || '%')
      AND (p.org_id IS NULL OR inv.org_id = TO_NUMBER(p.org_id))
    UNION ALL
    SELECT
        'NOTICE' AS doc_type,
        trx.customer_trx_id AS header_id,
        trx.trx_number AS doc_number,
        TO_CHAR(trx.trx_date, 'YYYY-MM-DD') AS doc_date,
        trx.complete_flag AS doc_status,
        trx.org_id
    FROM apps.ra_customer_trx_all trx, params p
    WHERE UPPER(p.doc_type) = 'NOTICE'
      AND (p.doc_number IS NULL OR trx.trx_number LIKE '%' || p.doc_number || '%')
      AND (p.org_id IS NULL OR trx.org_id = TO_NUMBER(p.org_id))
    UNION ALL
    SELECT
        'RFP' AS doc_type,
        pon.auction_header_id AS header_id,
        pon.document_number AS doc_number,
        TO_CHAR(pon.creation_date, 'YYYY-MM-DD') AS doc_date,
        pon.auction_status AS doc_status,
        pon.org_id
    FROM apps.pon_auction_headers_all pon, params p
    WHERE UPPER(p.doc_type) = 'RFP'
      AND (p.doc_number IS NULL OR pon.document_number LIKE '%' || p.doc_number || '%')
      AND (p.org_id IS NULL OR pon.org_id = TO_NUMBER(p.org_id))
    UNION ALL
    SELECT
        'EXPENSE' AS doc_type,
        er.report_header_id AS header_id,
        er.invoice_num AS doc_number,
        TO_CHAR(er.creation_date, 'YYYY-MM-DD') AS doc_date,
        er.expense_status_code AS doc_status,
        er.org_id
    FROM apps.ap_expense_report_headers_all er, params p
    WHERE UPPER(p.doc_type) = 'EXPENSE'
      AND (p.doc_number IS NULL OR er.invoice_num LIKE '%' || p.doc_number || '%')
      AND (p.org_id IS NULL OR er.org_id = TO_NUMBER(p.org_id))
)
ORDER BY doc_date DESC
FETCH FIRST 25 ROWS ONLY;
