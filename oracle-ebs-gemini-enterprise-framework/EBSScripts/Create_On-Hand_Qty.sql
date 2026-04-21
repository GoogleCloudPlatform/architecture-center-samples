DECLARE
    l_item_id        NUMBER;
    l_inv_org_id         NUMBER := 208; -- Replace with your Organization_ID
    l_account_id     NUMBER := 17347; -- Miscellaneous transaction CCID (Distribution Account)
    l_user_id        NUMBER := fnd_global.user_id; --1014748;
    l_login_id       NUMBER := fnd_global.login_id; --7309063; --
    l_trans_type_id  NUMBER := 42; -- Miscellaneous Receipt
     l_quantity      NUMBER:= 1; -- onhand quantity to b ecreated
     l_Subinventory  VARCHAR2(40) := 'Stores';
     l_part_number  VARCHAR2(40) := 'O-rings';
    l_iface_id       NUMBER;

BEGIN
    -- 1. Get Item ID for "O-ring"
    SELECT inventory_item_id 
    INTO   l_item_id
    FROM   mtl_system_items_b
    WHERE  segment1 = l_part_number 
    AND    organization_id = l_org_id;

    -- 2. Get Next Sequence for Interface ID
    SELECT MTL_CROSS_REF_INTERFACE_S.NEXTVAL  
    INTO   l_iface_id 
    FROM   dual;

    -- 3. Insert into Interface Table
    INSERT INTO mtl_transactions_interface (
        transaction_interface_id,
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
        transaction_type_id,
        distribution_account_id,
        last_update_login
    ) VALUES (
        l_iface_id,
        'PLSQL_UPLOAD',
        1,
        1,
        1,         -- Pending
        3,         -- Background processing
        SYSDATE,
        l_user_id,
        SYSDATE,
        l_user_id,
        l_item_id,
        l_inv_org_id,
        l_Subinventory,  -- Subinventory
        l_quantity,         -- Quantity
        'Ea',      -- Ensure this UOM is valid for your item
        SYSDATE-5700,
        l_trans_type_id,
        l_account_id,
        l_login_id
    );

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Transaction Inserted into Interface. ID: ' || l_iface_id);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK;
END;
