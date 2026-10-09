-- Stub JD Edwards EnterpriseOne 9.2 tables for scripts/test_stub_jde.py.
-- Only the columns the jde/sql tools and jde/stub/seed.sql use. Names, types and lengths
-- follow the JDE 9.2 data dictionary for a Unicode database: strings are NCHAR/NVARCHAR2,
-- dates are NUMBER (Julian CYYDDD), amounts NUMBER with implied decimals (noted as .n).
-- Defaults mirror how JDE stores empty values (blank or zero).
-- If a tool needs a column that is missing here, add it (check the JDE data dictionary).

CREATE TABLE prodctl.f0004 (  -- User Defined Code Types
    DTSY NCHAR(4) DEFAULT ' ',  -- Product Code
    DTRT NCHAR(2) DEFAULT ' ',  -- User Defined Codes
    DTDL01 NCHAR(30) DEFAULT ' '  -- Description
);

CREATE TABLE prodctl.f0005 (  -- User Defined Codes
    DRSY NCHAR(4) DEFAULT ' ',  -- Product Code
    DRRT NCHAR(2) DEFAULT ' ',  -- User Defined Codes
    DRKY NCHAR(10) DEFAULT ' ',  -- User Defined Code
    DRDL01 NCHAR(30) DEFAULT ' ',  -- Description
    DRDL02 NCHAR(30) DEFAULT ' ',  -- Description 02
    DRSPHD NCHAR(10) DEFAULT ' '  -- Special Handling Code - User Def Codes
);

CREATE TABLE proddta.f0006 (  -- Business Unit Master
    MCMCU NCHAR(12) DEFAULT ' ',  -- Business Unit
    MCSTYL NCHAR(2) DEFAULT ' ',  -- Business Unit Type
    MCCO NCHAR(5) DEFAULT ' ',  -- Company
    MCDL01 NCHAR(30) DEFAULT ' ',  -- Description
    MCPECC NCHAR(1) DEFAULT ' '  -- Posting Edit - Business Unit
);

CREATE TABLE proddta.f0010 (  -- Company Constants
    CCCO NCHAR(5) DEFAULT ' ',  -- Company
    CCNAME NCHAR(30) DEFAULT ' '  -- Name
);

CREATE TABLE proddta.f00165 (  -- Media Objects Storage
    GDOBNM NCHAR(10) DEFAULT ' ',  -- Object Name
    GDTXKY NVARCHAR2(254) DEFAULT ' ',  -- Generic Text Key
    GDMOSEQN NUMBER DEFAULT 0,  -- Media Object Sequence Number
    GDGTMOTYPE NUMBER DEFAULT 0,  -- Generic Text Media Object Type
    GDUSER NCHAR(10) DEFAULT ' ',  -- User ID
    GDUPMJ NUMBER DEFAULT 0,  -- Date - Updated (Julian)
    GDGTITNM NCHAR(50) DEFAULT ' ',  -- Generic Text Item Name
    GDQUNAM NCHAR(30) DEFAULT ' ',  -- Queue Name
    GDGTFILENM NCHAR(254) DEFAULT ' ',  -- Generic Text File Name
    GDTXFT BLOB  -- Generic Text BLOB Buffer
);

CREATE TABLE proddta.f00166 (  -- Media Object Category Codes
    GTOBNM NCHAR(10) DEFAULT ' ',  -- Object Name
    GTTXKY NVARCHAR2(254) DEFAULT ' ',  -- Generic Text Key
    GTMOSEQN NUMBER DEFAULT 0,  -- Media Object Sequence Number
    GTMODOCTP NCHAR(6) DEFAULT ' ',  -- Media Object Document Type
    GTMODL01 NCHAR(30) DEFAULT ' ',  -- Media Object Description
    GTMOAUTHOR NCHAR(40) DEFAULT ' ',  -- Media Object Document Author
    GTMOSTATUS NCHAR(6) DEFAULT ' ',  -- Media Object Status
    GTMOEFDTFR NUMBER DEFAULT 0,  -- Media Object Effective Date - From (Julian)
    GTMOEFDTTO NUMBER DEFAULT 0,  -- Media Object Effective Date - To (Julian)
    GTMOREVDT NUMBER DEFAULT 0,  -- Media Object Review Date (Julian)
    GTAN8 NUMBER DEFAULT 0  -- Address Number
);

