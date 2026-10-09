-- Tool: ps_list_setids
-- Skill: schema_discovery_and_lovs
-- Oracle Bind Variables:
--   :search_pattern (string): Optional search pattern to filter SetID code or description (e.g. '%SHARE%' or '%USA%').
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT :search_pattern AS search_pattern FROM dual
)
SELECT
    st.setid,
    st.descr AS setid_description
FROM sysadm.ps_setid_tbl st, params p
WHERE (p.search_pattern IS NULL OR UPPER(st.setid) LIKE UPPER(p.search_pattern) OR UPPER(st.descr) LIKE UPPER(p.search_pattern))
ORDER BY st.setid
FETCH FIRST 50 ROWS ONLY;
