-- Tool: ps_get_employee_record_documents
-- Skill: redaction_and_foia_compliance
-- Oracle Bind Variables:
--   :emplid (string): Employee ID (EMPLID).
--   :document_type (string): Document category filter (e.g., DISCIPLINARY, PAYCHECK, PERFORMANCE).
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :emplid AS emplid,
        :document_type AS document_type
    FROM dual
)
SELECT
    nm.emplid,
    nm.name_display AS employee_name,
    nid.national_id AS ssn_tax_id,
    disc.incident_dt AS disciplinary_date,
    disc.descr AS disciplinary_description,
    griev.grievance_dt AS grievance_date,
    griev.descr AS grievance_description,
    pay.check_dt AS paycheck_date,
    pay.total_gross AS gross_pay,
    pay.net_pay,
    hratt.document_id,
    hratt.descr AS document_title,
    hratt.attachsysfilename
FROM params p
JOIN sysadm.ps_names nm
    ON nm.emplid = p.emplid
   AND nm.name_type = 'PRI'
JOIN sysadm.ps_pers_nid nid
    ON nm.emplid = nid.emplid
   AND nid.primary_nid = 'Y'
LEFT JOIN sysadm.ps_disciplinary disc
    ON nm.emplid = disc.emplid
LEFT JOIN sysadm.ps_grievance griev
    ON nm.emplid = griev.emplid
LEFT JOIN sysadm.ps_pay_check pay
    ON nm.emplid = pay.emplid
LEFT JOIN sysadm.ps_hr_att_data hratt
    ON nm.emplid = hratt.emplid
   AND (p.document_type IS NULL OR UPPER(hratt.descr) LIKE UPPER('%' || p.document_type || '%'));