CREATE TABLE proddta.f0101 (  -- Address Book Master
    ABAN8 NUMBER DEFAULT 0,  -- Address Number
    ABALKY NCHAR(20) DEFAULT ' ',  -- Long Address Number
    ABTAX NCHAR(20) DEFAULT ' ',  -- Tax ID
    ABALPH NCHAR(40) DEFAULT ' ',  -- Name - Alpha
    ABAT1 NCHAR(3) DEFAULT ' ',  -- Search Type
    ABDUNS NCHAR(13) DEFAULT ' '  -- DUNS Number
);

CREATE TABLE proddta.f0111 (  -- Who's Who
    WWAN8 NUMBER DEFAULT 0,  -- Address Number
    WWIDLN NUMBER DEFAULT 0,  -- Who's Who Line Number - ID
    WWGNNM NCHAR(25) DEFAULT ' ',  -- Name - Given
    WWSRNM NCHAR(25) DEFAULT ' ',  -- Name - Surname
    WWDDATE NUMBER DEFAULT 0,  -- Day of Birth
    WWDMON NUMBER DEFAULT 0,  -- Month of Birth
    WWDYR NUMBER DEFAULT 0  -- Year of Birth
);

CREATE TABLE proddta.f0115 (  -- Phone Numbers
    WPAN8 NUMBER DEFAULT 0,  -- Address Number
    WPIDLN NUMBER DEFAULT 0,  -- Who's Who Line Number - ID
    WPAR1 NCHAR(6) DEFAULT ' ',  -- Phone Prefix
    WPPH1 NCHAR(20) DEFAULT ' '  -- Phone Number
);

CREATE TABLE proddta.f01151 (  -- Electronic Address
    EAAN8 NUMBER DEFAULT 0,  -- Address Number
    EAIDLN NUMBER DEFAULT 0,  -- Who's Who Line Number - ID
    EAETP NCHAR(4) DEFAULT ' ',  -- Electronic Address Type
    EAEMAL NCHAR(256) DEFAULT ' '  -- Electronic Address
);

CREATE TABLE proddta.f0116 (  -- Address by Date
    ALAN8 NUMBER DEFAULT 0,  -- Address Number
    ALEFTB NUMBER DEFAULT 0,  -- Date - Beginning Effective (Julian)
    ALADD1 NCHAR(40) DEFAULT ' ',  -- Address Line 1
    ALADDZ NCHAR(12) DEFAULT ' ',  -- Postal Code
    ALCTY1 NCHAR(25) DEFAULT ' ',  -- City
    ALADDS NCHAR(3) DEFAULT ' '  -- State
);

CREATE TABLE proddta.f03b11 (  -- Customer Ledger
    RPDOC NUMBER DEFAULT 0,  -- Document (Voucher  Invoice  etc.)
    RPDCT NCHAR(2) DEFAULT ' ',  -- Document Type
    RPKCO NCHAR(5) DEFAULT ' ',  -- Document Company
    RPSFX NCHAR(3) DEFAULT ' ',  -- Document Pay Item
    RPAN8 NUMBER DEFAULT 0,  -- Address Number
    RPDGJ NUMBER DEFAULT 0,  -- Date - For G/L (and Voucher) - Julian (Julian)
    RPDIVJ NUMBER DEFAULT 0,  -- Date - Invoice - Julian (Julian)
    RPCO NCHAR(5) DEFAULT ' ',  -- Company
    RPPST NCHAR(1) DEFAULT ' ',  -- Pay Status Code
    RPAG NUMBER DEFAULT 0,  -- Amount - Gross (.2)
    RPAAP NUMBER DEFAULT 0,  -- Amount Open (.2)
    RPCRCD NCHAR(3) DEFAULT ' ',  -- Currency Code - From
    RPMCU NCHAR(12) DEFAULT ' ',  -- Business Unit
    RPDDJ NUMBER DEFAULT 0,  -- Date - Net Due (Julian)
    RPVINV NCHAR(25) DEFAULT ' ',  -- Supplier Invoice Number
    RPVR01 NCHAR(25) DEFAULT ' ',  -- Reference
    RPRMK NCHAR(30) DEFAULT ' '  -- Name - Remark
);

