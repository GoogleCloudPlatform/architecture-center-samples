--calculates the Available to Transact (ATT) by subtracting the reserved quantities from the total on-hand.
--In EBS R12, the MTL_RESERVATIONS table holds the "locks," while MTL_ONHAND_QUANTITIES_DETAIL holds the physical stock.
SELECT 
    msi.segment1 AS item_number,
    mp.organization_code AS org,
    moq.subinventory_code AS subinv,
    -- Total Physical Stock
    SUM(moq.transaction_quantity) AS on_hand_qty,
    -- Total Reservations
    NVL((SELECT SUM(primary_reservation_quantity)
         FROM   mtl_reservations mr
         WHERE  mr.inventory_item_id = msi.inventory_item_id
         AND    mr.organization_id = msi.organization_id
         AND    mr.subinventory_code = moq.subinventory_code), 0) AS reserved_qty,
    -- Simple Math for Availability
    (SUM(moq.transaction_quantity) - 
     NVL((SELECT SUM(primary_reservation_quantity)
          FROM   mtl_reservations mr
          WHERE  mr.inventory_item_id = msi.inventory_item_id
          AND    mr.organization_id = msi.organization_id
          AND    mr.subinventory_code = moq.subinventory_code), 0)) AS available_to_transact
FROM 
    mtl_system_items_b msi,
    mtl_onhand_quantities_detail moq,
    mtl_parameters mp
WHERE 
    msi.inventory_item_id = moq.inventory_item_id
AND msi.organization_id = moq.organization_id
AND msi.organization_id = mp.organization_id
AND msi.segment1 = 'O-rings'
--AND mp.organization_code = 'S1' -- Chicago Org
AND moq.subinventory_code = 'Stores'
GROUP BY 
    msi.segment1, 
    mp.organization_code, 
    moq.subinventory_code,
    msi.inventory_item_id,
    msi.organization_id;