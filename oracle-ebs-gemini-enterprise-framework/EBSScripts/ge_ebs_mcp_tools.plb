create or replace package body ge_ebs_mcp_tools
as

function get_email 
return varchar2
is
PRAGMA AUTONOMOUS_TRANSACTION;
l_email_address       VARCHAR2(240);
begin
  if nvl(fnd_global.user_id,-1) = -1
  then
    return null;
  end if;
  
  begin
    select email_address
      into l_email_address
      from fnd_user
     where user_id = fnd_global.user_id;
  exception
    when OTHERS then return null;
  end;
  
  return l_email_address;
end get_email;


function ebs_initialize_context (
    p_email_address             VARCHAR2,
    p_operating_unit            VARCHAR2 DEFAULT NULL,
    p_responsibility            VARCHAR2 DEFAULT NULL,
    p_application_short_name    VARCHAR2 DEFAULT NULL
) return VARCHAR2 IS 
PRAGMA AUTONOMOUS_TRANSACTION;
    
    l_program_unit varchar2(100) := 'ebs_initialize_context';

    l_email_address       VARCHAR2(240) := p_email_address;
    l_operating_unit VARCHAR2(240) := p_operating_unit;
    l_responsibility VARCHAR2(240) := p_responsibility;
    l_application_short_name VARCHAR2(240) := p_application_short_name;
    l_user_id             NUMBER := -1;
    l_resp_id             NUMBER := -1;
    l_resp_appl_id        NUMBER := -1;
    l_ou_id               NUMBER := -1;
    l_user_name           VARCHAR2(100);
    l_actual_resp_name    VARCHAR2(100);

    l_return_value         VARCHAR2(4000);

