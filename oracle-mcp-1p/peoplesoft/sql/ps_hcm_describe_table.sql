-- Tool: ps_hcm_describe_table
-- Skill: ps_hcm_schema_discovery_and_lovs
-- Oracle Bind Variables:
--   :table_name (string): Record or table name to describe (for example PS_JOB or JOB). Empty = list tables by pattern instead.
--   :name_pattern (string): Pattern for listing tables when table_name is empty (for example %CHECKLIST%). Case-insensitive; % is the wildcard.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :table_name AS table_name,
        :name_pattern AS name_pattern
    FROM dual
)
SELECT * FROM (
    SELECT
        'COLUMN' AS kind,
        c.table_name,
        c.column_id AS position,
        c.column_name,
        c.data_type,
        c.data_length,
        c.nullable,
        CAST(NULL AS NUMBER) AS row_estimate
    FROM params p
    JOIN all_tab_columns c
        ON p.table_name IS NOT NULL
       AND c.owner = 'SYSADM'
       AND c.table_name IN (UPPER(p.table_name), 'PS_' || UPPER(p.table_name))
    UNION ALL
    SELECT
        'TABLE',
        t.table_name,
        CAST(NULL AS NUMBER),
        CAST(NULL AS VARCHAR2(128)),
        CAST(NULL AS VARCHAR2(106)),
        CAST(NULL AS NUMBER),
        CAST(NULL AS VARCHAR2(1)),
        t.num_rows
    FROM params p
    JOIN all_tables t
        ON p.table_name IS NULL
       AND p.name_pattern IS NOT NULL
       AND t.owner = 'SYSADM'
       AND t.table_name LIKE UPPER(p.name_pattern)
    ORDER BY 1, 2, 3
)
WHERE ROWNUM <= 400;
