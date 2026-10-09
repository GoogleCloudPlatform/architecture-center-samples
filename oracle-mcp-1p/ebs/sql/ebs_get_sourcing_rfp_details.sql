-- Tool: ebs_get_sourcing_rfp_details
-- Skill: rfp_vendor_evaluation_scorer
-- Oracle Bind Variables:
--   :auction_header_id (string): Sourcing negotiation header ID (PON_AUCTION_HEADERS_ALL.AUCTION_HEADER_ID). Empty string = look up by rfp_number.
--   :rfp_number (string): Solicitation document number (PON_AUCTION_HEADERS_ALL.DOCUMENT_NUMBER). Empty string = look up by auction_header_id.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :auction_header_id AS auction_header_id,
        :rfp_number AS rfp_number
    FROM dual
)
-- Lines and requirements are separate record types (record_type LINE or REQUIREMENT) so
-- they don't multiply each other. Requirements with requirement_line_number -1 apply to
-- the whole solicitation; others apply to that line.
SELECT
    paha.auction_header_id,
    paha.document_number AS rfp_number,
    dt.internal_name AS document_type,
    paha.auction_title,
    paha.auction_status,
    paha.bid_visibility_code,
    paha.amendment_number,
    paha.amendment_description,
    (SELECT MAX(a.amendment_number)
       FROM apps.pon_auction_headers_all a
      WHERE NVL(a.auction_header_id_orig_amend, a.auction_header_id) = NVL(paha.auction_header_id_orig_amend, paha.auction_header_id)
        AND a.auction_status <> 'DELETED') AS latest_amendment_number,
    TO_CHAR(paha.open_bidding_date, 'YYYY-MM-DD HH24:MI:SS') AS open_date,
    TO_CHAR(paha.close_bidding_date, 'YYYY-MM-DD HH24:MI:SS') AS close_date,
    rec.record_type,
    rec.item_line_number,
    rec.item_description,
    rec.required_quantity,
    rec.unit_of_measure,
    rec.requirement_line_number,
    rec.section_name,
    rec.scoring_criteria_id,
    rec.criteria_name,
    rec.criteria_description,
    rec.mandatory_flag,
    rec.weight_percent,
    rec.scoring_type,
    rec.scoring_method,
    rec.max_score,
    rec.knockout_score,
    rec.internal_only_flag
FROM params p
JOIN apps.pon_auction_headers_all paha
    ON (p.auction_header_id IS NOT NULL AND paha.auction_header_id = TO_NUMBER(p.auction_header_id))
    OR (p.auction_header_id IS NULL AND p.rfp_number IS NOT NULL AND paha.document_number = p.rfp_number)
LEFT JOIN apps.pon_auc_doctypes dt
    ON dt.doctype_id = paha.doctype_id
LEFT JOIN (
    SELECT
        paip.auction_header_id,
        'LINE' AS record_type,
        paip.line_number AS item_line_number,
        paip.item_description,
        paip.quantity AS required_quantity,
        paip.unit_of_measure,
        TO_NUMBER(NULL) AS requirement_line_number,
        NULL AS section_name,
        TO_NUMBER(NULL) AS scoring_criteria_id,
        NULL AS criteria_name,
        NULL AS criteria_description,
        NULL AS mandatory_flag,
        TO_NUMBER(NULL) AS weight_percent,
        NULL AS scoring_type,
        NULL AS scoring_method,
        TO_NUMBER(NULL) AS max_score,
        TO_NUMBER(NULL) AS knockout_score,
        NULL AS internal_only_flag
    FROM apps.pon_auction_item_prices_all paip
    UNION ALL
    SELECT
        paa.auction_header_id,
        'REQUIREMENT' AS record_type,
        TO_NUMBER(NULL) AS item_line_number,
        NULL AS item_description,
        TO_NUMBER(NULL) AS required_quantity,
        NULL AS unit_of_measure,
        paa.line_number AS requirement_line_number,
        paa.section_name,
        paa.sequence_number AS scoring_criteria_id,
        paa.attribute_name AS criteria_name,
        NVL(paa.description, paa.help_text) AS criteria_description,
        paa.mandatory_flag,
        paa.weight AS weight_percent,
        paa.scoring_type,
        paa.scoring_method,
        paa.attr_max_score AS max_score,
        paa.knockout_score,
        paa.internal_attr_flag AS internal_only_flag
    FROM apps.pon_auction_attributes paa
) rec
    ON rec.auction_header_id = paha.auction_header_id
ORDER BY rec.record_type, rec.item_line_number, rec.requirement_line_number, rec.section_name, rec.scoring_criteria_id;