BEGIN
    -- Set any necessary session parameters for EBS
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT = ''YYYY-MM-DD HH24:MI:SS''';
    mcp_toolbox_log('Session parameters set. Starting EBS initialization.','DEBUG',l_email_address,l_program_unit);
    mcp_toolbox_log('Input parameters - '
                    || 'p_email_address: '|| l_email_address
                    || ', p_operating_unit: '|| nvl(l_operating_unit, 'NULL')
                    || ', p_responsibility_name: '|| nvl(l_responsibility, 'NULL')
                    || ', p_application_short_name: '||nvl(l_application_short_name, 'NULL')
                   ,'DEBUG',l_email_address,l_program_unit)
                    ;
    --Check if this session has already been initialised
    BEGIN
        SELECT 
        JSON_ARRAY(
         JSON_object('user_name' value l_email_address),
         JSON_object('responsibility_name' value fr.responsibility_name),
         JSON_object('security_group_name' value fsg.security_group_name),     -- Added Security Group Name
         JSON_object('application_short_name' value fa.application_short_name),
         JSON_object('operating_unit_name' value hou.name  )
         ) MESSAGE,
         fnd_global.user_id
    INTO l_return_value,
         l_user_id
    FROM 
        fnd_user fu,
        fnd_responsibility_vl fr,
        fnd_application fa,
        hr_operating_units hou,
        fnd_security_groups_vl fsg   -- Added Security Groups View
    WHERE 
        fu.user_id = fnd_global.user_id
        and fu.email_address = l_email_address
        AND fr.responsibility_id = fnd_global.resp_id
        AND fr.application_id = fnd_global.resp_appl_id
        AND fa.application_id = fnd_global.resp_appl_id
        AND fsg.security_group_id = fnd_global.security_group_id -- Join for Security Group
        AND hou.organization_id(+) = fnd_global.org_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            mcp_toolbox_log('Session not initialised: '||l_email_address,'DEBUG',l_email_address,l_program_unit);
            
    END;
    
    IF l_user_id != -1 and l_email_address = get_email() --session is initialised
       AND coalesce(l_operating_unit,l_responsibility,l_application_short_name) is null --No arguments given
    THEN
        mcp_toolbox_log('Session already initialised: '||l_email_address,'DEBUG',l_email_address,l_program_unit);
        l_return_value := '{"STATUS":"SUCCESS","MESSAGE":'||l_return_value||'}';
        return l_return_value;
    END IF;
    
    -- Check if user actually exists;
    BEGIN
        select 
            u.user_id,
            u.user_name
          INTO
            l_user_id,
            l_user_name
          FROM fnd_user u
          WHERE upper(u.email_address) = upper(l_email_address)
           AND ( u.end_date IS NULL OR u.end_date > sysdate );
          -- (u.email_address = l_email_address or to_char(u.user_id) = l_email_address or u.user_name = l_email_address)
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            mcp_toolbox_log('Username not found '||l_email_address,'ERROR',l_email_address,l_program_unit);
            ROLLBACK;
            l_return_value := '{"STATUS":"ERROR","MESSAGE":"Username not found '||l_email_address||'"}';
            return l_return_value;
    END;
    
    -- Fetch User Responsibility
    BEGIN
        SELECT
            r.responsibility_id,
            r.application_id,
            r.responsibility_name
        INTO
            l_resp_id,
            l_resp_appl_id,
            l_actual_resp_name
            
        FROM
            fnd_user_resp_groups_direct urg,
            fnd_responsibility_vl       r
        WHERE 1=1
                
            AND urg.user_id = l_user_id
            AND urg.responsibility_id = r.responsibility_id
            AND urg.responsibility_application_id = r.application_id
                        -- Filter for Inventory responsibility
            AND ( upper(r.responsibility_name) = upper(l_responsibility) OR l_responsibility IS NULL )
                        -- Ensure Responsibility assignment is active
            AND ( urg.end_date IS NULL
                  OR urg.end_date > sysdate )
                        -- Ensure Responsibility definition is active
            AND ( r.end_date IS NULL
                  OR r.end_date > sysdate )
            ORDER BY r.responsibility_id
            FETCH FIRST 1 ROW ONLY ;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            mcp_toolbox_log('No responsibility found for '||l_email_address||'/'||'"'||l_responsibility||'"','ERROR',l_email_address,l_program_unit);
            ROLLBACK;
            l_return_value := '{"STATUS":"ERROR","MESSAGE":"Responsibility not found '||NVL(l_responsibility,'No Responsibility provided')||'"}';
            return l_return_value;
--            RAISE_APPLICATION_ERROR(-20001,'Username not found '||l_email_address);
        WHEN OTHERS THEN
            mcp_toolbox_log('ERROR: Something went wrong '||sqlerrm,'ERROR',l_email_address,l_program_unit);
            l_return_value := '{"STATUS":"ERROR","MESSAGE":"Something went wrong '||sqlerrm||'"}';
            ROLLBACK;
            return l_return_value;
--            RAISE_APPLICATION_ERROR(-20101,'Something went wrong '||l_email_address);
        
    
    END;
    -- 2. Perform Apps Initialize
    fnd_global.apps_initialize(
        user_id      => l_user_id,
        resp_id      => l_resp_id,
        resp_appl_id => l_resp_appl_id
    );
    
    
    -- If no shortname provided
    if l_application_short_name is null 
    THEN
    BEGIN
        SELECT DISTINCT 
           fa.application_short_name
         into l_application_short_name
         FROM   fnd_user_resp_groups_direct furg  
         JOIN   fnd_responsibility_vl fr         ON furg.responsibility_id = fr.responsibility_id
                                                    AND furg.responsibility_application_id = fr.application_id
         JOIN   fnd_application_vl fa            ON fr.application_id = fa.application_id
         WHERE  1=1
           AND furg.user_id = l_user_id
           AND    fa.application_short_name NOT IN ('SYSADMIN', 'FND', 'XDO', 'ALR')
           ORDER BY application_short_name
           FETCH FIRST 1 ROW ONLY;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            mcp_toolbox_log('Application not found for '||l_application_short_name,'ERROR',l_email_address,l_program_unit);
            l_return_value := '{"STATUS":"ERROR","MESSAGE":"Application not found for '||l_application_short_name||'"}';
            ROLLBACK;
            return l_return_value;
--            RAISE_APPLICATION_ERROR(-20002,'Application not found for '||l_application_short_name);
        WHEN OTHERS THEN
            mcp_toolbox_log('Something went wrong '||sqlerrm,'ERROR',l_email_address,l_program_unit);
            l_return_value := '{"STATUS":"ERROR","MESSAGE":"Something went wrong: '||sqlerrm||'"}';
            ROLLBACK;
            return l_return_value;
--            RAISE_APPLICATION_ERROR(-20202,'Something went wrong '||l_application_short_name);
    END;    
    END IF;

    -- 2.1 Initialize Multi-Org for Inventory
    -- This sets up the access map based on your responsibility's profile options
    BEGIN
    MO_GLOBAL.INIT(l_application_short_name);
    EXCEPTION
        WHEN OTHERS THEN
            mcp_toolbox_log('Something went wrong initi for '||l_application_short_name||' -  '||sqlerrm,'ERROR',l_email_address,l_program_unit);
            l_return_value := '{"STATUS":"ERROR","MESSAGE":"Something went wrong: '||sqlerrm||'"}';
            ROLLBACK;
            return l_return_value;
    --  2.2 Set Policy Context
    -- to work within one specific Operating Unit, find its ID first
    -- Example: Finding the OU linked to a specific Inventory Org (Chicago)
    END;
    
    IF l_operating_unit is null
    THEN
    BEGIN
          SELECT DISTINCT
                hou.organization_id AS operating_unit_id,
                hou.name            AS operating_unit_name
            INTO
               l_ou_id,
               l_operating_unit
            FROM fnd_user_resp_groups_direct furg 
            JOIN fnd_responsibility_vl       fr ON furg.responsibility_id = fr.responsibility_id AND furg.responsibility_application_id = fr.application_id
            JOIN fnd_application_vl          fa ON fr.application_id = fa.application_id
            JOIN fnd_profile_option_values   fpov ON fpov.level_value = furg.responsibility_id AND fpov.level_id = 10003 -- Level 10003 is 'Responsibility' level
            JOIN fnd_profile_options         fp ON fpov.profile_option_id = fp.profile_option_id
            JOIN hr_operating_units          hou ON hou.organization_id = TO_NUMBER(fpov.profile_option_value)
            WHERE fp.profile_option_name = 'ORG_ID'
                AND furg.user_id = l_user_id
                AND fa.application_short_name NOT IN ( 'SYSADMIN', 'FND', 'XDO', 'ALR' )
            ORDER BY operating_unit_id
            FETCH FIRST 1 ROW ONLY;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            mcp_toolbox_log('Organization not found for '||l_email_address,'ERROR',l_email_address,l_program_unit);
            l_return_value := '{"STATUS":"ERROR","MESSAGE":"Organization not found for '||l_email_address||'"}';
            ROLLBACK;
            return l_return_value;
--            RAISE_APPLICATION_ERROR(-20003,'Organization not found for '||l_email_address);
        WHEN OTHERS THEN
            mcp_toolbox_log('Something went wrong '||sqlerrm,'ERROR',l_email_address,l_program_unit);
            l_return_value := '{"STATUS":"ERROR","MESSAGE":"Something went wrong for '||l_email_address||'"}';
            ROLLBACK;
            return l_return_value;
--            RAISE_APPLICATION_ERROR(-20303,'Something went wrong '||l_email_address);
        
    END;
    ELSE
    BEGIN
        SELECT
            operating_unit
        INTO l_ou_id
        FROM
            org_organization_definitions
        WHERE
            upper(organization_name) = upper(l_operating_unit)
            FETCH FIRST 1 ROW ONLY;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            mcp_toolbox_log('Organization not found '||l_operating_unit,'ERROR',l_email_address,l_program_unit);
            l_return_value := '{"STATUS":"ERROR","MESSAGE":"Organization not found for '||l_operating_unit||'"}';
            ROLLBACK;
            return l_return_value;
--            RAISE_APPLICATION_ERROR(-20004,'Organization not found for '||l_operating_unit);
        WHEN OTHERS THEN
            mcp_toolbox_log('Something went wrong '||sqlerrm,'ERROR',l_email_address,l_program_unit);
            l_return_value := '{"STATUS":"ERROR","MESSAGE":"Something went wrong for '||l_operating_unit||'"}';
            ROLLBACK;
            return l_return_value;
--            RAISE_APPLICATION_ERROR(-20404,'Something went wrong '||l_operating_unit);
        
    END;
    END IF;

    -- Set the context to 'S' (Single) for that specific OU
    mo_global.set_policy_context('S', l_ou_id);
    
    mcp_toolbox_log('EBS session initialized successfully for user '
                    || l_email_address
                    || ' with responsibility '
                    || l_actual_resp_name,
                    'INFO',
                    l_email_address,l_program_unit);
    SELECT JSON_ARRAY(
        JSON_object('user_name' value l_email_address),
        JSON_object('responsibility_name' value fr.responsibility_name),
        JSON_object('security_group_name' value fsg.security_group_name),     -- Added Security Group Name
        JSON_object('application_short_name' value fa.application_short_name),
        JSON_object('operating_unit_name' value hou.name  )
        ) j
    INTO l_return_value
    FROM 
        fnd_user fu,
        fnd_responsibility_vl fr,
        fnd_application fa,
        hr_operating_units hou,
        fnd_security_groups_vl fsg   -- Added Security Groups View
    WHERE 
        fu.user_id = fnd_global.user_id
        AND fr.responsibility_id = fnd_global.resp_id
        AND fr.application_id = fnd_global.resp_appl_id
        AND fa.application_id = fnd_global.resp_appl_id
        AND fsg.security_group_id = fnd_global.security_group_id -- Join for Security Group
        AND hou.organization_id(+) = fnd_global.org_id
    ;
    
    l_return_value := '{"STATUS":"SUCCESS","MESSAGE":'||l_return_value||'}';
    
--    "MESSAGE":"EBS session initialized successfully for user '
--                    || l_email_address
--                    || '","RESPONSIBILITY":"'
--                    || l_actual_resp_name
--                    || '","OPERATING_UNIT_NAME":"'
--                    || l_operating_unit
--                    ||'"}';
    COMMIT;
    RETURN l_return_value;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        mcp_toolbox_log('Failed to initialize EBS session - ' || sqlerrm,'ERROR');
        l_return_value := '{"STATUS":"ERROR","MESSAGE":"Failed to initialize EBS session - ' || sqlerrm||'"}';
        return l_return_value;
END ebs_initialize_context;


FUNCTION reserve_item (
    p_item varchar2,
    p_quantity number default 1,
    p_location varchar2 default null,
    p_sub_inventory varchar2 := 'Stores'
) return VARCHAR2 IS
PRAGMA AUTONOMOUS_TRANSACTION;

    l_program_unit       VARCHAR2(100) := 'reserve_item';
    l_email_address      VARCHAR2(240) := get_email();
    -- API Variables
    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);
    l_rsv_id             NUMBER;
    l_qty_reserved       NUMBER; -- The confirmed amount actually reserved.
    l_dummy_sn           inv_reservation_global.serial_number_tbl_type;
    l_rsv_rec            inv_reservation_global.mtl_reservation_rec_type;
    
    -- Input Variables
    l_item_name          VARCHAR2(100) := UPPER(p_item); --'O-rings'; -- item or part number
    l_org_code           VARCHAR2(100)   := p_location; -- 'S1'; -- Change to your Chicago Org Code
    l_subinv             VARCHAR2(30)  := p_sub_inventory; -- defualt to stores 
    l_qty                NUMBER        := p_quantity; -- quantity requested
    
    -- System IDs
    l_item_id            NUMBER;
    l_org_id             NUMBER;
    l_user_id            NUMBER := fnd_global.user_id;
    
    l_error_count        NUMBER := 0;

    l_module             VARCHAR2(50) := 'RESERVE_ITEM';
    l_return_value      VARCHAR2(4000);

BEGIN
    
        -- Set any necessary session parameters for EBS
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT = ''YYYY-MM-DD HH24:MI:SS''';
    mcp_toolbox_log('Session parameters set. Starting Reserve Item.','INFO',l_email_address,l_program_unit);
    mcp_toolbox_log('Input parameters - '
                    || 'p_item: '|| l_item_name
                    || ', p_quantity: '|| nvl(l_qty, -1)
                    || ', p_organization_name: '|| nvl(l_org_code, 'NULL')
                    || ', p_sub_inventory: '||nvl(l_subinv, 'NULL')
                   ,'DEBUG',l_email_address,l_program_unit
                   );
    -- Verify Organization was passed correctly
