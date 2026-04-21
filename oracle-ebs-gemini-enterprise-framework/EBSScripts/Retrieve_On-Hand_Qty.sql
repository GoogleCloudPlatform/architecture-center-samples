SELECT msib.segment1            AS item_number,
       msib.description         AS item_description,
       msi.organization_code    AS org_code,
       moqd.subinventory_code   AS subinventory,
       moqd.locator_id,
       moqd.lot_number,
       moqd.primary_transaction_quantity AS onhand_qty,
       moqd.creation_date
FROM   mtl_onhand_quantities_detail moqd,
       mtl_system_items_b msib,
       mtl_parameters msi
WHERE  moqd.inventory_item_id = msib.inventory_item_id
AND    moqd.organization_id   = msib.organization_id
AND    moqd.organization_id   = msi.organization_id
AND    msib.segment1          = :l_part_number  -- Replace with your item O-rings
AND    msi.organization_code  like  :l_organization_code;  -- Replace with your org ex - chicago is  S1 