CREATE TABLE proddta.f03b40 (  -- A/R Deductions
    RBDCID NUMBER DEFAULT 0,  -- Deduction ID
    RBPSDD NCHAR(2) DEFAULT ' ',  -- Deduction Status Code
    RBDDOA NUMBER DEFAULT 0,  -- Amount - Open Deduction (.2)
    RBDDA NUMBER DEFAULT 0,  -- Amount - Deduction (.2)
    RBDDEX NCHAR(2) DEFAULT ' ',  -- Deduction Reason Code
    RBDDDO NUMBER DEFAULT 0,  -- Date - Deduction Opened (Julian)
    RBODOC NUMBER DEFAULT 0,  -- Document - Original
    RBODCT NCHAR(2) DEFAULT ' ',  -- Document Type - Original
    RBOSFX NCHAR(3) DEFAULT ' ',  -- Document Pay Item - Original
    RBOKCO NCHAR(5) DEFAULT ' '  -- Document Company (Original Order)
);

CREATE TABLE proddta.f0411 (  -- Supplier Ledger
    RPKCO NCHAR(5) DEFAULT ' ',  -- Document Company
    RPDOC NUMBER DEFAULT 0,  -- Document (Voucher  Invoice  etc.)
    RPDCT NCHAR(2) DEFAULT ' ',  -- Document Type
    RPSFX NCHAR(3) DEFAULT ' ',  -- Document Pay Item
    RPAN8 NUMBER DEFAULT 0,  -- Address Number
    RPDIVJ NUMBER DEFAULT 0,  -- Date - Invoice - Julian (Julian)
    RPDDJ NUMBER DEFAULT 0,  -- Date - Net Due (Julian)
    RPDGJ NUMBER DEFAULT 0,  -- Date - For G/L (and Voucher) - Julian (Julian)
    RPCO NCHAR(5) DEFAULT ' ',  -- Company
    RPPST NCHAR(1) DEFAULT ' ',  -- Pay Status Code
    RPAG NUMBER DEFAULT 0,  -- Amount - Gross (.2)
    RPAAP NUMBER DEFAULT 0,  -- Amount Open (.2)
    RPCRCD NCHAR(3) DEFAULT ' ',  -- Currency Code - From
    RPMCU NCHAR(12) DEFAULT ' ',  -- Business Unit
    RPVINV NCHAR(25) DEFAULT ' ',  -- Supplier Invoice Number
    RPPO NCHAR(8) DEFAULT ' ',  -- Purchase Order
    RPVR01 NCHAR(25) DEFAULT ' ',  -- Reference
    RPRMK NCHAR(30) DEFAULT ' '  -- Name - Remark
);