--    if l_org_code is null
--    then
----        TODO: Need logic to make sure code is valid
--        BEGIN
--            NULL;
--        EXCEPTION
--            WHEN NO_DATA_FOUND THEN
--                mcp_toolbox_log('Item not found '||l_item_name||' / ('||l_org_code||')','ERROR',l_email_address,l_program_unit);
--                l_return_value := '{"STATUS":"ERROR","MESSAGE":"Item not found '||l_item_name||' / ('||l_org_code||')'||'"}';
--                RETURN l_return_value;
--                 --RAISE_APPLICATION_ERROR(-20004,'Item not found '||l_item_name);
--            WHEN OTHERS THEN
--                mcp_toolbox_log('ERROR: Something went wrong '||sqlerrm,'ERROR',l_email_address,l_program_unit);
--                l_return_value := '{"STATUS":"ERROR","MESSAGE":"Something went wrong '||l_item_name||'"}';
--                RETURN l_return_value;
--        
--        END;
--        null;
--        
--    end if;
    
    -- Get IDs from Base Tables
    BEGIN
        SELECT max(msi.inventory_item_id) as inventory_item_id 
        INTO   l_item_id
        FROM   mtl_parameters mp, 
               mtl_system_items_b msi,
               apps.org_organization_definitions ood
       WHERE  1=1
         AND (mp.organization_code =  l_org_code or l_org_code is null)
         AND msi.organization_id = mp.organization_id
         and msi.organization_id = ood.organization_id  
         AND ood.operating_unit = fnd_global.org_id
         AND upper(msi.segment1 ) like upper(l_item_name)
         AND msi.reservable_type  = 1; -- Ensure item is reservable
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            mcp_toolbox_log('Item not found '||l_item_name||' / ('||l_org_code||')','ERROR',l_email_address,l_program_unit);
            l_return_value := '{"STATUS":"ERROR","MESSAGE":"Item not found '||l_item_name||' / ('||l_org_code||')'||'"}';
            RETURN l_return_value;
             --RAISE_APPLICATION_ERROR(-20004,'Item not found '||l_item_name);
        WHEN OTHERS THEN
            mcp_toolbox_log('Something went wrong '||sqlerrm,'ERROR',l_email_address,l_program_unit);
            l_return_value := '{"STATUS":"ERROR","MESSAGE":"Something went wrong '||l_item_name||'"}';
            RETURN l_return_value;
    END;

    -- 2. Initialize Reservation Record (Critical for R12)
    -- We set everything to NULL first to avoid junk values in the record
    mcp_toolbox_log('Packing variables','DEBUG',l_email_address,l_program_unit); 
    l_rsv_rec := NULL;

    l_rsv_rec.reservation_id            := NULL; -- Generating new
    l_rsv_rec.organization_id           := fnd_global.org_id;
    l_rsv_rec.inventory_item_id         := l_item_id;
    
    -- Demand Source: Type 13 = Inventory/Account (Manual Reservation)
    l_rsv_rec.demand_source_type_id     := 13; -- default 13 for inventory 
    l_rsv_rec.demand_source_name        := 'MANUAL_RSV';
    
    -- Supply Source: Type 13 = Inventory
    l_rsv_rec.supply_source_type_id     := 13; --default 13 for inventory 
    
    -- Location & Quantity
    l_rsv_rec.subinventory_code         := l_subinv;
    l_rsv_rec.reservation_uom_code      := 'Ea'; -- Ensure this is your primary UOM
    l_rsv_rec.reservation_quantity      := l_qty;
    
    -- R12 Specific Flags (The "Ship Ready" Fix)
    l_rsv_rec.ship_ready_flag           := 1;
    l_rsv_rec.staged_flag               := 'N';
    
    -- Mandatory Dates
    l_rsv_rec.requirement_date          := SYSDATE;
 --   l_rsv_rec.created_by                := l_user_id;
 --   l_rsv_rec.last_updated_by           := l_user_id;

    -- 3. Call the API
    mcp_toolbox_log('Calling inv_reservation_pub.create_reservation','DEBUG',l_email_address,l_program_unit);
    inv_reservation_pub.create_reservation (
        p_api_version_number        => 1.0,
        p_init_msg_lst              => fnd_api.g_true,
        x_return_status             => l_return_status,
        x_msg_count                 => l_msg_count,
        x_msg_data                  => l_msg_data,
        p_rsv_rec                   => l_rsv_rec,
        p_serial_number             => l_dummy_sn,
        x_serial_number             => l_dummy_sn,
        x_quantity_reserved         => l_qty_reserved,
        x_reservation_id            => l_rsv_id
    );

    -- 4. Handle Result
    IF l_return_status = fnd_api.g_ret_sts_success THEN
        COMMIT;
        mcp_toolbox_log('Success!','DEBUG',l_email_address,l_program_unit);
        -- This probably needs to propogate to the calling agent!
        mcp_toolbox_log('Reservation ID: ' || l_rsv_id,'INFO',l_email_address,l_program_unit);
        mcp_toolbox_log('Quantity Reserved: ' || l_qty_reserved,'INFO',l_email_address,l_program_unit);
    ELSE
        -- Detailed Error Logging
        ROLLBACK;
        mcp_toolbox_log('API Failed with status: ' || l_return_status,'ERROR',l_email_address,l_program_unit);
        l_error_count := l_error_count +1;
        FOR i IN 1..l_msg_count LOOP
            l_msg_data := fnd_msg_pub.get(p_msg_index => i, p_encoded => 'F');
            mcp_toolbox_log('**  Error ' || i || ': ' || l_msg_data,'ERROR',l_email_address,l_program_unit);
            l_error_count := l_error_count +1;
        END LOOP;
    END IF;
    
    if l_error_count > 0
    then
        mcp_toolbox_log('Something went wrong calling the API. Error count '||l_error_count,'ERROR',l_email_address,l_program_unit);
        l_return_value := '{"STATUS":"ERROR","MESSAGE":"Something went wrong calling the API. Error count '||l_error_count||'"}';
        RETURN l_return_value;
    end if;
    l_return_value := '{"STATUS":"SUCCESS","MESSAGE":[{"RESERVATION_ID":"' || l_rsv_id || '"},{"QUANTITY_RESERVED":"' || l_qty_reserved || '"}]}';
    RETURN l_return_value;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        mcp_toolbox_log('System Error: ' || SQLERRM,'ERROR',l_email_address,l_program_unit);
        l_return_value := '{"STATUS":"ERROR","MESSAGE":"Something went wrong. Unhandled exception '||SQLERRM||'"}';
        RETURN l_return_value;

