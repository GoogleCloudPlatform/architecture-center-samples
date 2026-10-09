-- Tool: ps_get_strategic_sourcing_event
-- Skill: rfp_vendor_evaluation_scorer
-- Oracle Bind Variables:
--   :business_unit (string): Procurement Business Unit code.
--   :event_id (string): Strategic Sourcing Event ID (PS_AUC_EVENT_HDR.AUC_EVENT_ID).
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :business_unit AS business_unit,
        :event_id AS event_id
    FROM dual
)
SELECT
    hdr.business_unit,
    hdr.auc_event_id AS event_id,
    hdr.descr AS event_description,
    hdr.event_status,
    TO_CHAR(hdr.start_dt, 'YYYY-MM-DD HH24:MI:SS') AS start_date,
    TO_CHAR(hdr.end_dt, 'YYYY-MM-DD HH24:MI:SS') AS close_date,
    line.line_nbr,
    line.descr AS item_description,
    line.qty_requested,
    line.unit_of_measure,
    crit.crit_id AS criteria_id,
    crit.descr AS criteria_description,
    crit.weighting_pct,
    doc.doc_type AS required_document_type
FROM params p
JOIN sysadm.ps_auc_event_hdr hdr
    ON hdr.business_unit = p.business_unit
   AND hdr.auc_event_id = p.event_id
JOIN sysadm.ps_auc_evnt_line line
    ON hdr.business_unit = line.business_unit
   AND hdr.auc_event_id = line.auc_event_id
LEFT JOIN sysadm.ps_auc_criteria crit
    ON hdr.business_unit = crit.business_unit
   AND hdr.auc_event_id = crit.auc_event_id
LEFT JOIN sysadm.ps_auc_rqd_doc doc
    ON hdr.business_unit = doc.business_unit
   AND hdr.auc_event_id = doc.auc_event_id
ORDER BY line.line_nbr, crit.crit_id;