CREATE TABLE proddta.f060116 (  -- Employee Master
    YAAN8 NUMBER DEFAULT 0,  -- Address Number
    YAALPH NCHAR(40) DEFAULT ' ',  -- Name - Alpha
    YASSN NCHAR(20) DEFAULT ' ',  -- Employee Tax ID
    YAOEMP NCHAR(8) DEFAULT ' ',  -- Additional Employee No
    YASEX NCHAR(1) DEFAULT ' ',  -- Gender (Male/Female)
    YAEST NCHAR(1) DEFAULT ' ',  -- Employment Status
    YAHMCO NCHAR(5) DEFAULT ' ',  -- Company - Home
    YAHMCU NCHAR(12) DEFAULT ' ',  -- Business Unit - Home
    YAPAST NCHAR(1) DEFAULT ' ',  -- Employee Pay Status
    YAJBCD NCHAR(6) DEFAULT ' ',  -- Job Type (Craft) Code
    YAJBST NCHAR(4) DEFAULT ' ',  -- Job Step
    YATRS NCHAR(3) DEFAULT ' ',  -- Change Reason
    YASAL NUMBER DEFAULT 0,  -- Rate - Salary  Annual (.2)
    YAPHRT NUMBER DEFAULT 0,  -- Rate - Hourly (.3)
    YADOB NUMBER DEFAULT 0,  -- Date - Birth (Julian)
    YADSI NUMBER DEFAULT 0,  -- Date - Original Employment (Julian)
    YADT NUMBER DEFAULT 0,  -- Date - Terminated (Julian)
    YADST NUMBER DEFAULT 0,  -- Date Started (Julian)
    YAANPA NUMBER DEFAULT 0  -- Supervisor
);

CREATE TABLE proddta.f06156 (  -- Payment Header
    YUAN8 NUMBER DEFAULT 0,  -- Address Number
    YUDOCM NUMBER DEFAULT 0,  -- Document - Matching(Payment or Item)
    YUCKD NUMBER DEFAULT 0,  -- Date - Check (Julian)
    YUGPAY NUMBER DEFAULT 0,  -- Amount - Gross Pay (.2)
    YUNPAY NUMBER DEFAULT 0  -- Amount - Net Pay (.2)
);

CREATE TABLE proddta.f08042 (  -- HR History
    JWFILE NCHAR(10) DEFAULT ' ',  -- File Name
    JWAN8 NUMBER DEFAULT 0,  -- Address Number
    JWDTAI NCHAR(10) DEFAULT ' ',  -- Data Item
    JWHSTD NCHAR(30) DEFAULT ' ',  -- History Data
    JWEFTO NUMBER DEFAULT 0,  -- Date - Effective On (Julian)
    JWTRS NCHAR(3) DEFAULT ' '  -- Change Reason
);

CREATE TABLE proddta.f09e108 (  -- Expense Policy Rules
    PRPOLICY NCHAR(5) DEFAULT ' ',  -- Policy Name
    PRDL01 NCHAR(30) DEFAULT ' ',  -- Description
    PREXPTYPE NCHAR(4) DEFAULT ' ',  -- Expense Category
    PREFTJ NUMBER DEFAULT 0,  -- Date - Effective (Julian)
    PREXRPTTYP NCHAR(1) DEFAULT ' ',  -- Expense Report Type
    PRLOCATN NCHAR(10) DEFAULT ' ',  -- Location
    PREXDJ NUMBER DEFAULT 0,  -- Date - Expired (Julian)
    PRRATE1 NUMBER DEFAULT 0,  -- Rate (.3)
    PRDLYALLOW NUMBER DEFAULT 0,  -- Daily Allowance (.2)
    PRTOLER NUMBER DEFAULT 0,  -- Expense Tolerance %
    PRAUDITAMT NUMBER DEFAULT 0,  -- Audit Amount (.2)
    PRRCTRQD NCHAR(1) DEFAULT ' ',  -- Receipt Required
    PRDOMRCTAM NUMBER DEFAULT 0,  -- Domestic Receipt Amount (.2)
    PRHEDIT NCHAR(1) DEFAULT ' ',  -- Hard Edit
    PRPOLCRCY NCHAR(3) DEFAULT ' ',  -- Policy Currency Code
    PRGOVTFLAG NCHAR(1) DEFAULT ' '  -- Use Allowable/Unallowable Rule
);

CREATE TABLE proddta.f09e110 (  -- Audit Selection Rules
    ASPOLICY NCHAR(5) DEFAULT ' ',  -- Policy Name
    ASRULENUM NUMBER DEFAULT 0,  -- Rule Number
    ASFROMRNG NUMBER DEFAULT 0,  -- From Range (.2)
    ASTHRURNG NUMBER DEFAULT 0,  -- Thru Range (.2)
    ASPERCSEL NUMBER DEFAULT 0,  -- Percent To Select
    ASEFTB NUMBER DEFAULT 0  -- Date - Beginning Effective (Julian)
);

