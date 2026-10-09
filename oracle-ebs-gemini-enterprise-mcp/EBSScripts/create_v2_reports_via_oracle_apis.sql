SET DEFINE OFF
SET SQLBLANKLINES ON
SET ECHO ON
SET FEEDBACK ON
SET SERVEROUTPUT ON SIZE 1000000
WHENEVER SQLERROR EXIT FAILURE

-- ============================================================================
-- ORACLE EBS 12.2.15 — OFFICIAL ORACLE PL/SQL API & OPEN INTERFACE LOADER (-V2)
-- Creates Synthetic Government Expense Reports & Grant Invoices strictly via:
--   1. APPS.AP_WEB_DB_EXPRPT_PKG.GetNextExpReportID (Oracle Internet Expenses Sequence API)
--   2. APPS.AP_EXPENSE_REPORT_HEADERS_PKG.Insert_Row (Oracle Payables/OIE Header Table Handler API)
--   3. APPS.AP_WEB_DB_EXPRPT_PKG.SetWkflApprvdFlagAndSource & SetAmtDuesAndTotal (Oracle OIE APIs)
--   4. APPS.AP_WEB_DB_EXPLINE_PKG.InsertLine (Oracle OIE Line Item API)
--   5. APPS.AP_WEB_DB_EXPDIST_PKG.updateDistAcctValuesForForms (Oracle OIE GL Distribution API)
--   6. APPS.AP_WEB_EXPENSE_WF.StartExpenseReportProcess (Oracle OIE Workflow Submission API)
--   7. APPS.AP_WEB_AUDIT_PROCESS.process_expense_report (Oracle OIE Audit Rule Engine API)
--   8. APPS.AP_WEB_AUDIT_QUEUE_UTILS.enqueue_for_audit (Oracle OIE Auditor Queue API)
--   9. APPS.FND_WEBATTCH.ADD_ATTACHMENT (Oracle AOL Document Attachment API)
--  10. APPS.GE_EBS_MCP_TOOLS.create_ap_invoice -> AP_INVOICES_INTERFACE + APXIIMPT Concurrent Request
-- ZERO direct INSERT/UPDATE/DELETE statements on base EBS tables.
-- ============================================================================

