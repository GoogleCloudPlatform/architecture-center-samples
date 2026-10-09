-- Tool: ebs_list_expense_reports
-- Skill: expense_auditor
-- Oracle Bind Variables:
--   :org_id (string): Operating unit ID (ORG_ID). Empty string = all operating units.
--   :employee_id (string): Employee person ID who submitted the report. Empty string = all employees.
--   :status (string): Expense status code, e.g. 'PAID', 'INVOICED', 'REJECTED', 'PENDING_MGRAPPRVL'. Empty string = all statuses.
--   :start_date (string): Submission (week end) date window start in YYYY-MM-DD format. Empty string = no lower bound.
--   :end_date (string): Submission (week end) date window end in YYYY-MM-DD format. Empty string = no upper bound.
--   :min_total (string): Minimum report total, e.g. '500'. Empty string = no minimum.
--   :offset (string): Number of matching reports to skip, for paging (0 or empty string = first page of 50).
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :org_id AS org_id,
        :employee_id AS employee_id,
        :status AS status,
        :start_date AS start_date,
        :end_date AS end_date,
        :min_total AS min_total,
        :offset AS offset_rows
    FROM dual
)
SELECT
    q.report_header_id,
    q.report_number,
    q.org_id,
    q.employee_id,
    q.employee_name,
    q.report_total,
    q.expense_status_code,
    q.submission_date,
    q.line_count,
    q.policy_violation_count,
    q.lines_receipt_missing,
    q.lines_receipt_unverified,
    q.attachment_count,
    q.total_matches,
    q.row_number,
    CASE WHEN q.total_matches > q.row_number THEN 'Y' ELSE 'N' END AS more_rows_follow
FROM (
    SELECT
        aerh.report_header_id,
        aerh.invoice_num AS report_number,
        aerh.org_id,
        aerh.employee_id,
        (SELECT MAX(papf.full_name) KEEP (DENSE_RANK LAST ORDER BY papf.effective_start_date)
           FROM apps.per_all_people_f papf
          WHERE papf.person_id = aerh.employee_id) AS employee_name,
        aerh.total AS report_total,
        aerh.expense_status_code,
        TO_CHAR(aerh.week_end_date, 'YYYY-MM-DD') AS submission_date,
        (SELECT COUNT(*)
           FROM apps.ap_expense_report_lines_all aerl
          WHERE aerl.report_header_id = aerh.report_header_id) AS line_count,
        (SELECT COUNT(*)
           FROM apps.ap_pol_violations_all apv
          WHERE apv.report_header_id = aerh.report_header_id) AS policy_violation_count,
        (SELECT COUNT(*)
           FROM apps.ap_expense_report_lines_all aerl
          WHERE aerl.report_header_id = aerh.report_header_id
            AND aerl.receipt_missing_flag = 'Y') AS lines_receipt_missing,
        (SELECT COUNT(*)
           FROM apps.ap_expense_report_lines_all aerl
          WHERE aerl.report_header_id = aerh.report_header_id
            AND aerl.receipt_required_flag = 'Y'
            AND NVL(aerl.receipt_verified_flag, 'N') <> 'Y') AS lines_receipt_unverified,
        (SELECT COUNT(*)
           FROM apps.fnd_attached_documents fad
          WHERE (fad.entity_name = 'OIE_HEADER_ATTACHMENTS' AND fad.pk1_value = TO_CHAR(aerh.report_header_id))
             OR (fad.entity_name = 'OIE_LINE_ATTACHMENTS'
                 AND fad.pk1_value IN (SELECT TO_CHAR(l.report_line_id)
                                         FROM apps.ap_expense_report_lines_all l
                                        WHERE l.report_header_id = aerh.report_header_id))) AS attachment_count,
        COUNT(*) OVER () AS total_matches,
        ROW_NUMBER() OVER (ORDER BY aerh.week_end_date DESC, aerh.report_header_id DESC) AS row_number,
        p.offset_rows
    FROM params p
    JOIN apps.ap_expense_report_headers_all aerh
        ON (p.org_id IS NULL OR aerh.org_id = TO_NUMBER(p.org_id))
       AND (p.employee_id IS NULL OR aerh.employee_id = TO_NUMBER(p.employee_id))
       AND (p.status IS NULL OR aerh.expense_status_code = p.status)
       AND (p.start_date IS NULL OR aerh.week_end_date >= TO_DATE(p.start_date, 'YYYY-MM-DD'))
       AND (p.end_date IS NULL OR aerh.week_end_date <= TO_DATE(p.end_date, 'YYYY-MM-DD'))
       AND (p.min_total IS NULL OR aerh.total >= TO_NUMBER(p.min_total))
) q
WHERE q.row_number > NVL(TO_NUMBER(q.offset_rows), 0)
  AND q.row_number <= NVL(TO_NUMBER(q.offset_rows), 0) + 50
ORDER BY q.row_number;