CREATE TABLE proddta.f20111 (  -- Expense Report Header
    EHEXRPTTYP NCHAR(1) DEFAULT ' ',  -- Expense Report Type
    EHEXRPTNUM NCHAR(10) DEFAULT ' ',  -- Expense Report Number
    EHEMPLOYID NUMBER DEFAULT 0,  -- Employee ID
    EHEXRPTDES NCHAR(40) DEFAULT ' ',  -- Expense Report Description
    EHEXRPTSTA NCHAR(3) DEFAULT ' ',  -- Expense Report Status
    EHTOTEXP NUMBER DEFAULT 0,  -- Total Expenses (.2)
    EHREIMBTOT NUMBER DEFAULT 0,  -- ReimbursementTotal (.2)
    EHDATEAPP NUMBER DEFAULT 0,  -- Date Approved (Julian)
    EHDATESUB NUMBER DEFAULT 0,  -- Date Submitted (Julian)
    EHBUSPURP NCHAR(40) DEFAULT ' ',  -- Business Purpose
    EHNUMEXC NUMBER DEFAULT 0,  -- Number Of Exceptions
    EHCASHADV NUMBER DEFAULT 0,  -- Cash Advance (.2)
    EHCO NCHAR(5) DEFAULT ' ',  -- Company
    EHPOLICY NCHAR(5) DEFAULT ' ',  -- Policy Name
    EHHMCU NCHAR(12) DEFAULT ' ',  -- Business Unit - Home
    EHGOVUNTOT NUMBER DEFAULT 0  -- Unallowable Amount Total (.2)
);

CREATE TABLE proddta.f20112 (  -- Expense Report Detail
    EDEXRPTTYP NCHAR(1) DEFAULT ' ',  -- Expense Report Type
    EDEXRPTNUM NCHAR(10) DEFAULT ' ',  -- Expense Report Number
    EDEMPLOYID NUMBER DEFAULT 0,  -- Employee ID
    EDLIN NUMBER DEFAULT 0,  -- Line Number - General (.2)
    EDEXPTYPE NCHAR(4) DEFAULT ' ',  -- Expense Category
    EDEXPDATE NUMBER DEFAULT 0,  -- Expense Date (Julian)
    EDEXPDAMT NUMBER DEFAULT 0,  -- Reimbursement Amount (.2)
    EDEXPFAMT NUMBER DEFAULT 0,  -- Expense Amount (.2)
    EDPMTMETH NCHAR(3) DEFAULT ' ',  -- Payment Method
    EDBUSPURP NCHAR(40) DEFAULT ' ',  -- Business Purpose
    EDADDLCMT NCHAR(60) DEFAULT ' ',  -- Additional Comments
    EDEXPSTAT NCHAR(2) DEFAULT ' ',  -- Expense Status
    EDCRCD NCHAR(3) DEFAULT ' ',  -- Currency Code - From
    EDRCPTLBL NUMBER DEFAULT 0,  -- Receipt Label
    EDNUMNITES NUMBER DEFAULT 0,  -- Number of Nights
    EDHOTELLOC NCHAR(25) DEFAULT ' ',  -- Hotel Location
    EDMCU0 NCHAR(12) DEFAULT ' ',  -- Business Unit
    EDLOCATN NCHAR(10) DEFAULT ' ',  -- Location
    EDSBL NCHAR(8) DEFAULT ' ',  -- Subledger - G/L
    EDSBLT NCHAR(1) DEFAULT ' ',  -- Subledger Type
    EDPOLICYEX NCHAR(3) DEFAULT ' ',  -- Policy Exception
    EDTAPDA NUMBER DEFAULT 0,  -- Total Available Per Diem Amount (.2)
    EDGOVTAMT NUMBER DEFAULT 0,  -- Allowable Amount (.2)
    EDGOVTUAMT NUMBER DEFAULT 0  -- Unallowable Amount (.2)
);

