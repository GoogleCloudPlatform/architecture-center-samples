-- Tool: ps_get_case_determination
-- Skill: plain_language_notice_generator
-- Oracle Bind Variables:
--   :emplid (string): Constituent or Student Employee ID (EMPLID).
--   :account_id (string): Sub-account or billing account identifier.
--   :item_nbr (string): Specific item or transaction sequence number.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :emplid AS emplid,
        :account_id AS account_id,
        :item_nbr AS item_nbr
    FROM dual
)
SELECT
    sf.common_id AS emplid,
    nm.name_display AS constituent_name,
    sf.account_nbr,
    sf.item_nbr,
    sf.item_type,
    sf.item_amt AS determination_amount,
    sf.applied_amt,
    (sf.item_amt - sf.applied_amt) AS balance_due,
    sf.item_status,
    line.line_seq_nbr,
    line.descr AS statutory_line_description,
    TO_CHAR(sf.posted_date, 'YYYY-MM-DD') AS determination_date
FROM params p
JOIN sysadm.ps_item_sf sf
    ON sf.common_id = p.emplid
   AND (p.account_id IS NULL OR sf.account_nbr = p.account_id)
   AND (p.item_nbr IS NULL OR sf.item_nbr = p.item_nbr)
JOIN sysadm.ps_item_line_sf line
    ON sf.business_unit = line.business_unit
   AND sf.common_id = line.common_id
   AND sf.item_nbr = line.item_nbr
JOIN sysadm.ps_account_sf acct
    ON sf.business_unit = acct.business_unit
   AND sf.common_id = acct.common_id
   AND sf.account_nbr = acct.account_nbr
JOIN sysadm.ps_names nm
    ON sf.common_id = nm.emplid
   AND nm.name_type = 'PRI'
ORDER BY sf.item_nbr, line.line_seq_nbr;
