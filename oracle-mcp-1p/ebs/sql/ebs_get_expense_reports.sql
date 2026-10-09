-- Tool: ebs_get_expense_reports
-- Skill: expense_auditor
-- Oracle Bind Variables:
--   :report_header_id (string): Expense report header ID (AP_EXPENSE_REPORT_HEADERS_ALL.REPORT_HEADER_ID). Empty string = any report.
--   :employee_id (string): Employee person ID who submitted the expense report. Empty string = any employee.
--   :start_date (string): Submission date window start in YYYY-MM-DD format. Empty string = no lower bound.
--   :end_date (string): Submission date window end in YYYY-MM-DD format. Empty string = no upper bound.
--   :include_receipts (string): 'Y' returns the receipt image data (large); anything else returns attachment names only.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :report_header_id AS report_header_id,
        :employee_id AS employee_id,
        :start_date AS start_date,
        :end_date AS end_date,
        :include_receipts AS include_receipts
    FROM dual
)
SELECT
    aerh.report_header_id,
    aerh.invoice_num AS report_number,
    aerh.employee_id,
    aerh.total AS report_total,
    aerh.expense_status_code,
    TO_CHAR(aerh.week_end_date, 'YYYY-MM-DD') AS submission_date,
    aerl.report_line_id,
    aerl.distribution_line_number AS line_num,
    aerl.category_code AS expense_category,
    aerl.amount AS line_amount,
    TO_CHAR(aerl.start_expense_date, 'YYYY-MM-DD') AS expense_date,
    TO_CHAR(aerl.end_expense_date, 'YYYY-MM-DD') AS expense_end_date,
    aerl.location AS expense_location,
    aerl.currency_code,
    aerl.receipt_currency_code,
    aerl.receipt_currency_amount,
    aerl.daily_amount,
    aerl.attendees,
    aerl.number_attendees,
    aerl.travel_type,
    aerl.ticket_class_code,
    aerl.project_number,
    aerl.task_number,
    aerl.award_number,
    aerl.expenditure_type,
    aerl.itemization_parent_id,
    aerl.item_description,
    aerl.justification,
    -- Corporate Setup Policies (Shows even if the expense is OK)
    er_param.prompt AS configured_expense_type,
    aph.policy_name AS assigned_policy_rule,
    aph.description AS policy_rule_description,
    -- Status Flag (Checks if a violation actually occurred)
    CASE 
        WHEN apv.violation_type IS NOT NULL THEN 'VIOLATED: ' || apv.violation_type
        ELSE 'OK'
    END AS policy_status,
    apv.allowable_amount,
    apv.exceeded_amount,
    apv.dup_report_header_id,
    apv.dup_report_line_id,
    -- Receipt rules (setup for the expense type, the value copied onto the line, and the line's receipt status)
    er_param.receipt_required_flag AS type_receipt_required_flag,
    er_param.require_receipt_amount AS type_require_receipt_amount,
    aerl.receipt_required_flag AS line_receipt_required_flag,
    aerl.receipt_missing_flag,
    aerl.receipt_verified_flag,
    aerl.image_receipt_required_flag,
    -- Attachment Metadata
    fad.entity_name AS attachment_level, 
    fdt.title AS attachment_title,
    fdt.description AS attachment_description,
    fl.file_name AS receipt_file_name,
    fl.file_content_type AS receipt_mime_type,
    CASE WHEN UPPER(p.include_receipts) = 'Y' THEN fl.file_data END AS receipt_image_blob
FROM params p
JOIN apps.ap_expense_report_headers_all aerh
    ON (p.report_header_id IS NULL OR aerh.report_header_id = TO_NUMBER(p.report_header_id))
   AND (p.employee_id IS NULL OR aerh.employee_id = TO_NUMBER(p.employee_id))
   AND (p.start_date IS NULL OR aerh.week_end_date >= TO_DATE(p.start_date, 'YYYY-MM-DD'))
   AND (p.end_date IS NULL OR aerh.week_end_date <= TO_DATE(p.end_date, 'YYYY-MM-DD'))
JOIN apps.ap_expense_report_lines_all aerl
    ON aerh.report_header_id = aerl.report_header_id
-- 1. Bridge line item to the setup parameters of the template used
LEFT JOIN apps.ap_expense_report_params_all er_param
    ON aerl.web_parameter_id = er_param.parameter_id
-- 2. Pull the policy rule tied to that template parameter setup
LEFT JOIN apps.ap_pol_headers aph
    ON er_param.company_policy_id = aph.policy_id
-- 3. Match composite key (header_id + distribution_line_number) for violations
LEFT JOIN apps.ap_pol_violations_all apv
    ON aerl.report_header_id = apv.report_header_id
   AND aerl.distribution_line_number = apv.distribution_line_number
-- 4. Dual check for either Header or Line level iExpense attachments
LEFT JOIN apps.fnd_attached_documents fad
    ON (fad.entity_name = 'OIE_HEADER_ATTACHMENTS' AND fad.pk1_value = TO_CHAR(aerh.report_header_id))
    OR (fad.entity_name = 'OIE_LINE_ATTACHMENTS' AND fad.pk1_value = TO_CHAR(aerl.report_line_id))
LEFT JOIN apps.fnd_documents fd
    ON fad.document_id = fd.document_id
LEFT JOIN apps.fnd_documents_tl fdt
    ON fd.document_id = fdt.document_id
   AND fdt.language = USERENV('LANG')
LEFT JOIN apps.fnd_lobs fl
    ON fd.media_id = fl.file_id
ORDER BY aerh.report_header_id, aerl.distribution_line_number
FETCH FIRST 500 ROWS ONLY;
