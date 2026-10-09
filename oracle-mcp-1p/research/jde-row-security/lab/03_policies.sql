-- Run as SYSTEM. Adds the lab VPD policy on the LAB COPY of F0101 only (never on TESTDTA).
-- Undo: DBMS_RLS.DROP_POLICY (also done by 99_teardown_lab.sql via DROP USER CASCADE).
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'JDE_RS_LAB',
        object_name     => 'F0101',
        policy_name     => 'JDE_RS_F0101_SELECT',
        function_schema => 'JDE_RS_LAB',
        policy_function => 'RS_PKG.VPD_POLICY',
        statement_types => 'SELECT',
        policy_type     => DBMS_RLS.DYNAMIC);
END;
/
EXIT
