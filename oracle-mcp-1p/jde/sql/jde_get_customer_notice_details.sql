-- Tool: jde_get_customer_notice_details
-- Skill: plain_language_notice_generator
-- Oracle Bind Variables:
--   :doc_number (integer): A/R invoice or billing document number (F03B11.RPDOC), e.g. the claim or determination number.
--   :doc_type (string): Optional A/R document type (F03B11.RPDCT), e.g. 'RI' for invoices or 'RM' for credit memos.
--   :company (string): Optional document company (F03B11.RPKCO), e.g. '00001' or '1'.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :doc_number AS doc_number,
        :doc_type AS doc_type,
        :company AS company
    FROM dual
)
-- JDE storage conventions used below: dates are Julian CYYDDD numbers (0 = blank),
-- amounts are stored without the decimal point (2 display decimals), and codes are
-- blank-padded fixed-length strings (UDC tables are compared with TRIM).
SELECT
    rp.rpdoc AS doc_number,
    rp.rpdct AS doc_type,
    TRIM(dt.drdl01) AS doc_type_description,
    rp.rpkco AS company,
    rp.rpsfx AS pay_item,
    rp.rpan8 AS customer_an8,
    TRIM(ab.abalph) AS constituent_name,
    CASE WHEN rp.rpdivj > 0 THEN TO_CHAR(TO_DATE(TO_CHAR(rp.rpdivj + 1900000), 'YYYYDDD'), 'YYYY-MM-DD') END AS notice_date,
    CASE WHEN rp.rpddj > 0 THEN TO_CHAR(TO_DATE(TO_CHAR(rp.rpddj + 1900000), 'YYYYDDD'), 'YYYY-MM-DD') END AS due_date,
    rp.rpag / 100 AS billed_amount,
    rp.rpaap / 100 AS outstanding_balance,
    TRIM(rp.rpcrcd) AS currency_code,
    rp.rppst AS pay_status,
    TRIM(ps.drdl01) AS pay_status_description,
    TRIM(rp.rprmk) AS statutory_remark,
    TRIM(rp.rpvr01) AS reference,
    TRIM(rp.rpmcu) AS business_unit,
    TRIM(bu.mcdl01) AS program_or_grant_name,
    ded.rbdcid AS dispute_id,
    TRIM(ded.rbddex) AS dispute_reason_code,
    TRIM(ded.rbpsdd) AS dispute_status,
    ded.rbdda / 100 AS disputed_amount,
    ded.rbddoa / 100 AS disputed_open_amount,
    CASE WHEN ded.rbdddo > 0 THEN TO_CHAR(TO_DATE(TO_CHAR(ded.rbdddo + 1900000), 'YYYYDDD'), 'YYYY-MM-DD') END AS dispute_opened_date
FROM params p
JOIN proddta.f03b11 rp
    ON rp.rpdoc = p.doc_number
   AND (p.doc_type IS NULL OR rp.rpdct = UPPER(p.doc_type))
   AND (p.company IS NULL OR rp.rpkco = LPAD(p.company, 5, '0'))
LEFT JOIN proddta.f0101 ab
    ON ab.aban8 = rp.rpan8
LEFT JOIN proddta.f0006 bu
    ON bu.mcmcu = rp.rpmcu
LEFT JOIN prodctl.f0005 dt
    ON TRIM(dt.drsy) = '00'
   AND TRIM(dt.drrt) = 'DT'
   AND TRIM(dt.drky) = TRIM(rp.rpdct)
LEFT JOIN prodctl.f0005 ps
    ON TRIM(ps.drsy) = '00'
   AND TRIM(ps.drrt) = 'PS'
   AND TRIM(ps.drky) = TRIM(rp.rppst)
LEFT JOIN proddta.f03b40 ded
    ON ded.rbodoc = rp.rpdoc
   AND ded.rbodct = rp.rpdct
   AND ded.rbokco = rp.rpkco
   AND ded.rbosfx = rp.rpsfx
ORDER BY rp.rpdct, rp.rpsfx;
