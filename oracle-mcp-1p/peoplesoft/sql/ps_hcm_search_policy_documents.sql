-- Tool: ps_hcm_search_policy_documents
-- Skill: ps_hcm_policy_and_statute_assistant
-- Oracle Bind Variables:
--   :search_text (string): Text to find in the title, description or instructions (case-insensitive). Empty = no text filter.
--   :source (string): CHECKLIST_ITEM (checklist item instructions), ATTACHMENT_CONFIG (HR attachment types and their stock documents), or empty for both.
--   :as_of_date (string): Date the entries must be in force on (YYYY-MM-DD). Empty = today.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :search_text AS search_text,
        :source AS source,
        :as_of_date AS as_of_date
    FROM dual
)
SELECT * FROM (
    SELECT
        'CHECKLIST_ITEM' AS source,
        i.chklst_item_cd AS document_id,
        i.descr AS title,
        DBMS_LOB.SUBSTR(i.descrlong, 1000, 1) AS summary,
        i.eff_status AS status,
        TO_CHAR(i.effdt, 'YYYY-MM-DD') AS effective_date,
        CAST(NULL AS VARCHAR2(200)) AS file_name,
        CAST(NULL AS VARCHAR2(200)) AS attachsysfilename
    FROM params p
    JOIN sysadm.ps_chklst_item_tbl i
        ON (p.source IS NULL OR UPPER(p.source) = 'CHECKLIST_ITEM')
       AND (p.search_text IS NULL
            OR UPPER(i.descr) LIKE '%' || UPPER(p.search_text) || '%'
            OR UPPER(DBMS_LOB.SUBSTR(i.descrlong, 2000, 1)) LIKE '%' || UPPER(p.search_text) || '%')
       AND i.effdt = (SELECT MAX(i2.effdt) FROM sysadm.ps_chklst_item_tbl i2
                       WHERE i2.chklst_item_cd = i.chklst_item_cd
                         AND i2.effdt <= NVL(TO_DATE(p.as_of_date, 'YYYY-MM-DD'), TRUNC(SYSDATE)))
    UNION ALL
    SELECT
        'ATTACHMENT_CONFIG' AS source,
        c.hr_att_cnfg_id AS document_id,
        c.descr AS title,
        DBMS_LOB.SUBSTR(c.comments, 1000, 1) AS summary,
        c.eff_status AS status,
        TO_CHAR(c.effdt, 'YYYY-MM-DD') AS effective_date,
        c.attachuserfile AS file_name,
        c.attachsysfilename AS attachsysfilename
    FROM params p
    JOIN sysadm.ps_hr_att_cnfg_tbl c
        ON (p.source IS NULL OR UPPER(p.source) = 'ATTACHMENT_CONFIG')
       AND (p.search_text IS NULL
            OR UPPER(c.descr) LIKE '%' || UPPER(p.search_text) || '%'
            OR UPPER(DBMS_LOB.SUBSTR(c.comments, 2000, 1)) LIKE '%' || UPPER(p.search_text) || '%')
       AND c.effdt = (SELECT MAX(c2.effdt) FROM sysadm.ps_hr_att_cnfg_tbl c2
                       WHERE c2.hr_att_cnfg_id = c.hr_att_cnfg_id
                         AND c2.effdt <= NVL(TO_DATE(p.as_of_date, 'YYYY-MM-DD'), TRUNC(SYSDATE)))
    ORDER BY 6 DESC, 3
)
WHERE ROWNUM <= 50;
