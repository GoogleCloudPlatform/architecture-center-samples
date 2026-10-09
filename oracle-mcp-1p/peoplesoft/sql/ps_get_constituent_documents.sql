-- Tool: ps_get_constituent_documents
-- Skill: document_intake_cleanup_and_validation
-- Oracle Bind Variables:
--   :intake_trans_id (string): Intake transaction or tracking identifier.
--   :emplid (string): Applicant or constituent EMPLID.
--   :item_code (string): Specific verification checklist item code.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :intake_trans_id AS intake_trans_id,
        :emplid AS emplid,
        :item_code AS item_code
    FROM dual
)
SELECT
    doc.scc_intake_trans_id AS intake_transaction_id,
    doc.emplid,
    doc.document_category,
    chk.chklst_item_cd AS verification_item_code,
    chk.item_status AS verification_status,
    att.attachsysfilename,
    att.attachuserfile AS file_name,
    att.file_type AS mime_type,
    att.file_size
FROM params p
JOIN sysadm.ps_scc_att_doc doc
    ON (p.intake_trans_id IS NULL OR doc.scc_intake_trans_id = p.intake_trans_id)
   AND (p.emplid IS NULL OR doc.emplid = p.emplid)
JOIN sysadm.ps_attachment_tbl att
    ON doc.attachsysfilename = att.attachsysfilename
LEFT JOIN sysadm.ps_checklist_item chk
    ON doc.emplid = chk.common_id
   AND (p.item_code IS NULL OR chk.chklst_item_cd = p.item_code);
