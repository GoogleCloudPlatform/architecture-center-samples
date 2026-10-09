-- Tool: ebs_get_vendor_bids
-- Skill: rfp_vendor_evaluation_scorer
-- Oracle Bind Variables:
--   :auction_header_id (string): Sourcing negotiation header ID. Empty string = any negotiation (then pass bid_number or vendor_name).
--   :bid_number (string): Specific bid number (PON_BID_HEADERS.BID_NUMBER). Empty string = any.
--   :vendor_name (string): Part of the bidding vendor's name. Empty string = any.
--   :include_prices (string): 'Y' also returns bid prices and totals; anything else leaves them empty, for technical review without price.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :auction_header_id AS auction_header_id,
        :bid_number AS bid_number,
        :vendor_name AS vendor_name,
        :include_prices AS include_prices
    FROM dual
)
-- Current bids only: superseded revisions (ARCHIVED), drafts and disqualified bids are
-- excluded, and superseded_revisions counts the vendor's archived revisions on the same
-- negotiation. Attachments are listed per bid line (entity PON_BID_ITEM_PRICES) and per
-- bid (PON_BID_HEADERS), keyed by negotiation, bid and line. Award, shortlist and score
-- columns are deliberately not returned.
SELECT
    pbh.bid_number,
    pbh.auction_header_id,
    paha.document_number AS rfp_number,
    paha.amendment_number AS bid_on_amendment_number,
    pbh.vendor_id,
    pbh.trading_partner_name AS vendor_name,
    pbh.vendor_site_code,
    pbh.bid_status,
    TO_CHAR(pbh.publish_date, 'YYYY-MM-DD HH24:MI:SS') AS submitted_date,
    TO_CHAR(paha.close_bidding_date, 'YYYY-MM-DD HH24:MI:SS') AS close_date,
    CASE WHEN pbh.publish_date > paha.close_bidding_date THEN 'Y' ELSE 'N' END AS submitted_after_close,
    (SELECT COUNT(*)
       FROM apps.pon_bid_headers old
      WHERE old.auction_header_id = pbh.auction_header_id
        AND old.trading_partner_id = pbh.trading_partner_id
        AND old.bid_status = 'ARCHIVED') AS superseded_revisions,
    pbh.note_to_auction_owner AS bid_note,
    CASE WHEN UPPER(p.include_prices) = 'Y' THEN pbh.buyer_bid_total END AS total_bid_price,
    CASE WHEN UPPER(p.include_prices) = 'Y' THEN pbh.bid_currency_code END AS bid_currency_code,
    pbip.line_number,
    CASE WHEN UPPER(p.include_prices) = 'Y' THEN pbip.price END AS bid_currency_price,
    TO_CHAR(pbip.promised_date, 'YYYY-MM-DD') AS promise_date,
    pbip.note_to_auction_owner AS technical_response_summary,
    (SELECT LISTAGG(NVL(fdt.title, fd.file_name) || ' [document ' || fd.document_id || ']', '; ')
                WITHIN GROUP (ORDER BY fad.seq_num)
       FROM apps.fnd_attached_documents fad
       JOIN apps.fnd_documents fd
           ON fd.document_id = fad.document_id
       LEFT JOIN apps.fnd_documents_tl fdt
           ON fdt.document_id = fd.document_id
          AND fdt.language = USERENV('LANG')
      WHERE fad.entity_name = 'PON_BID_ITEM_PRICES'
        AND fad.pk1_value = TO_CHAR(pbh.auction_header_id)
        AND fad.pk2_value = TO_CHAR(pbh.bid_number)
        AND fad.pk3_value = TO_CHAR(pbip.line_number)) AS line_attachments,
    (SELECT LISTAGG(NVL(fdt.title, fd.file_name) || ' [document ' || fd.document_id || ']', '; ')
                WITHIN GROUP (ORDER BY fad.seq_num)
       FROM apps.fnd_attached_documents fad
       JOIN apps.fnd_documents fd
           ON fd.document_id = fad.document_id
       LEFT JOIN apps.fnd_documents_tl fdt
           ON fdt.document_id = fd.document_id
          AND fdt.language = USERENV('LANG')
      WHERE fad.entity_name = 'PON_BID_HEADERS'
        AND fad.pk1_value = TO_CHAR(pbh.auction_header_id)
        AND fad.pk2_value = TO_CHAR(pbh.bid_number)) AS bid_attachments
FROM params p
JOIN apps.pon_bid_headers pbh
    ON pbh.bid_status NOT IN ('ARCHIVED', 'DRAFT', 'DISQUALIFIED')
   AND (p.auction_header_id IS NULL OR pbh.auction_header_id = TO_NUMBER(p.auction_header_id))
   AND (p.bid_number IS NULL OR pbh.bid_number = TO_NUMBER(p.bid_number))
   AND (p.vendor_name IS NULL OR UPPER(pbh.trading_partner_name) LIKE UPPER('%' || p.vendor_name || '%'))
   AND COALESCE(p.auction_header_id, p.bid_number, p.vendor_name) IS NOT NULL
JOIN apps.pon_auction_headers_all paha
    ON paha.auction_header_id = pbh.auction_header_id
LEFT JOIN apps.pon_bid_item_prices pbip
    ON pbip.bid_number = pbh.bid_number
ORDER BY pbh.auction_header_id, pbh.bid_number, pbip.line_number
FETCH FIRST 500 ROWS ONLY;
