DECLARE
    -- API Variables
    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);
    l_rsv_id             NUMBER;
    l_qty_reserved       NUMBER;
    l_dummy_sn           inv_reservation_global.serial_number_tbl_type;
    l_rsv_rec            inv_reservation_global.mtl_reservation_rec_type;
    
    -- Input Variables
    l_item_name          VARCHAR2(100) := 'O-rings'; -- item or part number
    l_org_code           VARCHAR2(3)   := 'S1'; -- Change to your Chicago Org Code
    l_subinv             VARCHAR2(30)  := 'Stores'; -- defualt to stores 
    l_qty                NUMBER        := 1; -- default taken 1 qty
    
    -- System IDs
    l_item_id            NUMBER;
    l_org_id             NUMBER;
    l_user_id            NUMBER := fnd_global.user_id;

BEGIN
    -- 1. Get IDs from Base Tables
    BEGIN
        SELECT mp.organization_id, msi.inventory_item_id
        INTO   l_org_id, l_item_id
        FROM   mtl_parameters mp, mtl_system_items_b msi
        WHERE  mp.organization_code = l_org_code
        AND    msi.organization_id  = mp.organization_id
        AND    msi.segment1         = l_item_name
        AND    msi.reservable_type  = 1; -- Ensure item is reservable
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Error: Item or Organization not found/reservable.');
            RETURN;
    END;

    -- 2. Initialize Reservation Record (Critical for R12)
    -- We set everything to NULL first to avoid junk values in the record
    l_rsv_rec := NULL;

    l_rsv_rec.reservation_id            := NULL; -- Generating new
    l_rsv_rec.organization_id           := l_org_id;
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
        DBMS_OUTPUT.PUT_LINE('Success!');
        DBMS_OUTPUT.PUT_LINE('Reservation ID: ' || l_rsv_id);
        DBMS_OUTPUT.PUT_LINE('Quantity Reserved: ' || l_qty_reserved);
    ELSE
        -- Detailed Error Logging
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('API Failed with status: ' || l_return_status);
        FOR i IN 1..l_msg_count LOOP
            l_msg_data := fnd_msg_pub.get(p_msg_index => i, p_encoded => 'F');
            DBMS_OUTPUT.PUT_LINE('Error ' || i || ': ' || l_msg_data);
        END LOOP;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('System Error: ' || SQLERRM);
END;
/