CREATE TABLE proddta.f43008 (  -- Approval Level Revisions
    APDCTO NCHAR(2) DEFAULT ' ',  -- Order Type
    APARTG NCHAR(12) DEFAULT ' ',  -- Code - Approval Routing
    APDL01 NCHAR(30) DEFAULT ' ',  -- Description
    APALIM NUMBER DEFAULT 0,  -- Limit - Approval
    APRPER NUMBER DEFAULT 0,  -- Person Responsible
    APATY NCHAR(1) DEFAULT ' '  -- Type of Approver
);

CREATE TABLE proddta.f4301 (  -- Purchase Order Header
    PHKCOO NCHAR(5) DEFAULT ' ',  -- Order Company (Order Number)
    PHDOCO NUMBER DEFAULT 0,  -- Document (Order No  Invoice  etc.)
    PHDCTO NCHAR(2) DEFAULT ' ',  -- Order Type
    PHSFXO NCHAR(3) DEFAULT ' ',  -- Order Suffix
    PHMCU NCHAR(12) DEFAULT ' ',  -- Business Unit
    PHAN8 NUMBER DEFAULT 0,  -- Address Number
    PHDRQJ NUMBER DEFAULT 0,  -- Date - Requested (Julian)
    PHTRDJ NUMBER DEFAULT 0,  -- Date - Order/Transaction (Julian)
    PHVR01 NCHAR(25) DEFAULT ' ',  -- Reference
    PHDEL1 NCHAR(30) DEFAULT ' ',  -- Delivery Instructions Line 1
    PHDEL2 NCHAR(30) DEFAULT ' ',  -- Delivery Instructions Line 2
    PHRMK NCHAR(30) DEFAULT ' ',  -- Name - Remark
    PHDESC NCHAR(30) DEFAULT ' ',  -- Description
    PHANBY NUMBER DEFAULT 0,  -- Buyer Number
    PHOTOT NUMBER DEFAULT 0  -- Amount - Order Gross (.2)
);

CREATE TABLE proddta.f4311 (  -- Purchase Order Detail
    PDKCOO NCHAR(5) DEFAULT ' ',  -- Order Company (Order Number)
    PDDOCO NUMBER DEFAULT 0,  -- Document (Order No  Invoice  etc.)
    PDDCTO NCHAR(2) DEFAULT ' ',  -- Order Type
    PDSFXO NCHAR(3) DEFAULT ' ',  -- Order Suffix
    PDLNID NUMBER DEFAULT 0,  -- Line Number (.3)
    PDAN8 NUMBER DEFAULT 0,  -- Address Number
    PDDRQJ NUMBER DEFAULT 0,  -- Date - Requested (Julian)
    PDLITM NCHAR(25) DEFAULT ' ',  -- 2nd Item Number
    PDDSC1 NCHAR(30) DEFAULT ' ',  -- Description
    PDDSC2 NCHAR(30) DEFAULT ' ',  -- Description - Line 2
    PDLNTY NCHAR(2) DEFAULT ' ',  -- Line Type
    PDNXTR NCHAR(3) DEFAULT ' ',  -- Status Code - Next
    PDLTTR NCHAR(3) DEFAULT ' ',  -- Status Code - Last
    PDUOM NCHAR(2) DEFAULT ' ',  -- Unit of Measure as Input
    PDUORG NUMBER DEFAULT 0,  -- Units - Order/Transaction Quantity
    PDPRRC NUMBER DEFAULT 0,  -- Amount - Unit Cost (.4)
    PDAEXP NUMBER DEFAULT 0,  -- Amount - Extended Price (.2)
    PDOMCU NCHAR(12) DEFAULT ' ',  -- Project Business Unit
    PDOBJ NCHAR(6) DEFAULT ' ',  -- Object Account
    PDSUB NCHAR(8) DEFAULT ' '  -- Subsidiary
);

