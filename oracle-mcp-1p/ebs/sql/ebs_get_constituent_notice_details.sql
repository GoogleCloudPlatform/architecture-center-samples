-- Tool: ebs_get_constituent_notice_details
-- Skill: plain_language_notice_generator
-- Oracle Bind Variables:
--   :transaction_id (string): Customer transaction ID or transaction number (e.g., Claim / Determination ID).
--   :org_id (string): Operating unit ID. Empty string = any operating unit.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :transaction_id AS transaction_id,
        :org_id AS org_id
    FROM dual
)
-- Balances are summed over the transaction's payment schedules (installments), and the
-- award is the one whose award project billed this invoice (Grants invoices carry the
-- project number in INTERFACE_HEADER_ATTRIBUTE1), so each invoice line is one row.
SELECT
    trx.customer_trx_id,
    trx.trx_number,
    TO_CHAR(trx.trx_date, 'YYYY-MM-DD') AS notice_date,
    trx.org_id,
    party.party_name AS constituent_name,
    cust.account_number,
    lines.line_number,
    lines.line_type,
    lines.description AS statutory_description,
    lines.extended_amount AS line_amount,
    lines.reason_code,
    rsn.meaning AS reason_meaning,
    sched.amount_due_original AS total_overpayment_amount,
    sched.amount_due_remaining AS outstanding_balance,
    sched.payment_status,
    sched.installment_count,
    gms.award_number,
    gms.award_full_name AS award_name
FROM params p
JOIN apps.ra_customer_trx_all trx
    ON (TO_CHAR(trx.customer_trx_id) = p.transaction_id OR trx.trx_number = p.transaction_id)
   AND (p.org_id IS NULL OR trx.org_id = TO_NUMBER(p.org_id))
JOIN apps.ra_customer_trx_lines_all lines
    ON trx.customer_trx_id = lines.customer_trx_id
JOIN (
    SELECT
        customer_trx_id,
        SUM(amount_due_original) AS amount_due_original,
        SUM(amount_due_remaining) AS amount_due_remaining,
        CASE WHEN MIN(status) = MAX(status) THEN MIN(status) ELSE 'MIXED' END AS payment_status,
        COUNT(*) AS installment_count
    FROM apps.ar_payment_schedules_all
    GROUP BY customer_trx_id
) sched
    ON trx.customer_trx_id = sched.customer_trx_id
JOIN apps.hz_cust_accounts cust
    ON trx.bill_to_customer_id = cust.cust_account_id
JOIN apps.hz_parties party
    ON cust.party_id = party.party_id
LEFT JOIN apps.ar_lookups rsn
    ON rsn.lookup_type = 'INVOICING_REASON'
   AND rsn.lookup_code = lines.reason_code
LEFT JOIN apps.pa_projects_all ppa
    ON trx.interface_header_context IN ('PROJECTS INVOICES', 'PA INVOICES')
   AND ppa.segment1 = trx.interface_header_attribute1
LEFT JOIN apps.gms_awards_all gms
    ON gms.award_project_id = ppa.project_id
ORDER BY lines.line_number;
