SET SERVEROUTPUT ON

DECLARE
    l_default_temp   VARCHAR2(30);
    l_temp_replace   VARCHAR2(30) := 'TEMP_REPLACE_' || TO_CHAR(SYSDATE,'HH24MISS');

BEGIN
    -- Find the current default temporary tablespace
    SELECT property_value
    INTO   l_default_temp
    FROM   database_properties
    WHERE  property_name = 'DEFAULT_TEMP_TABLESPACE';

    DBMS_OUTPUT.PUT_LINE('Default temp tablespace: ' || l_default_temp);

    -- Create a temporary replacement
    EXECUTE IMMEDIATE
        'CREATE TEMPORARY TABLESPACE ' || l_temp_replace;

    DBMS_OUTPUT.PUT_LINE('Created replacement: ' || l_temp_replace);

    -- Make it the default
    EXECUTE IMMEDIATE
        'ALTER DATABASE DEFAULT TEMPORARY TABLESPACE ' || l_temp_replace;

    DBMS_OUTPUT.PUT_LINE('Default switched to ' || l_temp_replace);

    -- Drop and recreate every temporary tablespace
    FOR r IN (
        SELECT tablespace_name
        FROM   dba_tablespaces
        WHERE  contents = 'TEMPORARY'
		AND tablespace_name not like '%REPLACE%'
        ORDER BY tablespace_name
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('Dropping ' || r.tablespace_name);

        EXECUTE IMMEDIATE
            'DROP TABLESPACE ' || r.tablespace_name || ' INCLUDING CONTENTS AND DATAFILES';

        DBMS_OUTPUT.PUT_LINE('Recreating ' || r.tablespace_name);

        EXECUTE IMMEDIATE
            'CREATE TEMPORARY TABLESPACE ' || r.tablespace_name || ' TEMPFILE SIZE 300M ENCRYPTION USING ''AES128'' ENCRYPT';
    END LOOP;

    -- Restore original default
    EXECUTE IMMEDIATE
        'ALTER DATABASE DEFAULT TEMPORARY TABLESPACE ' || l_default_temp;

    DBMS_OUTPUT.PUT_LINE('Default restored to ' || l_default_temp);

    -- Remove replacement
    EXECUTE IMMEDIATE
        'DROP TABLESPACE ' || l_temp_replace || ' INCLUDING CONTENTS AND DATAFILES';

    DBMS_OUTPUT.PUT_LINE('Replacement removed.');

END;
/