-- Tool: jde_get_voucher_match
-- Skill: expense_auditor
-- Oracle Bind Variables:
--   :voucher_number (string): A/P voucher document number (F0411.RPDOC).
--   :company (string): Optional voucher document company (F0411.RPKCO), e.g. '00001'.
--   :po_number (string): Purchase order number the voucher was matched to (F43121.PRDOCO).
--   :supplier_invoice (string): Supplier invoice number on the voucher (F0411.RPVINV).
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :voucher_number AS voucher_number,
        :company AS company,
        :po_number AS po_number,
        :supplier_invoice AS supplier_invoice
    FROM dual
)
-- At least one of voucher_number, po_number or supplier_invoice is required.
-- Receipts (match type 1) are summed per PO line; the voucher match row (match type 2)
-- carries the quantity and amount vouchered against that line.
SELECT
    rp.rpdoc AS voucher_number,
    rp.rpdct AS voucher_type,
    rp.rpkco AS company,
    rp.rpsfx AS pay_item,
    rp.rpan8 AS supplier_an8,
    TRIM(sup.abalph) AS supplier_name,
    TRIM(rp.rpvinv) AS supplier_invoice,
    CASE WHEN rp.rpdivj > 0 THEN TO_CHAR(TO_DATE(TO_CHAR(rp.rpdivj + 1900000), 'YYYYDDD'), 'YYYY-MM-DD') END AS invoice_date,
    CASE WHEN rp.rpdgj > 0 THEN TO_CHAR(TO_DATE(TO_CHAR(rp.rpdgj + 1900000), 'YYYYDDD'), 'YYYY-MM-DD') END AS gl_date,
    rp.rpag / 100 AS pay_item_gross_amount,
    rp.rpaap / 100 AS pay_item_open_amount,
    rp.rppst AS pay_status,
    mt.prdoco AS po_number,
    mt.prdcto AS po_type,
    mt.prlnid / 1000 AS po_line_number,
    TRIM(mt.prlitm) AS item_number,
    pd.pduorg AS quantity_ordered,
    pd.pdprrc / 10000 AS po_unit_cost,
    pd.pdaexp / 100 AS po_line_amount,
    rc.qty_received AS quantity_received,
    rc.amt_received / 100 AS amount_received,
    mt.prurec AS quantity_vouchered,
    mt.prarec / 100 AS amount_vouchered,
    (NVL(mt.prarec, 0) - NVL(rc.amt_received, 0)) / 100 AS match_variance,
    CASE
        WHEN mt.prdoco IS NULL THEN 'NOT_PO_MATCHED'
        WHEN rc.qty_received IS NULL THEN 'NO_RECEIPT'
        WHEN mt.prarec > rc.amt_received THEN 'BILLED_OVER_RECEIVED'
        WHEN rc.qty_received > pd.pduorg THEN 'RECEIVED_OVER_ORDERED'
        ELSE 'MATCHED'
    END AS three_way_match_status,
    TRIM(mt.prani) AS gl_account,
    NVL(TRIM(mt.promcu), TRIM(mt.prmcu)) AS grant_or_project_business_unit,
    TRIM(bu.mcdl01) AS grant_or_project_name,
    TO_CHAR(TRIM(mt.prsbl)) || CASE WHEN TRIM(mt.prsblt) IS NOT NULL THEN ' (' || TO_CHAR(TRIM(mt.prsblt)) || ')' END AS grant_subledger
FROM params p
JOIN proddta.f0411 rp
    ON (p.voucher_number IS NULL OR rp.rpdoc = TO_NUMBER(p.voucher_number))
   AND (p.company IS NULL OR rp.rpkco = LPAD(p.company, 5, '0'))
   AND (p.supplier_invoice IS NULL OR UPPER(TRIM(rp.rpvinv)) = UPPER(TRIM(p.supplier_invoice)))
LEFT JOIN proddta.f43121 mt
    ON mt.prmatc = '2'
   AND mt.prdoc = rp.rpdoc
   AND mt.prdct = rp.rpdct
   AND mt.prkco = rp.rpkco
   AND mt.prsfx = rp.rpsfx
LEFT JOIN proddta.f4311 pd
    ON pd.pddoco = mt.prdoco
   AND pd.pddcto = mt.prdcto
   AND pd.pdkcoo = mt.prkcoo
   AND pd.pdsfxo = mt.prsfxo
   AND pd.pdlnid = mt.prlnid
LEFT JOIN (
    SELECT prdoco, prdcto, prkcoo, prsfxo, prlnid,
           SUM(prurec) AS qty_received,
           SUM(prarec) AS amt_received
    FROM proddta.f43121
    WHERE prmatc = '1'
    GROUP BY prdoco, prdcto, prkcoo, prsfxo, prlnid
) rc
    ON rc.prdoco = mt.prdoco
   AND rc.prdcto = mt.prdcto
   AND rc.prkcoo = mt.prkcoo
   AND rc.prsfxo = mt.prsfxo
   AND rc.prlnid = mt.prlnid
LEFT JOIN proddta.f0101 sup
    ON sup.aban8 = rp.rpan8
LEFT JOIN proddta.f0006 bu
    ON bu.mcmcu = CASE WHEN TRIM(mt.promcu) IS NOT NULL THEN mt.promcu ELSE mt.prmcu END
WHERE COALESCE(p.voucher_number, p.po_number, p.supplier_invoice) IS NOT NULL
  AND (p.po_number IS NULL OR mt.prdoco = TO_NUMBER(p.po_number))
ORDER BY rp.rpdoc, rp.rpsfx, mt.prlnid;
