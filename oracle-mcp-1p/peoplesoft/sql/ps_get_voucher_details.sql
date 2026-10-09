-- Tool: ps_get_voucher_details
-- Skill: expense_auditor
-- Oracle Bind Variables:
--   :business_unit (string): Accounts Payable Business Unit code.
--   :voucher_id (string): AP Voucher ID (PS_VOUCHER.VOUCHER_ID).
--   :invoice_id (string): Vendor invoice number.
--   :po_id (string): Purchase Order ID.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :business_unit AS business_unit,
        :voucher_id AS voucher_id,
        :invoice_id AS invoice_id,
        :po_id AS po_id
    FROM dual
)
SELECT
    vchr.business_unit,
    vchr.voucher_id,
    vchr.invoice_id,
    TO_CHAR(vchr.invoice_dt, 'YYYY-MM-DD') AS invoice_date,
    vchr.total_amt AS voucher_total_amount,
    vline.line_nbr AS voucher_line_number,
    vline.merchandise_amt,
    pohdr.po_id,
    pdist.line_nbr AS po_line_number,
    pdist.qty_po,
    recv.qty_rcv,
    proj.project_id AS grant_project_chartfield,
    (NVL(vline.merchandise_amt, 0) - (NVL(pdist.merchandise_amt, 0))) AS match_variance
FROM params p
JOIN sysadm.ps_voucher vchr
    ON vchr.business_unit = p.business_unit
   AND (p.voucher_id IS NULL OR vchr.voucher_id = p.voucher_id)
   AND (p.invoice_id IS NULL OR vchr.invoice_id = p.invoice_id)
JOIN sysadm.ps_voucher_line vline
    ON vchr.business_unit = vline.business_unit
   AND vchr.voucher_id = vline.voucher_id
   AND (p.po_id IS NULL OR vline.po_id = p.po_id)
LEFT JOIN sysadm.ps_po_hdr pohdr
    ON vline.po_id = pohdr.po_id
LEFT JOIN sysadm.ps_po_line_distrib pdist
    ON vline.po_id = pdist.po_id
   AND vline.line_nbr = pdist.line_nbr
LEFT JOIN sysadm.ps_recv_ln_ship recv
    ON vline.receiver_id = recv.receiver_id
   AND vline.recv_ln_nbr = recv.recv_ln_nbr
LEFT JOIN sysadm.ps_project_resource proj
    ON vline.business_unit = proj.business_unit
   AND vline.project_id = proj.project_id
ORDER BY vchr.voucher_id, vline.line_nbr;
