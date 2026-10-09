-- Tool: ebs_describe_table
-- Skill: schema_discovery_and_lovs
-- Oracle Bind Variables:
--   :table_name (string): Table or view name to describe (e.g. 'AP_EXPENSE_REPORT_LINES_ALL').
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT :table_name AS table_name FROM dual
)
SELECT
    atc.owner,
    atc.table_name,
    atc.column_id,
    atc.column_name,
    atc.data_type,
    atc.data_length
FROM all_tab_columns atc, params p
WHERE atc.table_name = UPPER(p.table_name)
ORDER BY atc.owner, atc.column_id
FETCH FIRST 400 ROWS ONLY;
