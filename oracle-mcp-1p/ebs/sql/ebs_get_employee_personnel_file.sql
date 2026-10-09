-- Tool: ebs_get_employee_personnel_file
-- Skill: redaction_and_foia_compliance
-- Oracle Bind Variables:
--   :person_id (integer): Unique identifier of the employee in HRMS (PER_ALL_PEOPLE_F.PERSON_ID).
--   :employee_number (string): Agency employee badge or identification number.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :person_id AS person_id,
        :employee_number AS employee_number
    FROM dual
)
SELECT
    papf.person_id,
    papf.employee_number,
    papf.full_name,
    papf.first_name,
    papf.last_name,
    papf.national_identifier AS ssn_tax_id,
    TO_CHAR(papf.date_of_birth, 'YYYY-MM-DD') AS date_of_birth,
    paaf.assignment_number,
    paaf.job_id,
    ppr.performance_review_id,
    ppr.performance_rating,
    TO_CHAR(ppr.review_date, 'YYYY-MM-DD') AS review_date,
    paa.absence_attendance_type_id,
    TO_CHAR(paa.date_start, 'YYYY-MM-DD') AS absence_start_date,
    TO_CHAR(paa.date_end, 'YYYY-MM-DD') AS absence_end_date
FROM params p
JOIN apps.per_all_people_f papf
    ON TRUNC(SYSDATE) BETWEEN papf.effective_start_date AND papf.effective_end_date
   AND ((p.person_id IS NOT NULL AND papf.person_id = TO_NUMBER(p.person_id))
     OR (p.employee_number IS NOT NULL AND papf.employee_number = p.employee_number))
JOIN apps.per_all_assignments_f paaf
    ON papf.person_id = paaf.person_id
   AND TRUNC(SYSDATE) BETWEEN paaf.effective_start_date AND paaf.effective_end_date
LEFT JOIN apps.per_performance_reviews ppr
    ON papf.person_id = ppr.person_id
LEFT JOIN apps.per_absence_attendances paa
    ON papf.person_id = paa.person_id;
