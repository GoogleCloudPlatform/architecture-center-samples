-- Tool: ps_get_vendor_responses
-- Skill: rfp_vendor_evaluation_scorer
-- Oracle Bind Variables:
--   :business_unit (string): Procurement Business Unit code.
--   :event_id (string): Strategic Sourcing Event ID.
--   :bidder_id (string): Specific Vendor/Bidder ID.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :business_unit AS business_unit,
        :event_id AS event_id,
        :bidder_id AS bidder_id
    FROM dual
)
SELECT
    bidhdr.business_unit,
    bidhdr.auc_event_id AS event_id,
    bidhdr.bid_id,
    bidhdr.bidder_id,
    bidhdr.bid_status,
    bidhdr.total_bid_amt,
    bidresp.line_nbr,
    bidresp.unit_price,
    bidresp.resp_descr AS technical_response,
    att.attachsysfilename,
    att.attachuserfile AS proposal_filename
FROM params p
JOIN sysadm.ps_auc_bid_hdr bidhdr
    ON bidhdr.business_unit = p.business_unit
   AND bidhdr.auc_event_id = p.event_id
   AND bidhdr.bid_status NOT IN ('SAVED', 'CANCELLED')
   AND (p.bidder_id IS NULL OR bidhdr.bidder_id = p.bidder_id)
JOIN sysadm.ps_auc_bid_resp bidresp
    ON bidhdr.business_unit = bidresp.business_unit
   AND bidhdr.auc_event_id = bidresp.auc_event_id
   AND bidhdr.bid_id = bidresp.bid_id
LEFT JOIN sysadm.ps_auc_attachment att
    ON bidhdr.business_unit = att.business_unit
   AND bidhdr.bid_id = att.bid_id
ORDER BY bidhdr.bid_id, bidresp.line_nbr;