DECLARE
  l_user_id          NUMBER := 1318; -- OPERATIONS
  l_resp_id          NUMBER := 50554; -- Payables, Vision Operations (USA)
  l_resp_appl_id     NUMBER := 200; -- SQLAP
  l_org_id           NUMBER := 204; -- Vision Operations
  l_sob_id           NUMBER := 1;
  l_emp_id           NUMBER := 32; -- Frost, Mr. Jamie (Vision Operations Employee)
  l_template_id      NUMBER := 10024; -- Vision Operations WebExpense Template
  l_ccid             NUMBER;
  l_vendor_id        NUMBER;
  l_vendor_site_code VARCHAR2(15);
  l_rowid            VARCHAR2(100);
  l_hdr_id_atl       NUMBER;
  l_hdr_id_den       NUMBER;
  l_hdr_id_chi       NUMBER;
  l_bool             BOOLEAN;
  l_media_id         NUMBER;
  l_folio_clob       CLOB;
  l_inv_res          VARCHAR2(4000);

  PROCEDURE add_oie_line(
    p_hdr_id      IN NUMBER,
    p_line_num    IN NUMBER,
    p_amount      IN NUMBER,
    p_desc        IN VARCHAR2,
    p_justif      IN VARCHAR2,
    p_web_param   IN NUMBER,
    p_cat_code    IN VARCHAR2,
    p_start_date  IN DATE,
    p_end_date    IN DATE
  ) IS
    l_line_rec APPS.AP_EXPENSE_REPORT_LINES_ALL%ROWTYPE;
  BEGIN
    l_line_rec.report_header_id         := p_hdr_id;
    l_line_rec.distribution_line_number := p_line_num;
    l_line_rec.amount                   := p_amount;
    l_line_rec.submitted_amount         := p_amount;
    l_line_rec.daily_amount             := p_amount;
    l_line_rec.receipt_currency_amount  := p_amount;
    l_line_rec.currency_code            := 'USD';
    l_line_rec.receipt_currency_code    := 'USD';
    l_line_rec.receipt_conversion_rate  := 1;
    l_line_rec.line_type_lookup_code    := 'ITEM';
    l_line_rec.item_description         := p_desc;
    l_line_rec.justification            := p_justif;
    l_line_rec.web_parameter_id         := p_web_param;
    l_line_rec.category_code            := p_cat_code;
    l_line_rec.code_combination_id      := l_ccid;
    l_line_rec.set_of_books_id          := l_sob_id;
    l_line_rec.org_id                   := l_org_id;
    l_line_rec.start_expense_date       := p_start_date;
    l_line_rec.end_expense_date         := p_end_date;
    l_line_rec.itemization_parent_id    := -1;
    l_line_rec.creation_date            := SYSDATE;
    l_line_rec.created_by               := l_user_id;
    l_line_rec.last_update_date         := SYSDATE;
    l_line_rec.last_updated_by          := l_user_id;
    l_line_rec.last_update_login        := 0;

    APPS.AP_WEB_DB_EXPLINE_PKG.InsertLine(expense_line_rec => l_line_rec);
  END add_oie_line;

  PROCEDURE submit_and_audit_oie_report(
    p_hdr_id   IN NUMBER,
    p_inv_num  IN VARCHAR2,
    p_total    IN NUMBER,
    p_week_end IN DATE DEFAULT DATE '2026-03-31',
    p_purpose  IN VARCHAR2 DEFAULT 'Government Official Travel Expense Report'
  ) IS
    l_audit_ret VARCHAR2(200);
  BEGIN
    -- 1. Generate GL Account Distributions in AP_EXP_REPORT_DISTS_ALL via Official OIE Distribution API
    APPS.AP_WEB_DB_EXPDIST_PKG.updateDistAcctValuesForForms(
      p_report_header_id => p_hdr_id
    );

    -- 2. Start Official OIE Expense Report Workflow (sets EXPENSE_STATUS_CODE = 'PENDMGR', creates WF_ITEMS)
    APPS.AP_WEB_EXPENSE_WF.StartExpenseReportProcess(
      p_report_header_id => p_hdr_id,
      p_preparer_id      => l_emp_id,
      p_employee_id      => l_emp_id,
      p_document_number  => p_inv_num,
      p_total            => p_total,
      p_new_total        => p_total,
      p_reimb_curr       => 'USD',
      p_cost_center      => '110',
      p_purpose          => p_purpose,
      p_approver_id      => NULL,
      p_week_end_date    => p_week_end,
      p_workflow_flag    => 'M',
      p_submit_from_oie  => APPS.AP_WEB_EXPENSE_WF.C_SUBMIT_FROM_OIE,
      p_event_raised     => 'N'
    );

    -- 3. Evaluate Official OIE Audit Rules (sets AUDIT_CODE = 'PAPERLESS_AUDIT')
    l_audit_ret := APPS.AP_WEB_AUDIT_PROCESS.process_expense_report(
      p_report_header_id => p_hdr_id
    );

    -- 4. Enqueue Report into Official OIE Auditor Queue (AP_AUD_QUEUES)
    APPS.AP_WEB_AUDIT_QUEUE_UTILS.enqueue_for_audit(
      p_report_header_id => p_hdr_id
    );

    DBMS_OUTPUT.PUT_LINE('Submitted & Enqueued ' || p_inv_num || ' (ID=' || p_hdr_id || ') | Audit Tag=' || l_audit_ret);
  END submit_and_audit_oie_report;

  PROCEDURE create_oie_report(
    p_inv_num     IN VARCHAR2,
    p_week_end    IN DATE,
    p_total       IN NUMBER,
    p_desc        IN VARCHAR2,
    p_folio_text  IN VARCHAR2,
    p_out_hdr_id  OUT NUMBER
  ) IS
  BEGIN
    l_bool := APPS.AP_WEB_DB_EXPRPT_PKG.GetNextExpReportID(p_out_hdr_id);
    l_rowid := NULL;

    APPS.AP_EXPENSE_REPORT_HEADERS_PKG.Insert_Row(
      X_Rowid                        => l_rowid,
      X_Report_Header_Id             => p_out_hdr_id,
      X_Employee_Id                  => l_emp_id,
      X_Week_End_Date                => p_week_end,
      X_Creation_Date                => SYSDATE,
      X_Created_By                   => l_user_id,
      X_Last_Update_Date             => SYSDATE,
      X_Last_Updated_By              => l_user_id,
      X_Vouchno                      => 0,
      X_Total                        => p_total,
      X_Vendor_Id                    => NULL,
      X_Vendor_Site_Id               => NULL,
      X_Expense_Check_Address_Flag   => 'H',
      X_Reference_1                  => NULL,
      X_Reference_2                  => NULL,
      X_Invoice_Num                  => p_inv_num,
      X_Expense_Report_Id            => l_template_id,
      X_Accts_Pay_Code_Combinat_Id   => l_ccid,
      X_Set_Of_Books_Id              => l_sob_id,
      X_Source                       => 'WebExpense',
      X_Purgeable_Flag               => 'N',
      X_Accounting_Date              => p_week_end,
      X_Employee_Ccid                => l_ccid,
      X_Description                  => p_desc,
      X_Reject_Code                  => NULL,
      X_Hold_Lookup_Code             => NULL,
      X_Attribute_Category           => NULL,
      X_Attribute1                   => NULL,
      X_Attribute2                   => NULL,
      X_Attribute3                   => NULL,
      X_Attribute4                   => NULL,
      X_Attribute5                   => NULL,
      X_Default_Currency_Code        => 'USD',
      X_Default_Exchange_Rate_Type   => 'Corporate',
      X_Default_Exchange_Rate        => 1,
      X_Default_Exchange_Date        => p_week_end,
      X_Payment_Currency_Code        => 'USD',
      X_Payment_Cross_Rate_Type      => NULL,
      X_Payment_Cross_Rate_Date      => p_week_end,
      X_Payment_Cross_Rate           => 1,
      X_Apply_Advances_Flag          => 'N',
      X_Prepay_Num                   => NULL,
      X_Prepay_Dist_Num              => NULL,
      X_Maximum_Amount_To_Apply      => NULL,
      X_Prepay_Gl_Date               => NULL,
      X_Advance_Invoice_To_Apply     => NULL,
      X_Last_Update_Login            => 0,
      X_Voucher_Num                  => NULL,
      X_Attribute11                  => NULL,
      X_Attribute12                  => NULL,
      X_Attribute13                  => NULL,
      X_Attribute14                  => NULL,
      X_Attribute6                   => NULL,
      X_Attribute7                   => NULL,
      X_Attribute8                   => NULL,
      X_Attribute9                   => NULL,
      X_Attribute10                  => NULL,
      X_Attribute15                  => NULL,
      X_Doc_Category_Code            => NULL,
      X_Awt_Group_Id                 => NULL,
      X_Org_Id                       => l_org_id,
      X_Workflow_Approved_Flag       => 'M',
      X_global_attribute_category    => NULL,
      X_global_attribute1            => NULL,
      X_global_attribute2            => NULL,
      X_global_attribute3            => NULL,
      X_global_attribute4            => NULL,
      X_global_attribute5            => NULL,
      X_global_attribute6            => NULL,
      X_global_attribute7            => NULL,
      X_global_attribute8            => NULL,
      X_global_attribute9            => NULL,
      X_global_attribute10           => NULL,
      X_global_attribute11           => NULL,
      X_global_attribute12           => NULL,
      X_global_attribute13           => NULL,
      X_global_attribute14           => NULL,
      X_global_attribute15           => NULL,
      X_global_attribute16           => NULL,
      X_global_attribute17           => NULL,
      X_global_attribute18           => NULL,
      X_global_attribute19           => NULL,
      X_global_attribute20           => NULL,
      X_calling_sequence             => 'OIE_API_SEED_V2',
      X_Report_Submitted_date        => SYSDATE - 1
    );

    -- Official OIE API calls to set Workflow Flag, WebExpense Source, and Employee Amount Due
    l_bool := APPS.AP_WEB_DB_EXPRPT_PKG.SetWkflApprvdFlagAndSource(
      p_report_header_id => p_out_hdr_id,
      p_flag             => 'M',
      p_source           => 'WebExpense'
    );
    l_bool := APPS.AP_WEB_DB_EXPRPT_PKG.SetAmtDuesAndTotal(
      p_report_header_id      => p_out_hdr_id,
      p_amt_due_ccard_company => 0,
      p_amt_due_employee      => p_total,
      p_total                 => p_total
    );

    -- Attach OCR Receipt Folio via official Oracle AOL FND_WEBATTCH.ADD_ATTACHMENT API
    l_media_id := NULL;
    l_folio_clob := p_folio_text;
    APPS.FND_WEBATTCH.ADD_ATTACHMENT(
      seq_num              => '10',
      category_id          => '1',
      document_description => 'Attached Receipt Folio OCR Transcript (' || p_inv_num || ')',
      datatype_id          => '2', -- Long Text
      text                 => l_folio_clob,
      file_name            => p_inv_num || '_FOLIO_OCR.txt',
      url                  => NULL,
      function_name        => 'OIE_AUD_AUDIT_PAGE',
      entity_name          => 'AP_EXPENSE_REPORT_HEADERS',
      pk1_value            => TO_CHAR(p_out_hdr_id),
      pk2_value            => NULL,
      pk3_value            => NULL,
      pk4_value            => NULL,
      pk5_value            => NULL,
      media_id             => l_media_id,
      user_id              => TO_CHAR(l_user_id)
    );
  END create_oie_report;

