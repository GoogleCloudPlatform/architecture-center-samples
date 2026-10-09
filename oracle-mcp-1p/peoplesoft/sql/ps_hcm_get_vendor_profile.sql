-- Tool: ps_hcm_get_vendor_profile
-- Skill: ps_hcm_rfp_vendor_evaluation_scorer
-- Oracle Bind Variables:
--   :setid (string): Vendor SetID. Empty = any.
--   :vendor_id (string): Vendor ID. Empty = any.
--   :name_pattern (string): Text to find in the vendor name (case-insensitive, matched anywhere). Empty = no name filter.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :setid AS setid,
        :vendor_id AS vendor_id,
        :name_pattern AS name_pattern
    FROM dual
),
pol AS (
    SELECT vp.setid, vp.vendor_id, COUNT(*) AS policy_count, MAX(vp.policy_end_date) AS latest_policy_end
    FROM sysadm.ps_vendor_policy vp
    GROUP BY vp.setid, vp.vendor_id
)
SELECT * FROM (
    SELECT
        v.setid,
        v.vendor_id,
        v.name1 AS vendor_name,
        v.name2 AS vendor_name_2,
        v.vendor_status,
        v.vendor_class,
        v.vendor_persistence,
        v.vndr_status_po AS purchasing_status,
        v.primary_vendor,
        v.corporate_setid,
        v.corporate_vendor,
        v.hub_zone,
        TO_CHAR(v.eeo_certif_dt, 'YYYY-MM-DD') AS eeo_certification_date,
        TO_CHAR(v.last_activity_dt, 'YYYY-MM-DD') AS last_activity_date,
        v.wthd_sw AS subject_to_withholding,
        a.address1,
        a.city,
        a.state,
        a.postal,
        a.country,
        l.pymnt_terms_cd AS payment_terms,
        l.currency_cd,
        NVL(pol.policy_count, 0) AS policy_count,
        TO_CHAR(pol.latest_policy_end, 'YYYY-MM-DD') AS latest_policy_end_date
    FROM params p
    JOIN sysadm.ps_vendor v
        ON (p.setid IS NULL OR v.setid = p.setid)
       AND (p.vendor_id IS NULL OR v.vendor_id = p.vendor_id)
       AND (p.name_pattern IS NULL
            OR UPPER(v.name1) LIKE '%' || UPPER(p.name_pattern) || '%'
            OR UPPER(v.name2) LIKE '%' || UPPER(p.name_pattern) || '%')
    LEFT JOIN sysadm.ps_vendor_addr a
        ON a.setid = v.setid
       AND a.vendor_id = v.vendor_id
       AND a.address_seq_num = v.prim_addr_seq_num
       AND a.effdt = (SELECT MAX(a2.effdt) FROM sysadm.ps_vendor_addr a2
                       WHERE a2.setid = a.setid AND a2.vendor_id = a.vendor_id
                         AND a2.address_seq_num = a.address_seq_num AND a2.effdt <= TRUNC(SYSDATE))
    LEFT JOIN sysadm.ps_vendor_loc l
        ON l.setid = v.setid
       AND l.vendor_id = v.vendor_id
       AND l.vndr_loc = v.default_loc
       AND l.effdt = (SELECT MAX(l2.effdt) FROM sysadm.ps_vendor_loc l2
                       WHERE l2.setid = l.setid AND l2.vendor_id = l.vendor_id
                         AND l2.vndr_loc = l.vndr_loc AND l2.effdt <= TRUNC(SYSDATE))
    LEFT JOIN pol
        ON pol.setid = v.setid AND pol.vendor_id = v.vendor_id
    ORDER BY v.name1
)
WHERE ROWNUM <= 50;
