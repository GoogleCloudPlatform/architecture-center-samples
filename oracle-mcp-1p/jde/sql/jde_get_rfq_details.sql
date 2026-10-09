-- Tool: jde_get_rfq_details
-- Skill: rfp_vendor_evaluation_scorer
-- Oracle Bind Variables:
--   :order_number (integer): Request for quote (quote order) number (F4301.PHDOCO).
--   :order_type (string): Optional quote order type (F4301.PHDCTO); defaults to 'OQ'.
--   :order_company (string): Optional order company (F4301.PHKCOO), e.g. '00001'.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :order_number AS order_number,
        :order_type AS order_type,
        :order_company AS order_company
    FROM dual
)
SELECT
    ph.phdoco AS rfq_number,
    ph.phdcto AS order_type,
    ph.phkcoo AS order_company,
    TRIM(ph.phdesc) AS rfq_title,
    TRIM(ph.phvr01) AS solicitation_reference,
    TRIM(ph.phrmk) AS rfq_remark,
    TRIM(TRIM(ph.phdel1) || ' ' || TRIM(ph.phdel2)) AS delivery_instructions,
    CASE WHEN ph.phtrdj > 0 THEN TO_CHAR(TO_DATE(TO_CHAR(ph.phtrdj + 1900000), 'YYYYDDD'), 'YYYY-MM-DD') END AS issue_date,
    CASE WHEN ph.phdrqj > 0 THEN TO_CHAR(TO_DATE(TO_CHAR(ph.phdrqj + 1900000), 'YYYYDDD'), 'YYYY-MM-DD') END AS requested_date,
    TRIM(ph.phmcu) AS business_unit,
    TRIM(bu.mcdl01) AS business_unit_name,
    ph.phanby AS buyer_an8,
    TRIM(buyer.abalph) AS buyer_name,
    pd.pdlnid / 1000 AS line_number,
    TRIM(pd.pdlitm) AS item_number,
    TRIM(TRIM(pd.pddsc1) || ' ' || TRIM(pd.pddsc2)) AS item_description,
    TRIM(pd.pdlnty) AS line_type,
    pd.pduorg AS quantity_requested,
    TRIM(pd.pduom) AS unit_of_measure,
    pd.pdprrc / 10000 AS estimated_unit_cost,
    pd.pdaexp / 100 AS estimated_extended_amount,
    CASE WHEN pd.pddrqj > 0 THEN TO_CHAR(TO_DATE(TO_CHAR(pd.pddrqj + 1900000), 'YYYYDDD'), 'YYYY-MM-DD') END AS line_requested_date,
    TRIM(pd.pdomcu) AS project_business_unit,
    NULLIF(TO_CHAR(TRIM(pd.pdobj) || '.' || TRIM(pd.pdsub)), '.') AS gl_object_subsidiary,
    NULLIF(TO_CHAR(TRIM(pd.pdlttr) || '/' || TRIM(pd.pdnxtr)), '/') AS line_status_last_next,
    (SELECT COUNT(*)
       FROM proddta.f4330 s
      WHERE s.p0doco = pd.pddoco AND s.p0dcto = pd.pddcto AND s.p0kcoo = pd.pdkcoo
        AND s.p0sfxo = pd.pdsfxo AND s.p0lnid = pd.pdlnid) AS suppliers_invited,
    (SELECT CASE WHEN MIN(s.p0rqqj) > 0 THEN TO_CHAR(TO_DATE(TO_CHAR(MIN(s.p0rqqj) + 1900000), 'YYYYDDD'), 'YYYY-MM-DD') END
       FROM proddta.f4330 s
      WHERE s.p0doco = pd.pddoco AND s.p0dcto = pd.pddcto AND s.p0kcoo = pd.pdkcoo
        AND s.p0sfxo = pd.pdsfxo AND s.p0lnid = pd.pdlnid) AS response_due_date
FROM params p
JOIN proddta.f4301 ph
    ON ph.phdoco = p.order_number
   AND ph.phdcto = NVL(UPPER(p.order_type), 'OQ')
   AND (p.order_company IS NULL OR ph.phkcoo = LPAD(p.order_company, 5, '0'))
JOIN proddta.f4311 pd
    ON pd.pddoco = ph.phdoco
   AND pd.pddcto = ph.phdcto
   AND pd.pdkcoo = ph.phkcoo
   AND pd.pdsfxo = ph.phsfxo
LEFT JOIN proddta.f0006 bu
    ON bu.mcmcu = ph.phmcu
LEFT JOIN proddta.f0101 buyer
    ON buyer.aban8 = ph.phanby
ORDER BY pd.pdlnid;
