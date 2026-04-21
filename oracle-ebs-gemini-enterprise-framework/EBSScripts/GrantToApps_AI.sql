--GRANT scripts 

DECLARE
    l_target_schema VARCHAR2(30) := 'APPS_AI'; -- Your custom schema
    l_sql           VARCHAR2(1000);
BEGIN
    FOR r IN (SELECT object_name 
              FROM all_objects 
              WHERE owner = 'APPS' 
             -- AND object_type IN ('TABLE', 'VIEW', 'SYNONYM')
            --  AND object_name NOT LIKE 'BIN$%' -- Exclude recycle bin
              and object_name  in -- consider specific
              ('MTL_ONHAND_QUANTITIES', 
               'MTL_MATERIAL_TRANSACTIONS',
               'MTL_SYSTEM_ITEMS_VL',
                'MTL_RESERVATIONS_V',
                'MTL_DEMAND_V',
                'MTL_SERIAL_NUMBERS',
                'GL_BALANCES_V',
                'GL_JE_HEADERS_V',
                'GL_JE_LINES_V',
                'GL_CODE_COMBINATIONS_KFV',
                'AP_INVOICES',
                'AP_INVOICE_LINES_V',
                'AP_SUPPLIER_SITES',
                'AP_CHECKS_V',
                'AR_INVOICES_V',
                'RA_CUSTOMER_TRX_V',
                'RA_CUST_TRX_LINE_GL_DIST_V',
                'AR_CASH_RECEIPTS_V',
                'PO_HEADERS_V',
                'PO_LINES_V',
                'OE_ORDER_HEADERS_V',
                'OE_ORDER_LINES_V',
                'MTL_SYSTEM_ITEMS_KFV',
                'MTL_ITEM_LOCATIONS_VK',
                'MTL_ONHAND_QUANTITIES_V'
              )
              )
    LOOP
        BEGIN
            l_sql := 'GRANT SELECT ON APPS.' || r.object_name || ' TO ' || l_target_schema;
            EXECUTE IMMEDIATE l_sql;
            DBMS_OUTPUT.PUT_LINE(l_sql);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                     dbms_output.put_line('No data not found.');
            WHEN OTHERS THEN
                    dbms_output.put_line('An error occurred: ' || SQLERRM);
         END;           
     END LOOP;

     DBMS_OUTPUT.PUT_LINE('Successfull');
END;
/


GRANT EXECUTE ON apps.fnd_global TO apps_ai;
GRANT EXECUTE ON apps.mo_global TO apps_ai;
GRANT EXECUTE ON apps.fnd_profile TO apps_ai; -- Often needed for associated profile lookups
GRANT EXECUTE ON apps.fnd_client_info TO apps_ai; -- Legacy context support
GRANT EXECUTE ON fnd_request TO APPS_AI; -- concurentrequest
GRANT EXECUTE ON APPS.FND_DATE TO APPS_AI; -- concretrequest

-- Grants for Multi-Org Access
GRANT SELECT ON APPS.HR_OPERATING_UNITS TO APPS_AI;
GRANT SELECT ON APPS.FND_PRODUCT_GROUPS TO APPS_AI;
GRANT SELECT ON APPS.FND_PROFILE_OPTION_VALUES TO APPS_AI;

-- Crucial for R12 MOAC Security
GRANT SELECT ON APPS.FND_ORGS_FOR_REP_MO_V TO APPS_AI;
GRANT SELECT ON APPS.FND_PRODUCT_INSTALLATIONS TO APPS_AI;

GRANT SELECT ON apps.ap_invoices_interface_s TO apps_ai;
-- Core NLS and Language tables
GRANT SELECT ON apps.fnd_languages TO apps_ai;
GRANT SELECT ON apps.fnd_territories TO apps_ai;

-- Profile and Security tables (FND_GLOBAL checks these)
GRANT SELECT ON apps.fnd_profile_options TO apps_ai;
GRANT SELECT ON apps.fnd_profile_option_values TO apps_ai;
GRANT SELECT ON apps.fnd_user TO apps_ai;
GRANT SELECT ON apps.fnd_responsibility TO apps_ai;
GRANT SELECT ON apps.fnd_application TO apps_ai;

-- Data Security and Environment tables
GRANT SELECT ON apps.fnd_product_groups TO apps_ai;
GRANT SELECT ON apps.fnd_oracle_userid TO apps_ai;

-- Grants on Secured Views
GRANT SELECT ON apps.ap_invoices TO apps_ai;
GRANT SELECT ON apps.ap_invoice_lines TO apps_ai;
GRANT SELECT ON apps.ap_invoice_distributions TO apps_ai;
GRANT SELECT ON apps.ap_payment_schedules TO apps_ai;

-- Required for Multi-Org Access Control (MOAC)
GRANT SELECT, INSERT, DELETE ON apps.mo_glob_org_access_tmp TO apps_ai;

-- Required for logging and session tracking
GRANT SELECT, INSERT ON apps.fnd_log_messages TO apps_ai;

-- Required for security profile preferences
GRANT SELECT, DELETE ON apps.fnd_mo_sp_preferences TO apps_ai;

-- Run these while logged in as APPS_AI (or as a DBA creating them for APPS_AI)
CREATE OR REPLACE SYNONYM apps_ai.fnd_global FOR apps.fnd_global;
CREATE OR REPLACE SYNONYM apps_ai.mo_global FOR apps.mo_global;
CREATE OR REPLACE SYNONYM apps_ai.fnd_profile FOR apps.fnd_profile;