END reserve_item;

FUNCTION create_onhand (
    p_item           VARCHAR2,
    p_quantity       NUMBER,
    p_location       VARCHAR2,
    p_sub_inventory  VARCHAR2 DEFAULT 'Stores'
    --p_account_id     NUMBER   DEFAULT NULL
) RETURN VARCHAR2 IS 
PRAGMA AUTONOMOUS_TRANSACTION;
    
    l_program_unit varchar2(100) := 'create_onhand';
    l_email_address      VARCHAR2(240) := get_email();
    
    l_item_id           NUMBER;
    l_org_id            NUMBER;
    l_header_id         NUMBER;
    l_iface_id          NUMBER;
    l_acct_id           NUMBER := 17347; -- Miscellaneous transaction CCID (Distribution Account)   ;
    l_trans_type_id  NUMBER := 42; -- Miscellaneous Receipt
    l_return_status     VARCHAR2(1);
    l_msg_count         NUMBER;
    l_trans_count       NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_trans_res         NUMBER;
    l_module            VARCHAR2(50) := 'CREATE_ONHAND';
    l_return_value      VARCHAR2(4000);
BEGIN
    mcp_toolbox_log('Starting Create Onhand for Item: ' || p_item, 'INFO',l_email_address,l_program_unit);

    --  Get Item and Org IDs
    BEGIN
        SELECT msi.inventory_item_id, msi.organization_id
        INTO   l_item_id, l_org_id
        FROM   mtl_system_items_b msi, mtl_parameters mp
        WHERE  msi.segment1 = p_item
          AND  msi.organization_id = mp.organization_id
          AND  mp.organization_code = p_location;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            mcp_toolbox_log('Item/Org mapping not found: ' || p_item || '/' || p_location, 'ERROR',l_email_address,l_program_unit);
            l_return_value := '{"STATUS":"ERROR","MESSAGE":"Item or Organization invalid."}';
            RETURN l_return_value;
             --RAISE_APPLICATION_ERROR(-20004,'Item or Organization not found for '||p_item||' / ' || p_location);
        WHEN OTHERS THEN
            mcp_toolbox_log('ERROR: Something went wrong '||sqlerrm,'ERROR',l_email_address,l_program_unit);
            l_return_value := '{"STATUS":"ERROR","MESSAGE":"Something went wrong for '||p_item||' / ' || p_location||'"}';
            RETURN l_return_value;
            --RAISE_APPLICATION_ERROR(-20505,'Something went wrong '||p_item||' / ' || p_location);
    END;

    -- Default Account ID if not provided (Fetching from Org parameters as fallback)
    IF l_acct_id IS NULL THEN
        SELECT material_account INTO l_acct_id 
        FROM mtl_parameters WHERE organization_id = l_org_id;
    END IF;

    --  Prepare Interface IDs
    SELECT mtl_material_transactions_s.NEXTVAL INTO l_header_id FROM dual;
    SELECT mtl_material_transactions_s.NEXTVAL INTO l_iface_id FROM dual;

    --  Insert into transactions_interface Interface
    INSERT INTO mtl_transactions_interface (
        transaction_interface_id,
        transaction_header_id,
        source_code,
        source_line_id,
        source_header_id,
        process_flag,
        transaction_mode,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        inventory_item_id,
        organization_id,
        subinventory_code,
        transaction_quantity,
        transaction_uom,
        transaction_date,
        transaction_type_id, -- 42: Misc Receipt
        distribution_account_id
    ) VALUES (
        l_iface_id,
        l_header_id,
        'MCP_TOOLBOX',
        1,
        1,
        1, -- Pending
        3, -- Background
        SYSDATE,
        fnd_global.user_id,
        SYSDATE,
        fnd_global.user_id,
        l_item_id,
        l_org_id,
        p_sub_inventory,
        p_quantity,
        'Ea',
        SYSDATE,
        l_trans_type_id,
        l_acct_id
    );

    -- 5. Call Transaction Manager API
    mcp_toolbox_log('Calling inv_txn_manager_pub for Header: ' || l_header_id, 'DEBUG',l_email_address,l_program_unit);
    
    l_trans_res := /*inv_txn_manager_pub.process_Transactions(
        p_api_version   => 1.0,
        p_header_id     => l_header_id,
        p_table         => 1, -- Interface Table
        x_return_status => l_return_status,
        x_msg_count     => l_msg_count,
        x_msg_data      => l_msg_data
    );*/
    INV_TXN_MANAGER_PUB.process_Transactions(
        p_api_version      => 1.0,
        p_init_msg_list   => fnd_api.g_false,
        p_commit         => fnd_api.g_true ,
        p_validation_level  => 100,--fnd_api.g_valid_level_full 
        p_header_id        => l_header_id,
        p_table            => 1, -- 1 = MTL_TRANSACTIONS_INTERFACE
        x_return_status    => l_return_status,
        x_msg_count        => l_msg_count,
        x_msg_data         => l_msg_data,
        x_trans_count     => l_trans_count
    ) ;

    IF l_trans_res = 0 AND l_return_status = fnd_api.g_ret_sts_success THEN
        COMMIT;
        mcp_toolbox_log('Onhand successfully created. Interface ID: ' || l_iface_id, 'INFO',l_email_address,l_program_unit);
            l_return_value := '{"STATUS":"SUCCESS","MESSAGE":"Onhand created successfully.","INTERFACE_ID":' || l_iface_id || '}';
            RETURN l_return_value;

    ELSE
        ROLLBACK;
        -- Check interface table for specific explanation if API generic message is empty
        BEGIN
            SELECT error_explanation INTO l_msg_data 
            FROM mtl_transactions_interface 
            WHERE transaction_interface_id = l_iface_id;
        EXCEPTION WHEN OTHERS THEN NULL; END;
        
        mcp_toolbox_log('Onhand Creation Failed: ' || l_msg_data, 'ERROR',l_email_address,l_program_unit);
        l_return_value := '{"STATUS":"ERROR","MESSAGE":"Onhand creation failed. ' || l_msg_data || '"}';
        RETURN l_return_value;
        --RAISE_APPLICATION_ERROR(-20702, 'Transaction Manager Error: ' || l_msg_data);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        mcp_toolbox_log('System Error in create_onhand: ' || SQLERRM, 'ERROR',l_email_address,l_program_unit);
        l_return_value := '{"STATUS":"ERROR","MESSAGE":"Something went wrong. Unhandled exception '||SQLERRM||'"}';
        RETURN l_return_value;
        -- RAISE;
