-- Tool: ps_hcm_get_employee_record_documents
-- Skill: ps_hcm_redaction_and_foia_compliance
-- Oracle Bind Variables:
--   :emplid (string): Employee ID whose record is wanted. Required.
--   :document_type (string): IDENTITY, DISCIPLINE, GRIEVANCE, PAYCHECK, ABSENCE, ATTACHMENT, or empty for all.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :emplid AS emplid,
        :document_type AS document_type
    FROM dual
),
nm AS (
    SELECT n.emplid, n.name_display
    FROM sysadm.ps_names n
    WHERE n.name_type = 'PRI'
      AND n.effdt = (SELECT MAX(n2.effdt) FROM sysadm.ps_names n2
                      WHERE n2.emplid = n.emplid AND n2.name_type = n.name_type AND n2.effdt <= TRUNC(SYSDATE))
)
SELECT * FROM (
    SELECT
        'IDENTITY' AS record_type,
        nm.emplid AS record_key,
        CAST(NULL AS VARCHAR2(10)) AS record_date,
        nm.name_display AS title,
        (SELECT n.national_id_type || ' ending ' || SUBSTR(n.national_id, -4)
           FROM sysadm.ps_pers_nid n
          WHERE n.emplid = nm.emplid AND n.primary_nid = 'Y' AND ROWNUM = 1) AS detail,
        CAST(NULL AS NUMBER) AS amount1,
        CAST(NULL AS NUMBER) AS amount2
    FROM params p
    JOIN nm ON nm.emplid = p.emplid AND (p.document_type IS NULL OR UPPER(p.document_type) = 'IDENTITY')
    UNION ALL
    SELECT
        'DISCIPLINE', d.emplid || '/' || TO_CHAR(d.discipline_dt, 'YYYYMMDD'), TO_CHAR(d.discipline_dt, 'YYYY-MM-DD'),
        d.disciplinary_type, d.final_resolution, CAST(NULL AS NUMBER), CAST(NULL AS NUMBER)
    FROM params p
    JOIN sysadm.ps_disciplin_actn d ON d.emplid = p.emplid AND (p.document_type IS NULL OR UPPER(p.document_type) = 'DISCIPLINE')
    UNION ALL
    SELECT
        'GRIEVANCE', g.grievance_id, TO_CHAR(g.grievance_dt, 'YYYY-MM-DD'),
        g.grievance_type, g.grievance_status || ' / ' || g.final_resolution, CAST(NULL AS NUMBER), CAST(NULL AS NUMBER)
    FROM params p
    JOIN sysadm.ps_grievance g ON g.emplid = p.emplid AND (p.document_type IS NULL OR UPPER(p.document_type) = 'GRIEVANCE')
    UNION ALL
    SELECT * FROM (
        SELECT
            'PAYCHECK', TO_CHAR(c.paycheck_nbr), TO_CHAR(c.check_dt, 'YYYY-MM-DD'),
            'Paycheck ' || c.company || '/' || c.paygroup, c.paycheck_status, c.total_gross, c.net_pay
        FROM params p
        JOIN sysadm.ps_pay_check c ON c.emplid = p.emplid AND (p.document_type IS NULL OR UPPER(p.document_type) = 'PAYCHECK')
        ORDER BY c.check_dt DESC
    ) WHERE ROWNUM <= 12
    UNION ALL
    SELECT
        'ABSENCE', TO_CHAR(a.begin_dt, 'YYYYMMDD') || '/' || a.absence_type, TO_CHAR(a.begin_dt, 'YYYY-MM-DD'),
        a.absence_type || ' ' || a.absence_code, a.paid_unpaid, a.duration_days, a.duration_hours
    FROM params p
    JOIN sysadm.ps_absence_hist a ON a.emplid = p.emplid AND (p.document_type IS NULL OR UPPER(p.document_type) = 'ABSENCE')
    UNION ALL
    SELECT
        'ATTACHMENT', att.source_record || '/' || att.attachsysfilename, TO_CHAR(att.created_dttm, 'YYYY-MM-DD'),
        att.hr_att_subject, att.attachuserfile, CAST(NULL AS NUMBER), CAST(NULL AS NUMBER)
    FROM params p
    JOIN (
        SELECT 'GP_ABS_ATTACH' AS source_record, emplid, hr_att_subject, attachuserfile, attachsysfilename, created_dttm FROM sysadm.ps_gp_abs_attach
        UNION ALL
        SELECT 'HR_PER_BIOG_ATT', emplid, hr_att_subject, attachuserfile, attachsysfilename, created_dttm FROM sysadm.ps_hr_per_biog_att
        UNION ALL
        SELECT 'BEN_ATTACH_DTL', emplid, hr_att_subject, attachuserfile, attachsysfilename, created_dttm FROM sysadm.ps_ben_attach_dtl
    ) att ON att.emplid = p.emplid AND (p.document_type IS NULL OR UPPER(p.document_type) = 'ATTACHMENT')
    ORDER BY 1, 3 DESC NULLS LAST
)
WHERE ROWNUM <= 300;
