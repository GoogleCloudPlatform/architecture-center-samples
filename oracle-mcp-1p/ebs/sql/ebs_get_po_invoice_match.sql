-- Tool: ebs_get_po_invoice_match
-- Skill: expense_auditor
-- Oracle Bind Variables:
--   :invoice_id (string): Accounts payable invoice ID (AP_INVOICES_ALL.INVOICE_ID). Empty string = any invoice.
--   :po_header_id (string): Purchase order header ID (PO_HEADERS_ALL.PO_HEADER_ID). Empty string = any purchase order.
--   :po_number (string): Purchase order reference number string. Empty string = any purchase order number.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :invoice_id AS invoice_id,
        :po_header_id AS po_header_id,
        :po_number AS po_number
    FROM dual
)
SELECT
    aia.invoice_id,
    aia.invoice_num,
    TO_CHAR(aia.invoice_date, 'YYYY-MM-DD') AS invoice_date,
    aia.invoice_amount,
    pha.po_header_id,
    pha.segment1 AS po_number,
    pla.line_num AS po_line_number,
    pla.quantity AS quantity_ordered,
    pla.unit_price AS po_unit_price,
    aila.line_number AS invoice_line_number,
    aila.quantity_invoiced,
    aila.amount AS invoice_line_amount,
    rcv.quantity AS quantity_received,
    (NVL(aila.amount, 0) - (NVL(pla.unit_price, 0) * NVL(rcv.quantity, 0))) AS match_variance,
    gad.award_id,
    gad.project_id,
    gad.task_id
FROM params p
JOIN apps.ap_invoices_all aia
    ON (p.invoice_id IS NULL OR aia.invoice_id = TO_NUMBER(p.invoice_id))
JOIN apps.ap_invoice_lines_all aila
    ON aia.invoice_id = aila.invoice_id
LEFT JOIN apps.po_headers_all pha
    ON aila.po_header_id = pha.po_header_id
   AND (p.po_header_id IS NULL OR pha.po_header_id = TO_NUMBER(p.po_header_id))
   AND (p.po_number IS NULL OR pha.segment1 = p.po_number)
LEFT JOIN apps.po_lines_all pla
    ON aila.po_line_id = pla.po_line_id
LEFT JOIN apps.rcv_transactions rcv
    ON aila.rcv_transaction_id = rcv.transaction_id
LEFT JOIN apps.ap_invoice_distributions_all aida
    ON aila.invoice_id = aida.invoice_id
   AND aila.line_number = aida.invoice_line_number
LEFT JOIN apps.gms_award_distributions gad
    ON aida.invoice_distribution_id = gad.invoice_distribution_id
WHERE (p.po_header_id IS NULL AND p.po_number IS NULL) OR pha.po_header_id IS NOT NULL
ORDER BY aia.invoice_id, aila.line_number
FETCH FIRST 200 ROWS ONLY;
