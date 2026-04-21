create or replace package ge_ebs_mcp_tools
as
function ebs_initialize_context (
    p_email_address             VARCHAR2,
    p_operating_unit            VARCHAR2 DEFAULT NULL,
    p_responsibility            VARCHAR2 DEFAULT NULL,
    p_application_short_name    VARCHAR2 DEFAULT NULL
) return VARCHAR2;


FUNCTION reserve_item (
    p_item varchar2,
    p_quantity number default 1,
    p_location varchar2 default null,
    p_sub_inventory varchar2 := 'Stores'
) return VARCHAR2;

/*  create_onhand This function is a wrapper for an Oracle Inventory Miscellaneous Receipt. Its job is to manually create stock (on-hand quantity) into a specific warehouse location for a specific item.
    populates data to mtl_transactions_interface and calls INV_TXN_MANAGER_PUB.process_Transactions immediately onhand created
*/

FUNCTION create_onhand (
    p_item           VARCHAR2,
    p_quantity       NUMBER,
    p_location       VARCHAR2, -- Org Code (e.g., 'S1')
    p_sub_inventory  VARCHAR2 DEFAULT 'Stores'
    --p_account_id     NUMBER   DEFAULT NULL -- Optional CCID
) return VARCHAR2;

FUNCTION delete_reservation (
    p_reservation_id NUMBER
) return VARCHAR2;

    -- Procedure to create a Supplier/Vendor for invoices
    -- Returns x_vendor_id to be used in site creation
    FUNCTION create_supplier (
        p_vendor_name IN  VARCHAR2,
        p_site_name   IN VARCHAR2 default NULL,
        p_tax_reg_num IN  VARCHAR2 default NULL
    ) RETURN VARCHAR2;

    -- Procedure to create AP Invoice
    FUNCTION create_ap_invoice (
        p_vendor_id      IN NUMBER,
        p_invoice_num    IN VARCHAR2,
        p_amount         IN NUMBER,
        p_supplier_site  IN VARCHAR2 DEFAULT NULL,
        p_description    IN VARCHAR2 DEFAULT NULL
    )RETURN VARCHAR2;

end ge_ebs_mcp_tools;
/

grant execute on apps.ge_ebs_mcp_tools to apps_ai;