END create_onhand;

FUNCTION delete_reservation (
    p_reservation_id NUMBER
) RETURN VARCHAR2 IS 
PRAGMA AUTONOMOUS_TRANSACTION;
    
    l_program_unit varchar2(100) := 'delete_reservation';
    l_email_address      VARCHAR2(240) := get_email();
    
    -- API Variables
    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);
    l_rsv_rec            inv_reservation_global.mtl_reservation_rec_type;
    l_dummy_sn           inv_reservation_global.serial_number_tbl_type;
    l_module             VARCHAR2(50) := 'DELETE_RESERVATION';
    l_return_value       VARCHAR2(4000);


BEGIN
    mcp_toolbox_log('Starting Delete Reservation ID: ' || p_reservation_id, 'INFO',l_email_address,l_program_unit);

    -- Initialize the record with the Reservation ID
    l_rsv_rec.reservation_id := p_reservation_id;

    --  Call the Standard INV API
    inv_reservation_pub.delete_reservation (
        p_api_version_number => 1.0,
        p_init_msg_lst       => fnd_api.g_true,
        x_return_status      => l_return_status,
        x_msg_count          => l_msg_count,
        x_msg_data           => l_msg_data,
        p_rsv_rec            => l_rsv_rec,
        p_serial_number      => l_dummy_sn
    );

    --  Handle Result and Capture Message Stack
    IF l_return_status = fnd_api.g_ret_sts_success THEN
        COMMIT;
        mcp_toolbox_log('Reservation successfully deleted: '||p_reservation_id,'INFO',l_email_address,l_program_unit);
        l_return_value := '{"STATUS":"SUCCESS","MESSAGE":"Reservation ' || p_reservation_id || ' deleted successfully."}';
        RETURN l_return_value;
    ELSE
        ROLLBACK;
        mcp_toolbox_log('Delete API Failed. Status: ' || l_return_status, 'ERROR',l_email_address,l_program_unit);

        -- Loop through FND_MSG_PUB to get detailed error messages
        IF l_msg_count > 0 THEN
            FOR i IN 1..l_msg_count LOOP
                l_msg_data := fnd_msg_pub.get(p_msg_index => i, p_encoded => 'F');
                mcp_toolbox_log('EBS Message ['||i||']: ' || l_msg_data, 'ERROR',l_email_address,l_program_unit);
            END LOOP;
        END IF;

        l_return_value := '{"STATUS":"ERROR","MESSAGE":"Delete Reservation Failed. Check log for details."}';
        RETURN l_return_value;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        mcp_toolbox_log('System Error in delete_reservation: ' || SQLERRM, 'ERROR',l_email_address,l_program_unit);
        l_return_value := '{"STATUS":"ERROR","MESSAGE":"System Error in delete_reservation: ' || SQLERRM || '"}';
        RETURN l_return_value;
