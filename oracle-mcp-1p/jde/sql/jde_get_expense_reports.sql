-- Tool: jde_get_expense_reports
-- Skill: expense_auditor
-- Oracle Bind Variables:
--   :report_number (string): Expense report number (F20111.EHEXRPTNUM).
--   :employee_an8 (string): Address number of the employee who submitted the report (F20111.EHEMPLOYID).
--   :start_date (string): Submission date window start in YYYY-MM-DD format.
--   :end_date (string): Submission date window end in YYYY-MM-DD format.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :report_number AS report_number,
        :employee_an8 AS employee_an8,
        :start_date AS start_date,
        :end_date AS end_date
    FROM dual
)
-- The policy rule shown for each line is the one effective on the expense date for
-- the report's policy and expense category, preferring a location-specific rule.
SELECT
    TRIM(eh.ehexrptnum) AS report_number,
    eh.ehexrpttyp AS report_type,
    eh.ehemployid AS employee_an8,
    TRIM(emp.abalph) AS employee_name,
    TRIM(eh.ehexrptdes) AS report_description,
    TRIM(eh.ehbuspurp) AS report_business_purpose,
    TRIM(eh.ehexrptsta) AS report_status,
    CASE WHEN eh.ehdatesub > 0 THEN TO_CHAR(TO_DATE(TO_CHAR(eh.ehdatesub + 1900000), 'YYYYDDD'), 'YYYY-MM-DD') END AS submission_date,
    CASE WHEN eh.ehdateapp > 0 THEN TO_CHAR(TO_DATE(TO_CHAR(eh.ehdateapp + 1900000), 'YYYYDDD'), 'YYYY-MM-DD') END AS approval_date,
    eh.ehtotexp / 100 AS report_total,
    eh.ehreimbtot / 100 AS reimbursement_total,
    eh.ehgovuntot / 100 AS unallowable_total,
    eh.ehcashadv / 100 AS cash_advance,
    eh.ehnumexc AS exception_count,
    TRIM(eh.ehpolicy) AS policy_name,
    TRIM(eh.ehco) AS company,
    TRIM(eh.ehhmcu) AS home_business_unit,
    ed.edlin / 100 AS line_number,
    TRIM(ed.edexptype) AS expense_category,
    CASE WHEN ed.edexpdate > 0 THEN TO_CHAR(TO_DATE(TO_CHAR(ed.edexpdate + 1900000), 'YYYYDDD'), 'YYYY-MM-DD') END AS expense_date,
    ed.edexpfamt / 100 AS expense_amount,
    TRIM(ed.edcrcd) AS expense_currency,
    ed.edexpdamt / 100 AS reimbursement_amount,
    ed.edgovtamt / 100 AS allowable_amount,
    ed.edgovtuamt / 100 AS unallowable_amount,
    ed.edtapda / 100 AS per_diem_available,
    TRIM(ed.edpmtmeth) AS payment_method,
    TRIM(ed.edbuspurp) AS business_purpose,
    TRIM(ed.edaddlcmt) AS additional_comments,
    TRIM(ed.edhotelloc) AS hotel_location,
    ed.ednumnites AS number_of_nights,
    ed.edrcptlbl AS receipt_label,
    TRIM(ed.edmcu0) AS charged_business_unit,
    TO_CHAR(TRIM(ed.edsbl)) || CASE WHEN TRIM(ed.edsblt) IS NOT NULL THEN ' (' || TO_CHAR(TRIM(ed.edsblt)) || ')' END AS grant_subledger,
    TRIM(ed.edexpstat) AS line_status,
    CASE WHEN TRIM(ed.edpolicyex) IS NOT NULL THEN 'EXCEPTION: ' || TO_CHAR(TRIM(ed.edpolicyex)) ELSE 'OK' END AS policy_status,
    pol.prdlyallow / 100 AS policy_daily_allowance,
    pol.prrctrqd AS policy_receipt_required,
    pol.prdomrctam / 100 AS policy_receipt_threshold,
    pol.prauditamt / 100 AS policy_audit_amount
FROM params p
JOIN proddta.f20111 eh
    ON (p.report_number IS NULL OR TRIM(eh.ehexrptnum) = TRIM(p.report_number))
   AND (p.employee_an8 IS NULL OR eh.ehemployid = TO_NUMBER(p.employee_an8))
   AND (p.start_date IS NULL OR eh.ehdatesub >= TO_NUMBER(TO_CHAR(TO_DATE(p.start_date, 'YYYY-MM-DD'), 'YYYYDDD')) - 1900000)
   AND (p.end_date IS NULL OR eh.ehdatesub <= TO_NUMBER(TO_CHAR(TO_DATE(p.end_date, 'YYYY-MM-DD'), 'YYYYDDD')) - 1900000)
JOIN proddta.f20112 ed
    ON ed.edexrptnum = eh.ehexrptnum
   AND ed.edexrpttyp = eh.ehexrpttyp
   AND ed.edemployid = eh.ehemployid
LEFT JOIN proddta.f0101 emp
    ON emp.aban8 = eh.ehemployid
OUTER APPLY (
    SELECT pr.prdlyallow, pr.prrctrqd, pr.prdomrctam, pr.prauditamt
    FROM proddta.f09e108 pr
    WHERE pr.prpolicy = eh.ehpolicy
      AND pr.prexptype = ed.edexptype
      AND pr.preftj <= ed.edexpdate
      AND (pr.prexdj = 0 OR pr.prexdj >= ed.edexpdate)
      AND (TRIM(pr.prlocatn) IS NULL OR pr.prlocatn = ed.edlocatn)
    ORDER BY CASE WHEN TRIM(pr.prlocatn) IS NULL THEN 1 ELSE 0 END, pr.preftj DESC
    FETCH FIRST 1 ROWS ONLY
) pol
ORDER BY eh.ehexrptnum, ed.edlin
FETCH FIRST 500 ROWS ONLY;
