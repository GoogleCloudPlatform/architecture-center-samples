-- Tool: ps_search_policy_documents
-- Skill: policy_and_statute_assistant
-- Oracle Bind Variables:
--   :search_text (string): Search keyword or policy title.
--   :portal_folder (string): Portal folder or repository taxonomy branch.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :search_text AS search_text,
        :portal_folder AS portal_folder
    FROM dual
)
SELECT
    cnt.portal_objname AS document_id,
    cnt.portal_label AS policy_title,
    cnt.portal_folder_name AS folder_name,
    pub.descr AS policy_summary,
    pub.eff_status AS policy_status,
    TO_CHAR(pub.effdt, 'YYYY-MM-DD') AS effective_date,
    att.attachsysfilename,
    att.attachuserfile AS file_name
FROM params p
JOIN sysadm.ps_portal_content cnt
    ON (p.portal_folder IS NULL OR cnt.portal_folder_name = p.portal_folder)
   AND (p.search_text IS NULL OR UPPER(cnt.portal_label) LIKE UPPER('%' || p.search_text || '%'))
LEFT JOIN sysadm.ps_ep_pub_doc pub
    ON cnt.portal_objname = pub.portal_objname
LEFT JOIN sysadm.ps_attachment_tbl att
    ON cnt.portal_objname = att.attachsysfilename
ORDER BY pub.effdt DESC
FETCH FIRST 20 ROWS ONLY;
