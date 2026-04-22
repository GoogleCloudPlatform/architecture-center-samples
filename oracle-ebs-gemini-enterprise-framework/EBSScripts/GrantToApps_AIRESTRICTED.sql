/*Restricted/Module-Specific Access
Use this option for production environments where the principle of Least Privilege is strictly enforced to modules
payables,receivables, general ledger, order managements, ebtax, inventory and FND views
*/
BEGIN
   FOR r IN (SELECT owner, view_name 
             FROM all_views 
             WHERE owner = 'APPS' 
             AND (view_name LIKE 'AP_%' 
               OR view_name LIKE 'AR_%' 
               OR view_name LIKE 'GL_%' 
               OR view_name LIKE 'OE_%' 
               OR view_name LIKE 'ZX_%' 
               OR view_name LIKE 'MTL_%'
                OR view_name LIKE 'IBY_%'
                 OR view_name LIKE 'FND_%')) 
   LOOP
    BEGIN 
      EXECUTE IMMEDIATE 'GRANT SELECT ON ' || r.owner || '.' || r.view_name || ' TO APPS_AI';
       DBMS_OUTPUT.PUT_LINE('GRANT SELECT ON ' || r.owner || '.' || r.view_name || ' TO APPS_AI');
        EXCEPTION
         WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('FAILED: Grant on ' || r.view_name || ' | Error: ' || SQLERRM);
      END;          
    END LOOP;
     DBMS_OUTPUT.PUT_LINE('Successfull');
END;
/
