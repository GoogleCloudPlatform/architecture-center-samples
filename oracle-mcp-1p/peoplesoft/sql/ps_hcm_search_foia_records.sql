-- Tool: ps_hcm_search_foia_records
-- Skill: ps_hcm_redaction_and_foia_compliance
-- Oracle Bind Variables:
--   :search_keyword (string): Name, ID or title text to find (case-insensitive). Empty = no text filter, but then a category is required.
--   :category (string): PERSON, DISCIPLINE, GRIEVANCE, TRAINING, VENDOR, or ALL. Empty = all, but then a keyword is required.
--   :start_date (string): Earliest record date (YYYY-MM-DD). Empty = no lower bound; person records have no date and are left out when a date is given.
--   :end_date (string): Latest record date (YYYY-MM-DD). Empty = no upper bound.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :search_keyword AS search_keyword,
        :category AS category,
        :start_date AS start_date,
        :end_date AS end_date
    FROM dual
),
nm AS (
    SELECT n.emplid, n.name_display
    FROM sysadm.ps_names n
    WHERE n.name_type = 'PRI'
      AND n.effdt = (SELECT MAX(n2.effdt) FROM sysadm.ps_names n2
                      WHERE n2.emplid = n.emplid AND n2.name_type = n.name_type AND n2.effdt <= TRUNC(SYSDATE))
)
SELECT * FROM (
    SELECT
        'PERSON' AS record_category,
        nm.emplid AS reference_id,
        nm.name_display AS party_name,
        'Personnel record' AS record_title,
        CAST(NULL AS VARCHAR2(10)) AS record_date
    FROM params p
    JOIN nm
        ON (p.search_keyword IS NOT NULL OR p.category IS NOT NULL)
       AND (p.category IS NULL OR UPPER(p.category) IN ('PERSON', 'ALL'))
       AND p.start_date IS NULL AND p.end_date IS NULL
       AND (p.search_keyword IS NULL OR nm.emplid = p.search_keyword
            OR UPPER(nm.name_display) LIKE '%' || UPPER(p.search_keyword) || '%')
    UNION ALL
    SELECT
        'DISCIPLINE',
        d.emplid || '/' || TO_CHAR(d.discipline_dt, 'YYYYMMDD'),
        nm.name_display,
        'Disciplinary action: ' || d.disciplinary_type,
        TO_CHAR(d.discipline_dt, 'YYYY-MM-DD')
    FROM params p
    JOIN sysadm.ps_disciplin_actn d
        ON (p.search_keyword IS NOT NULL OR p.category IS NOT NULL)
       AND (p.category IS NULL OR UPPER(p.category) IN ('DISCIPLINE', 'ALL'))
       AND (p.start_date IS NULL OR d.discipline_dt >= TO_DATE(p.start_date, 'YYYY-MM-DD'))
       AND (p.end_date IS NULL OR d.discipline_dt <= TO_DATE(p.end_date, 'YYYY-MM-DD'))
    LEFT JOIN nm ON nm.emplid = d.emplid
    WHERE p.search_keyword IS NULL OR d.emplid = p.search_keyword
       OR UPPER(nm.name_display) LIKE '%' || UPPER(p.search_keyword) || '%'
       OR UPPER(d.disciplinary_type) LIKE '%' || UPPER(p.search_keyword) || '%'
    UNION ALL
    SELECT
        'GRIEVANCE',
        g.grievance_id,
        nm.name_display,
        'Grievance: ' || g.grievance_type,
        TO_CHAR(g.grievance_dt, 'YYYY-MM-DD')
    FROM params p
    JOIN sysadm.ps_grievance g
        ON (p.search_keyword IS NOT NULL OR p.category IS NOT NULL)
       AND (p.category IS NULL OR UPPER(p.category) IN ('GRIEVANCE', 'ALL'))
       AND (p.start_date IS NULL OR g.grievance_dt >= TO_DATE(p.start_date, 'YYYY-MM-DD'))
       AND (p.end_date IS NULL OR g.grievance_dt <= TO_DATE(p.end_date, 'YYYY-MM-DD'))
    LEFT JOIN nm ON nm.emplid = g.emplid
    WHERE p.search_keyword IS NULL OR g.grievance_id = p.search_keyword OR g.emplid = p.search_keyword
       OR UPPER(nm.name_display) LIKE '%' || UPPER(p.search_keyword) || '%'
       OR UPPER(g.grievance_type) LIKE '%' || UPPER(p.search_keyword) || '%'
    UNION ALL
    SELECT
        'TRAINING',
        tr.emplid || '/' || tr.course || '/' || TO_CHAR(tr.course_start_dt, 'YYYYMMDD'),
        nm.name_display,
        'Training: ' || tr.course_title,
        TO_CHAR(tr.course_start_dt, 'YYYY-MM-DD')
    FROM params p
    JOIN sysadm.ps_training tr
        ON (p.search_keyword IS NOT NULL OR p.category IS NOT NULL)
       AND (p.category IS NULL OR UPPER(p.category) IN ('TRAINING', 'ALL'))
       AND (p.start_date IS NULL OR tr.course_start_dt >= TO_DATE(p.start_date, 'YYYY-MM-DD'))
       AND (p.end_date IS NULL OR tr.course_start_dt <= TO_DATE(p.end_date, 'YYYY-MM-DD'))
    LEFT JOIN nm ON nm.emplid = tr.emplid
    WHERE p.search_keyword IS NULL OR tr.emplid = p.search_keyword
       OR UPPER(nm.name_display) LIKE '%' || UPPER(p.search_keyword) || '%'
       OR UPPER(tr.course_title) LIKE '%' || UPPER(p.search_keyword) || '%'
    UNION ALL
    SELECT
        'VENDOR',
        v.setid || '/' || v.vendor_id,
        v.name1,
        'Vendor record',
        TO_CHAR(v.last_activity_dt, 'YYYY-MM-DD')
    FROM params p
    JOIN sysadm.ps_vendor v
        ON (p.search_keyword IS NOT NULL OR p.category IS NOT NULL)
       AND (p.category IS NULL OR UPPER(p.category) IN ('VENDOR', 'ALL'))
       AND (p.start_date IS NULL OR v.last_activity_dt >= TO_DATE(p.start_date, 'YYYY-MM-DD'))
       AND (p.end_date IS NULL OR v.last_activity_dt <= TO_DATE(p.end_date, 'YYYY-MM-DD'))
       AND (p.search_keyword IS NULL OR v.vendor_id = p.search_keyword
            OR UPPER(v.name1) LIKE '%' || UPPER(p.search_keyword) || '%')
    ORDER BY 5 DESC NULLS LAST, 3
)
WHERE ROWNUM <= 100;
