-- Tool: ps_get_expense_sheets
-- Skill: expense_auditor
-- Oracle Bind Variables:
--   :sheet_id (string): Expense sheet identifier (PS_EX_SHEET_HDR.SHEET_ID).
--   :emplid (string): Employee EMPLID who submitted the expense report.
--   :start_date (string): Submission date window start (YYYY-MM-DD).
--   :end_date (string): Submission date window end (YYYY-MM-DD).
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :sheet_id AS sheet_id,
        :emplid AS emplid,
        :start_date AS start_date,
        :end_date AS end_date
    FROM dual
)
SELECT
    hdr.sheet_id,
    hdr.emplid,
    hdr.sheet_status,
    hdr.total_amount,
    TO_CHAR(hdr.posted_date, 'YYYY-MM-DD') AS submission_date,
    line.line_nbr,
    line.expense_type,
    line.amount AS line_amount,
    TO_CHAR(line.expense_dt, 'YYYY-MM-DD') AS expense_date,
    line.merchant,
    line.descr254 AS business_purpose,
    dist.fund_code,
    dist.deptid,
    dist.project_id,
    att.attachsysfilename,
    att.attachuserfile AS receipt_filename
FROM params p
JOIN sysadm.ps_ex_sheet_hdr hdr
    ON (p.sheet_id IS NULL OR hdr.sheet_id = p.sheet_id)
   AND (p.emplid IS NULL OR hdr.emplid = p.emplid)
   AND (p.start_date IS NULL OR hdr.posted_date >= TO_DATE(p.start_date, 'YYYY-MM-DD'))
   AND (p.end_date IS NULL OR hdr.posted_date <= TO_DATE(p.end_date, 'YYYY-MM-DD'))
JOIN sysadm.ps_ex_sheet_line line
    ON hdr.sheet_id = line.sheet_id
LEFT JOIN sysadm.ps_ex_sheet_dist dist
    ON line.sheet_id = dist.sheet_id
   AND line.line_nbr = dist.line_nbr
LEFT JOIN sysadm.ps_ex_att_tbl att
    ON line.sheet_id = att.sheet_id
   AND line.line_nbr = att.line_nbr
ORDER BY hdr.sheet_id, line.line_nbr;