END delete_reservation;

FUNCTION create_supplier (
    p_vendor_name IN  VARCHAR2,
    p_site_name   IN VARCHAR2 default NULL,
    p_tax_reg_num IN  VARCHAR2 default NULL
) RETURN VARCHAR2 
IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    
    l_program_unit varchar2(100) := 'create_supplier';
    l_sqlerrm varchar2(4000);
    
    l_vendor_rec    ap_vendor_pub_pkg.r_vendor_rec_type;
    l_return_status VARCHAR2(10);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
    l_party_id      NUMBER;
    
    l_vendor_id     NUMBER;
    l_return_value  VARCHAR2(4000);
BEGIN

    l_vendor_rec.vendor_name    := p_vendor_name;
    l_vendor_rec.tax_reference  := p_tax_reg_num;

    ap_vendor_pub_pkg.create_vendor(
        p_api_version      => 1.0,
        p_init_msg_list    => fnd_api.g_true,
        p_commit           => fnd_api.g_false,
        p_validation_level => fnd_api.g_valid_level_full,
        p_vendor_rec       => l_vendor_rec,
        x_return_status    => l_return_status,
        x_msg_count        => l_msg_count,
        x_msg_data         => l_msg_data,
        x_vendor_id        => l_vendor_id,
        x_party_id         => l_party_id
    );

    IF l_return_status = fnd_api.g_ret_sts_success THEN
        DBMS_OUTPUT.PUT_LINE('Supplier Created Successfully. Vendor ID: ' || l_vendor_id);
        l_return_value := '{"STATUS":"SUCCESS","VENDOR_ID":"'||l_vendor_id||'"}';
        COMMIT;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Error Creating Supplier: ' || l_msg_data);
        l_return_value := '{"STATUS":"ERROR","MESSAGE":"Error Creating Supplier: '||l_msg_data||'"}';
        ROLLBACK;
    END IF;
    
    RETURN l_return_value;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        l_sqlerrm:=SQLERRM;
        l_return_value := '{"STATUS":"ERROR","MESSAGE":"'||l_sqlerrm||'"}';
        RETURN l_return_value;
END create_supplier;

FUNCTION create_supplier_site (
    p_vendor_id   IN NUMBER,
    p_site_name   IN VARCHAR2
) RETURN VARCHAR2
IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    
    l_program_unit varchar2(100) := 'create_supplier_site';
    l_sqlerrm varchar2(4000);
    
    l_site_rec       ap_vendor_pub_pkg.r_vendor_site_rec_type;
    l_return_status  VARCHAR2(4000);
    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(4000);
    l_vendor_site_id NUMBER;
    l_party_site_id  NUMBER;
    l_location_id    NUMBER;
    
    l_return_value         VARCHAR2(4000);
BEGIN
    
    mcp_toolbox_log('Input parameters - '
                    || 'p_vendor_id: '|| p_vendor_id
                    || ', p_site_name: '|| nvl(p_site_name, 'NULL')
                   ,'DEBUG',NULL,l_program_unit);
                   
                   
    l_site_rec.vendor_id           := p_vendor_id;
    l_site_rec.vendor_site_code    := substr(p_site_name,1,15);
    l_site_rec.org_id              := 204; -- Vision USA Operations
    -- -- B. Site Naming & Address
    l_site_rec.address_line1    := 'address line 1';
    l_site_rec.city             := 'City';
    l_site_rec.state            := '';
    l_site_rec.zip              := '';
    l_site_rec.country          := 'US';
    --Site Purposes (Crucial for Invoicing)
    l_site_rec.purchasing_site_flag  := 'Y';
    l_site_rec.pay_site_flag         := 'Y'; -- MUST BE 'Y' to create an AP Invoice!
    l_site_rec.primary_pay_site_flag := 'Y';
    
   
    mcp_toolbox_log('ap_vendor_pub_pkg.create_vendor_site ' || p_vendor_id || ' - ' || 'CALLING','DEBUG',NULL,l_program_unit);
    ap_vendor_pub_pkg.create_vendor_site(
        p_api_version      => 1.0,
        p_init_msg_list    => fnd_api.g_true,
        p_commit           => fnd_api.g_false,
        p_validation_level => fnd_api.g_valid_level_full,
        p_vendor_site_rec  => l_site_rec,
        x_return_status    => l_return_status,
        x_msg_count        => l_msg_count,
        x_msg_data         => l_msg_data,
        x_vendor_site_id   => l_vendor_site_id,
        x_party_site_id    => l_party_site_id,
        x_location_id      => l_location_id
    );
    mcp_toolbox_log('ap_vendor_pub_pkg.create_vendor_site ' || p_vendor_id || ' - ' || l_msg_data,'DEBUG',NULL,l_program_unit);
    IF l_return_status = fnd_api.g_ret_sts_success THEN
        COMMIT;
