DECLARE
    l_email_address    VARCHAR2(240) := 'krishnamurthy@pythian.com'; -- <--- extracted USER
    l_module_name        VARCHAR2(240) := '%Inventory%US%'; --- Payables%US% , Order%US% , General%ledger%US%
    l_default_organization_code        VARCHAR2(100):='S1'; -- S1 chicago 
    l_default_application_short_name         VARCHAR2(100):='INV'; -- application name 
    l_user_id          NUMBER;
    l_resp_id          NUMBER;
    l_resp_appl_id     NUMBER;
    l_user_name        VARCHAR2(100);
    l_actual_resp_name VARCHAR2(100);
    l_ou_id             NUMBER;

BEGIN
    -- 1. Fetch User and the specific "Inventory" Responsibility
    SELECT 
        u.user_id,
        u.user_name,
        r.responsibility_id,
        r.application_id,
        r.responsibility_name
    INTO 
        l_user_id,
        l_user_name,
        l_resp_id,
        l_resp_appl_id,
        l_actual_resp_name
    FROM 
        fnd_user u,
        fnd_user_resp_groups_direct urg,
        fnd_responsibility_vl r
    WHERE 
        u.email_address = l_email_address
        AND u.user_id = urg.user_id
        AND urg.responsibility_id = r.responsibility_id
        AND urg.responsibility_application_id = r.application_id
        -- Filter for Inventory responsibility
        AND r.responsibility_name LIKE l_module_name
        -- Ensure User is active
        AND (u.end_date IS NULL OR u.end_date > SYSDATE)
        -- Ensure Responsibility assignment is active
        AND (urg.end_date IS NULL OR urg.end_date > SYSDATE)
        -- Ensure Responsibility definition is active
        AND (r.end_date IS NULL OR r.end_date > SYSDATE)
        AND ROWNUM = 1;

    -- 2. Perform Apps Initialize
    FND_GLOBAL.APPS_INITIALIZE(
        user_id      => l_user_id,
        resp_id      => l_resp_id,
        resp_appl_id => l_resp_appl_id
    );
        
    -- 2.1 Initialize Multi-Org for Inventory
    -- This sets up the access map based on your responsibility's profile options
    MO_GLOBAL.INIT(l_default_application_short_name);

    DBMS_OUTPUT.PUT_LINE('MO Global Multi-Org for Inventory ');
    
    --  2.2 Set Policy Context
    -- to work within one specific Operating Unit, find its ID first
    -- Example: Finding the OU linked to a specific Inventory Org (Chicago)
    SELECT operating_unit
   INTO   l_ou_id
    FROM   org_organization_definitions
    WHERE  organization_code = l_default_organization_code; -- Chicago inv Org Code

    -- Set the context to 'S' (Single) for that specific OU
    MO_GLOBAL.SET_POLICY_CONTEXT('S', l_ou_id);

    DBMS_OUTPUT.PUT_LINE('MO Global Initialized for OU ID: ' || l_ou_id);
    
    -- 3. Output confirmation
    DBMS_OUTPUT.PUT_LINE('Session Initialized Successfully:');
    DBMS_OUTPUT.PUT_LINE('---------------------------------');
    DBMS_OUTPUT.PUT_LINE('User Name  : ' || l_user_name);
    DBMS_OUTPUT.PUT_LINE('Resp Name  : ' || l_actual_resp_name);
    DBMS_OUTPUT.PUT_LINE('Resp ID    : ' || l_resp_id);
    DBMS_OUTPUT.PUT_LINE('Appl ID    : ' || l_resp_appl_id);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: No active ' ||l_module_name||' responsibility found for ' || l_email_address);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
