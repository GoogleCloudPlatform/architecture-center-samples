-- Tool: ebs_get_expense_report_approval_and_payment
-- Skill: expense_auditor
-- Oracle Bind Variables:
--   :report_header_id (string): Expense report header ID. Empty string = any report.
--   :org_id (string): Operating unit ID (ORG_ID). Empty string = all operating units.
--   :start_date (string): Submission (week end) date window start in YYYY-MM-DD format. Empty string = no lower bound.
--   :end_date (string): Submission (week end) date window end in YYYY-MM-DD format. Empty string = no upper bound.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :report_header_id AS report_header_id,
        :org_id AS org_id,
        :start_date AS start_date,
        :end_date AS end_date
    FROM dual
)
SELECT
    aerh.report_header_id,
    aerh.invoice_num AS report_number,
    aerh.employee_id,
    (SELECT MAX(papf.full_name) KEEP (DENSE_RANK LAST ORDER BY papf.effective_start_date)
       FROM apps.per_all_people_f papf
      WHERE papf.person_id = aerh.employee_id) AS employee_name,
    aerh.total AS report_total,
    TO_CHAR(aerh.week_end_date, 'YYYY-MM-DD') AS submission_date,
    TO_CHAR(aerh.report_submitted_date, 'YYYY-MM-DD') AS report_submitted_date,
    aerh.expense_status_code,
    TO_CHAR(aerh.expense_last_status_date, 'YYYY-MM-DD') AS last_status_date,
    aerh.workflow_approved_flag,
    aerh.approval_type,
    aerh.expense_current_approver_id AS current_approver_id,
    (SELECT MAX(papf.full_name) KEEP (DENSE_RANK LAST ORDER BY papf.effective_start_date)
       FROM apps.per_all_people_f papf
      WHERE papf.person_id = aerh.expense_current_approver_id) AS current_approver_name,
    CASE WHEN aerh.expense_current_approver_id = aerh.employee_id THEN 'Y' ELSE 'N' END AS approver_is_submitter,
    aerh.override_approver_id,
    aerh.override_approver_name,
    aerh.receipts_status,
    TO_CHAR(aerh.receipts_received_date, 'YYYY-MM-DD') AS receipts_received_date,
    aerh.image_receipts_status,
    aerh.missing_img_just AS missing_image_justification,
    aerh.audit_code,
    aerh.last_audited_by,
    aerh.hold_lookup_code,
    aerh.reject_code,
    aia.invoice_id,
    aia.invoice_amount,
    aia.amount_paid,
    aia.payment_status_flag,
    aia.approval_status AS invoice_approval_status,
    TO_CHAR(aia.gl_date, 'YYYY-MM-DD') AS invoice_gl_date,
    aip.amount AS payment_amount,
    TO_CHAR(aip.accounting_date, 'YYYY-MM-DD') AS payment_accounting_date,
    ac.check_number,
    TO_CHAR(ac.check_date, 'YYYY-MM-DD') AS payment_date,
    ac.status_lookup_code AS payment_status,
    ac.payment_method_lookup_code AS payment_method,
    TO_CHAR(ac.cleared_date, 'YYYY-MM-DD') AS cleared_date,
    TO_CHAR(ac.void_date, 'YYYY-MM-DD') AS void_date
FROM params p
JOIN apps.ap_expense_report_headers_all aerh
    ON (p.report_header_id IS NULL OR aerh.report_header_id = TO_NUMBER(p.report_header_id))
   AND (p.org_id IS NULL OR aerh.org_id = TO_NUMBER(p.org_id))
   AND (p.start_date IS NULL OR aerh.week_end_date >= TO_DATE(p.start_date, 'YYYY-MM-DD'))
   AND (p.end_date IS NULL OR aerh.week_end_date <= TO_DATE(p.end_date, 'YYYY-MM-DD'))
LEFT JOIN apps.ap_invoices_all aia
    ON aia.invoice_num = aerh.invoice_num
   AND aia.org_id = aerh.org_id
LEFT JOIN apps.ap_invoice_payments_all aip
    ON aip.invoice_id = aia.invoice_id
LEFT JOIN apps.ap_checks_all ac
    ON ac.check_id = aip.check_id
ORDER BY aerh.week_end_date DESC, aerh.report_header_id DESC, aip.invoice_payment_id
FETCH FIRST 200 ROWS ONLY;