--        l_return_value := '{"STATUS":"SUCCESS","VENDOR_SITE_ID":"'||l_vendor_site_id||'"}';
        mcp_toolbox_log('Vendor site created for ' || p_vendor_id || ' - ' || p_site_name,'DEBUG',NULL,l_program_unit);
        l_return_value := l_vendor_site_id;
        
    ELSE
        -- Helper to extract and print multiple error messages if they exist
        IF l_msg_count > 1 THEN
            FOR i IN 1..l_msg_count LOOP
                l_msg_data := i||'='||l_msg_data||'; '||fnd_msg_pub.get(p_msg_index => i, p_encoded => fnd_api.g_false);
                DBMS_OUTPUT.PUT_LINE('Error ' || i || ': ' || l_msg_data);
                mcp_toolbox_log('Vendor site error 1 for ' || p_vendor_id || ' - ' || l_msg_data,'ERROR',NULL,l_program_unit);
            END LOOP;
--            l_return_value := '{"STATUS":"ERROR","MESSAGE":"Something went wrong calling create_vendor_site. Error count '||l_msg_data||'"}';
            l_return_value := NULL;
        ELSE
--            DBMS_OUTPUT.PUT_LINE('Error Creating Site: ' || l_msg_data);
--            l_return_value := '{"STATUS":"ERROR","MESSAGE":"Error Creating Site: '||l_msg_data||'"}';
            mcp_toolbox_log('Vendor site error 2 for ' || p_vendor_id || ' - ' || l_msg_data,'ERROR',NULL,l_program_unit);
            l_return_value := NULL;
        END IF;
        ROLLBACK;
    END IF;
    
    RETURN l_return_value;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        l_sqlerrm:=SQLERRM;
--        l_return_value := '{"STATUS":"ERROR","MESSAGE":"Unexpected Error in create_supplier_site: ' || l_sqlerrm||'"}';  
        l_return_value := NULL;
        mcp_toolbox_log('Vendor site error 3 for ' || p_vendor_id || ' - ' || l_sqlerrm,'ERROR',NULL,l_program_unit);
        RETURN l_return_value;
END create_supplier_site;

