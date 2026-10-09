-- Tool: jde_get_supplier_quotes
-- Skill: rfp_vendor_evaluation_scorer
-- Oracle Bind Variables:
--   :order_number (integer): Request for quote (quote order) number (F4330.P0DOCO).
--   :order_type (string): Optional quote order type; defaults to 'OQ'.
--   :supplier_an8 (string): Optional supplier address number to return one supplier's responses only.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :order_number AS order_number,
        :order_type AS order_type,
        :supplier_an8 AS supplier_an8
    FROM dual
)
SELECT
    sel.p0doco AS rfq_number,
    sel.p0dcto AS order_type,
    sel.p0kcoo AS order_company,
    sel.p0lnid / 1000 AS line_number,
    TRIM(pd.pdlitm) AS item_number,
    TRIM(pd.pddsc1) AS item_description,
    pd.pduorg AS quantity_requested,
    sel.p0an8 AS supplier_an8,
    TRIM(sup.abalph) AS supplier_name,
    TRIM(sup.abduns) AS duns_number,
    TRIM(sup.abtax) AS supplier_tax_id,
    sel.p0qprt AS quote_printed_flag,
    CASE WHEN sel.p0rqqj > 0 THEN TO_CHAR(TO_DATE(TO_CHAR(sel.p0rqqj + 1900000), 'YYYYDDD'), 'YYYY-MM-DD') END AS response_due_date,
    CASE WHEN sel.p0qrdj > 0 THEN TO_CHAR(TO_DATE(TO_CHAR(sel.p0qrdj + 1900000), 'YYYYDDD'), 'YYYY-MM-DD') END AS response_date,
    CASE WHEN sel.p0qrdj > sel.p0rqqj AND sel.p0rqqj > 0 THEN 'LATE' WHEN sel.p0qrdj > 0 THEN 'ON_TIME' ELSE 'NO_RESPONSE' END AS response_timeliness,
    q.p1uorg AS quoted_quantity_break,
    q.p1prrc / 10000 AS quoted_unit_price,
    (q.p1prrc / 10000) * pd.pduorg AS quoted_extended_price,
    TRIM(q.p1crcd) AS currency_code,
    CASE WHEN q.p1pddj > 0 THEN TO_CHAR(TO_DATE(TO_CHAR(q.p1pddj + 1900000), 'YYYYDDD'), 'YYYY-MM-DD') END AS promised_date,
    CASE WHEN q.p1cndj > 0 THEN TO_CHAR(TO_DATE(TO_CHAR(q.p1cndj + 1900000), 'YYYYDDD'), 'YYYY-MM-DD') END AS quote_valid_until,
    sel.p0urel AS units_released,
    sel.p0arel / 100 AS amount_released
FROM params p
JOIN proddta.f4330 sel
    ON sel.p0doco = p.order_number
   AND sel.p0dcto = NVL(UPPER(p.order_type), 'OQ')
   AND (p.supplier_an8 IS NULL OR sel.p0an8 = TO_NUMBER(p.supplier_an8))
JOIN proddta.f4311 pd
    ON pd.pddoco = sel.p0doco
   AND pd.pddcto = sel.p0dcto
   AND pd.pdkcoo = sel.p0kcoo
   AND pd.pdsfxo = sel.p0sfxo
   AND pd.pdlnid = sel.p0lnid
LEFT JOIN proddta.f4331 q
    ON q.p1doco = sel.p0doco
   AND q.p1dcto = sel.p0dcto
   AND q.p1kcoo = sel.p0kcoo
   AND q.p1sfxo = sel.p0sfxo
   AND q.p1lnid = sel.p0lnid
   AND q.p1an8 = sel.p0an8
LEFT JOIN proddta.f0101 sup
    ON sup.aban8 = sel.p0an8
ORDER BY sel.p0lnid, quoted_unit_price NULLS LAST, sel.p0an8;
