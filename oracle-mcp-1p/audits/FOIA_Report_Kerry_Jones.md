# FREEDOM OF INFORMATION ACT (FOIA) DISCOVERY REPORT

**Document Control Number:** FOIA-2026-VO-00210  
**Target Subject:** Kerry Jones  
**Agency / Operating Unit:** Vision Operations (`ORG_ID: 204`) / Vision Corporation (`ORG_ID: 202`)  
**Enterprise Systems Searched:** Oracle E-Business Suite R12.2 (HRMS, AP, PO, TCA, FND)  
**Date of Report:** September 30, 2026  
**Status:** Completed Cross-Module Discovery  

---

## 1. Executive Summary

This report documents all records, transactions, personnel files, and electronic attachments identified for **Kerry Jones** within the Oracle E-Business Suite database under the jurisdiction of **Vision Operations** (Operating Unit 204) and **Vision Corporation** (Business Group 202).

Cross-system correlation identified matching records across four functional subsystems:
1. **Oracle Human Resources (HRMS):** Official personnel record, employee badge assignments, and historical performance evaluations.
2. **Oracle Internet Expenses (OIE) / Accounts Payable (AP):** Official award travel expense claim and disbursement records totaling **$4,149.60**.
3. **Trading Community Architecture (TCA) / Purchasing (PO):** Supplier and vendor registration under Supplier Number `1009`.
4. **Foundation Attachment Repository (FND):** Stored binary image attachment (`10043388.bmp`, Document ID `210`).

---

## 2. Personnel Records & Privacy Review (HRMS)

* **Source System:** Oracle HRMS (`PER_ALL_PEOPLE_F`, `PER_ALL_ASSIGNMENTS_F`, `PER_PERFORMANCE_REVIEWS`)  
* **Record Identifier (Person ID):** `33`  
* **Employee / Badge Number:** `32`  
* **Assignment Number:** `32`  
* **Job Identification Code:** `1937`  
* **Legal Name:** Ms. Kerry Jones  
* **Business Group:** Vision Corporation (`ORG_ID: 202`)  
* **Operating Unit Association:** Vision Operations (`ORG_ID: 204`)  
* **Record Creation Date:** February 24, 1997  

### Performance Evaluation History
* **December 31, 2000** (Review ID `8320`): Rating `1`
* **December 31, 2002** (Review ID `6022`): Rating `5`
* **December 31, 2004** (Review ID `7317`): Rating `5`

### Absences & Disciplinary Actions
* **Absence Attendance Records:** None on file.
* **Grievances / Disciplinary Actions:** None on file.

### FOIA Exemption 6 Privacy Analysis (5 U.S.C. § 552(b)(6))
Records that disclose personal information about individuals are evaluated under FOIA Exemption 6 to protect personal privacy:
* **Date of Birth:** `1969-04-14` $\rightarrow$ **REDACTED (b)(6)**
* **Social Security / Tax ID:** `654-33-6511` $\rightarrow$ **REDACTED (b)(6)** (masked as `XXX-XX-6511`)
* **Individual Performance Evaluation Ratings:** **REDACTED (b)(6)** prior to public disclosure.

---

## 3. Travel & Expense Disbursements (OIE / AP)

* **Source System:** Oracle Internet Expenses & Accounts Payable (`AP_EXPENSE_REPORT_HEADERS_ALL`, `AP_INVOICES_ALL`)  
* **Expense Report Header ID:** `10363`  
* **AP Invoice ID:** `13311`  
* **Document Number:** `06-JAN-97`  
* **Submission Date:** January 6, 1997  
* **Operating Unit:** Vision Operations (`ORG_ID: 204`)  
* **Trip Purpose / Description:** `Gold Club Award Trip`  
* **Audit & Policy Status:** `OK` (Policy compliant, approved for reimbursement)  
* **Total Disbursed Amount:** **$4,149.60 USD**

### Itemized Expense Breakdown

| Line | Expense Category | Description | Amount (USD) | Status |
|:---:|:---|:---|:---:|:---:|
| **1** | Miscellaneous | Miscellaneous | $254.74 | Approved |
| **2** | Transportation | Car Rental | $387.65 | Approved |
| **3** | Subsistence | Meals | $548.97 | Approved |
| **4** | Travel | Airfare | $1,325.66 | Approved |
| **5** | Lodging | Hotel (*"Httel"*) | $1,632.58 | Approved |
| **Total** | | | **$4,149.60** | |

---

## 4. Supplier & Trading Partner Profile (TCA / PO)

* **Source System:** Oracle Trading Community Architecture & Payables (`PO_VENDORS`, `HZ_PARTIES`)  
* **Supplier Legal Name:** Kerry Jones  
* **Supplier / Vendor Number:** `1009`  
* **Vendor ID (`VENDOR_ID`):** `10`  
* **TCA Party ID:** `301481`  
* **Party Registry Number:** `50732`  
* **Party Type:** `ORGANIZATION`  
* **Status:** Active Registered Vendor  

---

## 5. Electronic Evidence & Binary Attachments (FND)

* **Source System:** Oracle Foundation Repository (`FND_ATTACHED_DOCUMENTS`, `FND_DOCUMENTS`, `FND_LOBS`)  
* **Document ID:** `210`  
* **Attached Document ID:** `602`  
* **Parent Entity:** `PO_VENDORS`  
* **Entity Primary Key (`ENTITY_PK1`):** `10` (References Vendor ID `10`)  
* **Attachment Description:** `K.Jones Picture`  
* **Original File Path:** `/hm000a/applcsf/attachme/10043388.bmp`  
* **Effective Date:** August 22, 1997  
* **MIME Content Type:** `image/x-MS-bmp`  
* **File Format:** Windows 3.x Bitmap (259 × 336 pixels, 8-bit indexed, 88,438 bytes)  
* **Extracted Artifact Location:** `scripts/10043388.bmp`  

---

## 6. FOIA Disclosure Determination

| Record Type | Document Ref | Status | Statutory Justification |
|:---|:---|:---|:---|
| **Employee Job Title & Assignment** | Badge `32` / Job `1937` | **Releasable** | Public agency employment record |
| **Date of Birth & SSN** | Person ID `33` | **Withheld** | 5 U.S.C. § 552(b)(6) Personal Privacy |
| **Performance Review Ratings** | Reviews `8320`, `6022`, `7317` | **Withheld** | 5 U.S.C. § 552(b)(6) Personal Privacy |
| **Award Trip Expense Report** | Invoice `13311` (`06-JAN-97`) | **Releasable** | Public expenditure of agency funds |
| **Supplier Registration** | Vendor `1009` / Party `301481` | **Releasable** | Commercial entity trading record |
| **Vendor Photograph Attachment** | Document `210` (`10043388.bmp`) | **Releasable with Redaction** | Releasable subject to individual consent |

---
*Report compiled via Model Context Protocol (MCP) Toolbox for Oracle E-Business Suite.*