CREATE TABLE proddta.f43121 (  -- Purchase Order Receiver
    PRMATC NCHAR(1) DEFAULT ' ',  -- Type - Match Record Type
    PRAN8 NUMBER DEFAULT 0,  -- Address Number
    PRKCOO NCHAR(5) DEFAULT ' ',  -- Order Company (Order Number)
    PRDOCO NUMBER DEFAULT 0,  -- Document (Order No  Invoice  etc.)
    PRDCTO NCHAR(2) DEFAULT ' ',  -- Order Type
    PRSFXO NCHAR(3) DEFAULT ' ',  -- Order Suffix
    PRLNID NUMBER DEFAULT 0,  -- Line Number (.3)
    PRLITM NCHAR(25) DEFAULT ' ',  -- 2nd Item Number
    PRRCDJ NUMBER DEFAULT 0,  -- Date - Received (Julian)
    PRVINV NCHAR(25) DEFAULT ' ',  -- Supplier Invoice Number
    PRMCU NCHAR(12) DEFAULT ' ',  -- Business Unit
    PRANI NCHAR(29) DEFAULT ' ',  -- Account Number - Input (Mode Unknown)
    PROMCU NCHAR(12) DEFAULT ' ',  -- Project Business Unit
    PRSBL NCHAR(8) DEFAULT ' ',  -- Subledger - G/L
    PRSBLT NCHAR(1) DEFAULT ' ',  -- Subledger Type
    PRKCO NCHAR(5) DEFAULT ' ',  -- Document Company
    PRDOC NUMBER DEFAULT 0,  -- Document (Voucher  Invoice  etc.)
    PRDCT NCHAR(2) DEFAULT ' ',  -- Document Type
    PRSFX NCHAR(3) DEFAULT ' ',  -- Document Pay Item
    PRUREC NUMBER DEFAULT 0,  -- Units - Received
    PRAREC NUMBER DEFAULT 0  -- Amount - Received (.2)
);

CREATE TABLE proddta.f4330 (  -- Supplier Selection
    P0KCOO NCHAR(5) DEFAULT ' ',  -- Order Company (Order Number)
    P0DOCO NUMBER DEFAULT 0,  -- Document (Order No  Invoice  etc.)
    P0DCTO NCHAR(2) DEFAULT ' ',  -- Order Type
    P0LNID NUMBER DEFAULT 0,  -- Line Number (.3)
    P0AN8 NUMBER DEFAULT 0,  -- Address Number
    P0QPRT NCHAR(1) DEFAULT ' ',  -- Quote Printed Flag
    P0RQQJ NUMBER DEFAULT 0,  -- Date - Required Reponse Date (Julian)
    P0QRDJ NUMBER DEFAULT 0,  -- Date - Reponse Date (Julian)
    P0UREL NUMBER DEFAULT 0,  -- Units - Released
    P0AREL NUMBER DEFAULT 0,  -- Amount - Released (.2)
    P0SFXO NCHAR(3) DEFAULT ' '  -- Order Suffix
);

CREATE TABLE proddta.f4331 (  -- Supplier Price Quotes
    P1DOCO NUMBER DEFAULT 0,  -- Document (Order No  Invoice  etc.)
    P1DCTO NCHAR(2) DEFAULT ' ',  -- Order Type
    P1KCOO NCHAR(5) DEFAULT ' ',  -- Order Company (Order Number)
    P1AN8 NUMBER DEFAULT 0,  -- Address Number
    P1LNID NUMBER DEFAULT 0,  -- Line Number (.3)
    P1UORG NUMBER DEFAULT 0,  -- Units - Order/Transaction Quantity
    P1PRRC NUMBER DEFAULT 0,  -- Amount - Unit Cost (.4)
    P1PDDJ NUMBER DEFAULT 0,  -- Date - Scheduled Pick (Julian)
    P1CNDJ NUMBER DEFAULT 0,  -- Date - Cancel (Julian)
    P1CRCD NCHAR(3) DEFAULT ' ',  -- Currency Code - From
    P1SFXO NCHAR(3) DEFAULT ' '  -- Order Suffix
);