FUNCTION create_ap_invoice (
        p_vendor_id      IN NUMBER,
        p_invoice_num    IN VARCHAR2,
        p_amount         IN NUMBER,
        p_supplier_site  IN VARCHAR2 DEFAULT NULL,
        p_description    IN VARCHAR2 DEFAULT NULL
    ) RETURN VARCHAR2
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        
        l_program_unit varchar2(100) := 'create_ap_invoice';
        l_sqlerrm varchar2(4000);
        
    -- 1. Session Initialization Variables (Standard Vision Ops)
        l_user_id         NUMBER := fnd_global.user_id;
        l_resp_id         NUMBER := fnd_global.resp_id;
        l_resp_appl_id    NUMBER := fnd_global.resp_appl_id;
        l_org_id          NUMBER := 204; -- Vision Operations (USA)

    -- 2. Invoice Data Variables
        l_source          VARCHAR2(50) := 'MANUAL INVOICE ENTRY';
        l_invoice_date    DATE := trunc(sysdate); 

    -- 3. Sequence & Request Variables
        l_invoice_id      NUMBER;
        l_invoice_line_id NUMBER;
        l_group_id        VARCHAR2(50);
        l_request_id      NUMBER;
        
        l_vendor_id       NUMBER;
        l_vendor_site_id  NUMBER;
        l_default_site    VARCHAR2(100) := 'Gemini default site for '||p_vendor_id;
        l_return_value    VARCHAR2(4000);
    BEGIN
    
    mcp_toolbox_log('Input parameters - '
                    || 'p_vendor_id: '|| p_vendor_id
                    || ', p_invoice_num: '|| nvl(p_invoice_num, 'NULL')
                    || ', p_amount: '|| nvl(p_amount,0)
                    || ', p_supplier_site: '||nvl(p_supplier_site, 'NULL')
                    || ', p_description: '||nvl(p_description, 'NULL')
                   ,'DEBUG',NULL,l_program_unit);
                   
                   
    -- ==========================================
    -- STEP 1: Site management
    -- ==========================================
   if p_supplier_site is not null
   then
       mcp_toolbox_log('Looking up site : '||p_vendor_id||' - '||p_supplier_site,'DEBUG',NULL,l_program_unit);
       BEGIN
        select VENDOR_SITE_ID
          INTO l_vendor_site_id
          from AP_SUPPLIER_SITES
         where VENDOR_ID=p_vendor_id
         and (UPPER(VENDOR_SITE_CODE) like upper('%'||p_supplier_site||'%') or upper(VENDOR_SITE_CODE_ALT) like upper('%'||p_supplier_site||'%'))
         order by VENDOR_SITE_ID
         fetch first 1 rows only;
        EXCEPTION 
            WHEN NO_DATA_FOUND 
            THEN 
                l_vendor_site_id := NULL;
                mcp_toolbox_log('Site ID not found for : '||p_vendor_id||' - '||p_supplier_site,'DEBUG',NULL,l_program_unit);
        
        END;
    end if;
    
    IF l_vendor_site_id IS NULL
    THEN
        --Let's check if default site already exists
        BEGIN
        select VENDOR_SITE_ID
          INTO l_vendor_site_id
          from AP_SUPPLIER_SITES
         where VENDOR_ID=p_vendor_id
         and (UPPER(VENDOR_SITE_CODE) = upper(l_default_site) )
         order by VENDOR_SITE_ID
         fetch first 1 rows only;
        EXCEPTION 
            WHEN NO_DATA_FOUND 
            THEN 
                l_vendor_site_id := NULL;
                mcp_toolbox_log('Site ID not found for : '||p_vendor_id||' - '||l_default_site,'DEBUG',NULL,l_program_unit);
        
        END;
        if l_vendor_site_id is null
        then    
            l_vendor_site_id := create_supplier_site(p_vendor_id,nvl(p_supplier_site,l_default_site));
            mcp_toolbox_log('Site created for : '||p_vendor_id||' - '||nvl(p_supplier_site,l_default_site),'INFO',NULL,l_program_unit);
        end if;
    END IF;
    
    IF l_vendor_site_id is null
    then
        mcp_toolbox_log('Vendor site not found '||nvl(p_supplier_site,l_default_site),'INFO',NULL,l_program_unit);
        RAISE_APPLICATION_ERROR(-20000,'Vendor site not found '||nvl(p_supplier_site,l_default_site));
    end if;

    -- ==========================================
    -- STEP 2: Generate IDs & Group Batch
    -- ==========================================
        SELECT
            ap_invoices_interface_s.NEXTVAL,
            ap_invoice_lines_interface_s.NEXTVAL
        INTO 
            l_invoice_id,
            l_invoice_line_id
        FROM
            dual;

        l_group_id := 'GRP-' || l_invoice_id; 

    -- ==========================================
    -- STEP 3: Insert into Header Interface
    -- ==========================================
    
        INSERT INTO ap_invoices_interface (
            invoice_id,
            invoice_num,
            vendor_id,
            vendor_site_id,
            invoice_amount,
            invoice_currency_code,
            invoice_date,
            gl_date,
            description,
            source,
            group_id,
            org_id,
            creation_date,
            created_by
        ) VALUES ( l_invoice_id,
                   p_invoice_num,
                   p_vendor_id,
                   l_vendor_site_id,
                   p_amount,
                   'USD', -- Vision Operations USA Currency
                   l_invoice_date,
                   l_invoice_date,
                   'Backend Created Invoice - ' || p_invoice_num,
                   l_source,
                   l_group_id,
                   l_org_id,
                   sysdate,
                   l_user_id );
    mcp_toolbox_log('Inserted invoice ' || p_invoice_num || ' - ' || l_invoice_id,'DEBUG',NULL,l_program_unit);
    -- ==========================================
    -- STEP 4: Insert into Lines Interface
    -- ==========================================
        INSERT INTO ap_invoice_lines_interface (
            invoice_id,
            invoice_line_id,
            line_number,
            line_type_lookup_code,
            amount,
            description,
            org_id,
            creation_date,
            created_by
        ) VALUES ( l_invoice_id,
                   l_invoice_line_id,
                   1,
                   'ITEM',
                   p_amount,
                   nvl(p_description,'Line 1 for ') || p_invoice_num,
                   l_org_id,
                   sysdate,
                   l_user_id );
    mcp_toolbox_log('Inserted invoice line' || p_invoice_num || ' - ' || l_invoice_line_id,'DEBUG',NULL,l_program_unit);

    -- ==========================================
    -- STEP 5: Submit the Concurrent Request
    -- ==========================================
    -- APXIIMPT Arguments: Org_id, Source, Group_id, etc.
        l_request_id := fnd_request.submit_request(
            application => 'SQLAP',
            program     => 'APXIIMPT',
--            start_time  => NULL,
--            sub_request => FALSE,
            argument1   => l_org_id,
            argument2   => l_source,
            argument3   => l_group_id, -- Passing Group ID to process only this batch
--            argument4   => NULL,
--            argument5   => NULL,
--            argument6   => NULL,
--            argument7   => NULL,
            argument8   => 'N', -- Summarize Report
            argument9   => 'Y'  -- Commit Cycles
        );
    mcp_toolbox_log('Submitted invoice ' || p_invoice_num || ' - ' || l_group_id,'DEBUG',NULL,l_program_unit);

    -- ==========================================
    -- STEP 6: Handle Submission Results
    -- ==========================================
        IF l_request_id > 0 THEN
--            dbms_output.put_line('Success! Invoice '
--                                 || p_invoice_num
--                                 || ' loaded. Request ID: '
--                                 || l_request_id);
            mcp_toolbox_log('Success! Invoice ' || p_invoice_num || ' loaded. Request ID: ' || l_request_id,'INFO',NULL,l_program_unit);
            COMMIT;
            l_return_value := '{"STATUS":"SUCCESS","MESSAGE":[{"REQUEST_ID":"'||l_request_id||'"},{"INVOICE_ID":"'||l_invoice_id||'"},{"INVOICE_LINE_ID":"'||l_invoice_line_id||'"},{"VENDOR_SITE_ID":"'||l_vendor_site_id||'"}]}';            
        ELSE
            ROLLBACK;
            l_return_value := '{"STATUS":"ERROR","MESSAGE":"Data inserted, but failed to submit concurrent request"}';   
            mcp_toolbox_log('Data inserted, but failed to submit concurrent request','ERROR',NULL,l_program_unit);
        END IF;
    RETURN l_return_value;
    
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            l_sqlerrm:=SQLERRM;
            l_return_value := '{"STATUS":"ERROR","MESSAGE":"Unexpected Error in create_ap_invoice: ' || l_sqlerrm||'"}'; 
            mcp_toolbox_log('Unexpected Error in create_ap_invoice: ' || l_sqlerrm,'ERROR',NULL,l_program_unit);
            RETURN l_return_value;
    END create_ap_invoice;

end ge_ebs_mcp_tools;