BEGIN
  -- 1. Initialize Oracle Applications Context & MOAC Policy Context
  APPS.FND_GLOBAL.APPS_INITIALIZE(l_user_id, l_resp_id, l_resp_appl_id);
  APPS.MO_GLOBAL.INIT('SQLAP');
  APPS.MO_GLOBAL.SET_POLICY_CONTEXT('S', l_org_id);

  SELECT MIN(CODE_COMBINATION_ID) INTO l_ccid
  FROM APPS.AP_EXPENSE_REPORT_LINES_ALL
  WHERE REPORT_HEADER_ID = 35989;

  IF l_ccid IS NULL THEN
    SELECT MIN(CODE_COMBINATION_ID) INTO l_ccid
    FROM APPS.GL_CODE_COMBINATIONS
    WHERE ENABLED_FLAG = 'Y' AND DETAIL_POSTING_ALLOWED_FLAG = 'Y';
  END IF;

  -- 2. Create EXP-ATL-9921-V2 via Official Oracle OIE & Payables APIs
  create_oie_report(
    p_inv_num    => 'EXP-ATL-9921-V2',
    p_week_end   => TO_DATE('2026-07-16', 'YYYY-MM-DD'),
    p_total      => 710.00,
    p_desc       => 'Marcus Sterling - DOJ-JUST-2026 Atlanta Criminal Justice Conference (#ATL-9921-V2)',
    p_folio_text => 'FOLIO 1 (API-CREATED V2): EXPENSE REPORT #EXP-ATL-9921-V2 | Claimant: Marcus Sterling | Grant: DOJ-JUST-2026 | Purpose: Criminal Justice Conference in Atlanta, GA (Fulton County), 2026-07-14 to 2026-07-16. GSA Caps: Max Lodging = $185.00/night; Full-Day M&IE = $74.00; Travel Day 75% M&IE = $55.50. Total Claimed: $710.00 | Allowable: $615.50 | Questioned/Unallowable: $94.50 ($14.50 Ribeye M&IE Overage + $35.00 IPA Craft Beer 2 CFR 200.423 + $15.00 Server Gratuity Overage + $30.00 In-Room Movies 2 CFR 200.438).',
    p_out_hdr_id => l_hdr_id_atl
  );

  add_oie_line(l_hdr_id_atl, 1, 370.00, 'Lodging (2 nights @ $185.00/night - Grand Atlanta Hotel #ATL-9921-V2)', 'Matches GSA Atlanta Fulton County cap of $185.00/night (2 CFR 200.475(d))', 10006, 'ACCOMMODATIONS', TO_DATE('2026-07-14','YYYY-MM-DD'), TO_DATE('2026-07-16','YYYY-MM-DD'));
  add_oie_line(l_hdr_id_atl, 2,  50.00, 'State & City Lodging Tax (2 nights @ $25.00/night)', 'Mandatory municipal lodging tax on allowable room rate (2 CFR 200.475(d))', 10006, 'ACCOMMODATIONS', TO_DATE('2026-07-14','YYYY-MM-DD'), TO_DATE('2026-07-16','YYYY-MM-DD'));
  add_oie_line(l_hdr_id_atl, 3,  70.00, 'Room Service Dinner Entree: Ribeye Steak (Travel Day 2026-07-14)', 'GSA Travel Day 75% M&IE cap is $55.50 ($74.00 full day); $14.50 overage questioned', 10009, 'MEALS', TO_DATE('2026-07-14','YYYY-MM-DD'), TO_DATE('2026-07-14','YYYY-MM-DD'));
  add_oie_line(l_hdr_id_atl, 4,  35.00, 'Room Service Beverage: Local IPA Craft Beer (2026-07-14)', 'Alcoholic beverage on hotel folio (Strictly Unallowable under 2 CFR 200.423)', 10009, 'MEALS', TO_DATE('2026-07-14','YYYY-MM-DD'), TO_DATE('2026-07-14','YYYY-MM-DD'));
  add_oie_line(l_hdr_id_atl, 5,  15.00, 'Room Service Server Gratuity (2026-07-14)', 'Daily M&IE allowance ($55.50) already absorbed by food charge; $15.00 overage unallowable', 10009, 'MEALS', TO_DATE('2026-07-14','YYYY-MM-DD'), TO_DATE('2026-07-14','YYYY-MM-DD'));
  add_oie_line(l_hdr_id_atl, 6,  30.00, 'In-Room Movie Rentals: Blockbuster HD 1 & 2 (2026-07-15)', 'In-room entertainment charges (Strictly Unallowable under 2 CFR 200.438)', 10009, 'MEALS', TO_DATE('2026-07-15','YYYY-MM-DD'), TO_DATE('2026-07-15','YYYY-MM-DD'));
  add_oie_line(l_hdr_id_atl, 7, 140.00, 'Overnight Hotel Valet Parking (2 nights @ $70.00/night)', 'Necessary conference lodging parking (Allowable under 2 CFR 200.475)', 10007, 'MEALS', TO_DATE('2026-07-14','YYYY-MM-DD'), TO_DATE('2026-07-16','YYYY-MM-DD'));
  submit_and_audit_oie_report(l_hdr_id_atl, 'EXP-ATL-9921-V2', 710.00);

  DBMS_OUTPUT.PUT_LINE('Created EXP-ATL-9921-V2 via Official OIE API -> REPORT_HEADER_ID = ' || l_hdr_id_atl);

  -- 3. Create EXP-DEN-5521-V2 via Official Oracle OIE & Payables APIs
  create_oie_report(
    p_inv_num    => 'EXP-DEN-5521-V2',
    p_week_end   => TO_DATE('2026-05-14', 'YYYY-MM-DD'),
    p_total      => 1629.00,
    p_desc       => 'Dr. Aris Thorne - NSF-ENG-2025-44 Denver Advanced Materials Symposium (#UA-5521-V2)',
    p_folio_text => 'FOLIO 2 (API-CREATED V2): EXPENSE REPORT #EXP-DEN-5521-V2 | Claimant: Dr. Aris Thorne | Grant: NSF-ENG-2025-44 | Purpose: Advanced Materials Symposium, Denver, CO (2026-05-12 to 2026-05-14). GSA Denver Caps: Lodging = $199.00/night; M&IE = $79.00 (Travel day 75% = $59.25). Total Claimed: $1,629.00 | Allowable: $1,629.00 | Questioned: $0.00 (Allowable in Full).',
    p_out_hdr_id => l_hdr_id_den
  );

  add_oie_line(l_hdr_id_den, 1, 420.00, 'United Airlines E-Ticket #UA-5521 Economy ORD->DEN->ORD', 'Economy airfare allowable under 2 CFR 200.475(e)', 10005, 'AIRFARE', TO_DATE('2026-05-12','YYYY-MM-DD'), TO_DATE('2026-05-14','YYYY-MM-DD'));
  add_oie_line(l_hdr_id_den, 2, 390.00, 'Denver Downtown Hotel #DEN-9011 (2 nights @ $195.00/night)', 'Allowable, below $199.00/night GSA Denver cap (2 CFR 200.475(d))', 10006, 'ACCOMMODATIONS', TO_DATE('2026-05-12','YYYY-MM-DD'), TO_DATE('2026-05-14','YYYY-MM-DD'));
  add_oie_line(l_hdr_id_den, 3, 184.00, 'M&IE Per Diem Subsistence (3 days: $59.25 + $79.00 + $45.75)', 'Allowable, within GSA Denver M&IE schedule (2 CFR 200.475(d))', 10009, 'MEALS', TO_DATE('2026-05-12','YYYY-MM-DD'), TO_DATE('2026-05-14','YYYY-MM-DD'));
  add_oie_line(l_hdr_id_den, 4,  85.00, 'Ground Transportation Uber Receipts ($45.00 + $40.00)', 'Allowable official ground transit (2 CFR 200.475)', 10007, 'MEALS', TO_DATE('2026-05-12','YYYY-MM-DD'), TO_DATE('2026-05-14','YYYY-MM-DD'));
  add_oie_line(l_hdr_id_den, 5, 550.00, 'Conference Registration #AMS-2026-REG', 'Allowable symposium registration fee (2 CFR 200.432)', 10009, 'MEALS', TO_DATE('2026-05-12','YYYY-MM-DD'), TO_DATE('2026-05-14','YYYY-MM-DD'));
  submit_and_audit_oie_report(l_hdr_id_den, 'EXP-DEN-5521-V2', 1629.00);

  DBMS_OUTPUT.PUT_LINE('Created EXP-DEN-5521-V2 via Official OIE API -> REPORT_HEADER_ID = ' || l_hdr_id_den);

  -- 4. Create EXP-CHI-8812-V2 via Official Oracle OIE & Payables APIs
  create_oie_report(
    p_inv_num    => 'EXP-CHI-8812-V2',
    p_week_end   => TO_DATE('2026-06-13', 'YYYY-MM-DD'),
    p_total      => 2370.00,
    p_desc       => 'Dr. Marcus Vance - 2026-HC-9921 Chicago National Healthcare Conference (#DL-8812-V2)',
    p_folio_text => 'FOLIO 3 (API-CREATED V2): EXPENSE REPORT #EXP-CHI-8812-V2 | Claimant: Dr. Marcus Vance | Grant: 2026-HC-9921 | Purpose: Chicago National Healthcare Conference (#DL-8812), 2026-06-10 to 2026-06-13. Total Claimed: $2,370.00.',
    p_out_hdr_id => l_hdr_id_chi
  );

  add_oie_line(l_hdr_id_chi, 1, 680.00, 'Delta Airlines #DL-8812 Roundtrip Airfare', 'Conference air travel (2 CFR 200.475(e))', 10005, 'AIRFARE', TO_DATE('2026-06-10','YYYY-MM-DD'), TO_DATE('2026-06-13','YYYY-MM-DD'));
  add_oie_line(l_hdr_id_chi, 2, 920.00, 'Chicago Magnificent Mile Hotel (3 nights)', 'Conference hotel lodging (2 CFR 200.475(d))', 10006, 'ACCOMMODATIONS', TO_DATE('2026-06-10','YYYY-MM-DD'), TO_DATE('2026-06-13','YYYY-MM-DD'));
  add_oie_line(l_hdr_id_chi, 3, 220.00, 'Chicago Conference Meals & Incidentals (M&IE)', 'Conference subsistence (2 CFR 200.475(d))', 10009, 'MEALS', TO_DATE('2026-06-10','YYYY-MM-DD'), TO_DATE('2026-06-13','YYYY-MM-DD'));
  add_oie_line(l_hdr_id_chi, 4, 550.00, 'National Healthcare Conference Registration Fee', 'Conference registration (2 CFR 200.432)', 10009, 'MEALS', TO_DATE('2026-06-10','YYYY-MM-DD'), TO_DATE('2026-06-13','YYYY-MM-DD'));
  submit_and_audit_oie_report(l_hdr_id_chi, 'EXP-CHI-8812-V2', 2370.00);

  DBMS_OUTPUT.PUT_LINE('Created EXP-CHI-8812-V2 via Official OIE API -> REPORT_HEADER_ID = ' || l_hdr_id_chi);

  -- 5. Create -V2 Grant AP Invoices via Official Payables Open Interface (GE_EBS_MCP_TOOLS.create_ap_invoice -> AP_INVOICES_INTERFACE + APXIIMPT)
  SELECT pv.VENDOR_ID, pvs.VENDOR_SITE_CODE
  INTO l_vendor_id, l_vendor_site_code
  FROM APPS.PO_VENDORS pv
  JOIN APPS.PO_VENDOR_SITES_ALL pvs ON pv.VENDOR_ID = pvs.VENDOR_ID
  WHERE pvs.ORG_ID = 204
    AND pvs.PAY_SITE_FLAG = 'Y'
    AND ROWNUM = 1;

  l_inv_res := APPS.GE_EBS_MCP_TOOLS.create_ap_invoice(
    p_vendor_id     => l_vendor_id,
    p_invoice_num   => 'HM-4409-V2',
    p_amount        => 3800.00,
    p_supplier_site => l_vendor_site_code,
    p_description   => 'Horizon Marketing (Grant HRSA-RURAL-2026): $1,200 Immunization Brochures; $1,600 Branded Swag Totes/Bottles; $1,000 Live Acoustic Quartet'
  );
  DBMS_OUTPUT.PUT_LINE('HM-4409-V2 Open Interface Result: ' || l_inv_res);

  l_inv_res := APPS.GE_EBS_MCP_TOOLS.create_ap_invoice(
    p_vendor_id     => l_vendor_id,
    p_invoice_num   => 'V-2026-301-V2',
    p_amount        => 1420.00,
    p_supplier_site => l_vendor_site_code,
    p_description   => 'Apex Office Supplies (Grant CDC-CHRONIC-2026, 48% MTDC NICRA): $600 Copy Paper, $520 Laser Toner, $300 General Desk Stationery'
  );
  DBMS_OUTPUT.PUT_LINE('V-2026-301-V2 Open Interface Result: ' || l_inv_res);

  l_inv_res := APPS.GE_EBS_MCP_TOOLS.create_ap_invoice(
    p_vendor_id     => l_vendor_id,
    p_invoice_num   => 'MS-1049-V2',
    p_amount        => 34500.00,
    p_supplier_site => l_vendor_site_code,
    p_description   => 'Marine Sensors Corp (PO-7801 / Grant NOAA-OCEAN-2025-12): Deep-Sea Temperature Probes Model X7 ($34,500 Sole Source without competitive quotes)'
  );
  DBMS_OUTPUT.PUT_LINE('MS-1049-V2 Open Interface Result: ' || l_inv_res);

  COMMIT;
END;
/
EXIT;
