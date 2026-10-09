-- Tool: ps_hcm_get_person_documents
-- Skill: ps_hcm_document_intake_cleanup_and_validation
-- Oracle Bind Variables:
--   :emplid (string): Person (EMPLID) whose documents and checklists are wanted. Required.
--   :kind (string): ATTACHMENT, CHECKLIST, or empty for both.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :emplid AS emplid,
        :kind AS kind
    FROM dual
)
SELECT * FROM (
    SELECT
        'ATTACHMENT' AS record_kind,
        a.source_record,
        a.emplid,
        TO_CHAR(a.seq_nbr) AS item_code,
        a.hr_att_subject AS title,
        a.hr_att_type AS document_type,
        a.attachuserfile AS file_name,
        a.attachsysfilename,
        TO_CHAR(a.created_dttm, 'YYYY-MM-DD HH24:MI:SS') AS item_date,
        a.status,
        (SELECT SUM(f.file_size) FROM sysadm.ps_hr_att_files f WHERE f.attachsysfilename = a.attachsysfilename) AS file_bytes
    FROM params p
    JOIN (
        SELECT 'GP_ABS_ATTACH' AS source_record, emplid, seq_nbr, hr_att_subject, hr_att_type, attachuserfile, attachsysfilename, created_dttm, status
          FROM sysadm.ps_gp_abs_attach
        UNION ALL
        SELECT 'HR_PER_BIOG_ATT', emplid, seq_nbr, hr_att_subject, hr_att_type, attachuserfile, attachsysfilename, created_dttm, status
          FROM sysadm.ps_hr_per_biog_att
        UNION ALL
        SELECT 'BEN_ATTACH_DTL', emplid, seq_nbr, hr_att_subject, hr_att_type, attachuserfile, attachsysfilename, created_dttm, status
          FROM sysadm.ps_ben_attach_dtl
    ) a
        ON a.emplid = p.emplid
       AND (p.kind IS NULL OR UPPER(p.kind) = 'ATTACHMENT')
    UNION ALL
    SELECT
        'CHECKLIST' AS record_kind,
        'PER_CHECKLIST' AS source_record,
        pc.emplid,
        pc.checklist_cd AS item_code,
        ct.descr AS title,
        ct.checklist_type AS document_type,
        CAST(NULL AS VARCHAR2(200)) AS file_name,
        CAST(NULL AS VARCHAR2(200)) AS attachsysfilename,
        TO_CHAR(pc.checklist_dt, 'YYYY-MM-DD') AS item_date,
        ct.eff_status AS status,
        CAST(NULL AS NUMBER) AS file_bytes
    FROM params p
    JOIN sysadm.ps_per_checklist pc
        ON pc.emplid = p.emplid
       AND (p.kind IS NULL OR UPPER(p.kind) = 'CHECKLIST')
    LEFT JOIN sysadm.ps_checklist_tbl ct
        ON ct.checklist_cd = pc.checklist_cd
       AND ct.effdt = (SELECT MAX(ct2.effdt) FROM sysadm.ps_checklist_tbl ct2
                        WHERE ct2.checklist_cd = ct.checklist_cd AND ct2.effdt <= TRUNC(SYSDATE))
    ORDER BY 9 DESC
)
WHERE ROWNUM <= 200;
