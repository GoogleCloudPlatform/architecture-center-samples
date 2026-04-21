# oracle-ebs-scripts and APPS_AI Database Integration Guide

This repository contains a comprehensive suite of SQL and PL/SQL scripts designed for Oracle E-Business Suite (EBS) integration, specifically focusing AI-driven data retrieval (APPS_AI).

## Components and Modules

1. APPS_AI Database Integration Guide
2. ebs-scripts for use case

# 1. APPS_AI Database Integration Guide 
APPS_AI Security ConfigurationThis repository contains the necessary scripts to configure the APPS_AI user schema, Before executing functional scripts, configure the APPS_AI user schema. Choose one of the two following security postures based on your organizational requirements.

# Option 1: Global Read Access
Best for broad AI discovery and cross-module analysis.

Logic: Provides SELECT ANY TABLE (Read-Only) to mimic APPS user access without write permissions.

Action:
1. Run  GRANT SELECT ANY TABLE TO APPS_AI;
2. Run @GrantToApps_AI.sql (Foundational execution & special object grants).

# Option 2: Restricted Module Access
Best for production environments following the Principle of Least Privilege.

Logic: Explicitly grants access only to necessary objects (~3,000 specific grants).

Action: 1. Run @GrantToApps_AIRESTRICTED.sql

# 2. ebs-scripts for use case

### [Apps initialize]
This appsInitialisefromemailid.sql plsql code execute scripts which read email id and get the neccessary deatils required for user initialize in EBS.
- **Purpose**: Apps, Multi-Org, operating unit initilisation.
- **Key Features**:
    - User apps initialize.
    - Initialize Multi-Org for Inventory ( inventory is used for the usecase)
    - Set Policy Context to work within one specific Operating Unit .

### [Inventory]
This directory contains the sql and pl sql code to pull data from ebs and execute scripts which inter crewate reserve on hand quantity in EBS.
- **Purpose**: SQL and PL?SQL scripts to be called from agents.
- **Key Features**:
    - Retrieve On-hand.
    - Create On-hand.
    - Resrve item from location .

#### Scripts

| Scripts | Path | Purpose |
|-----------|----------|------------------------------|\
|appsInitialisefromemailid.sql| `EBSScripts/appsInitialisefromemailid.sql` | SQL which pulls On-hand  quantity data from EBS for a give item/part number and warehouse location |
| `Retrieve_On-Hand_Qty` | `EBSScripts/Retrieve_On-Hand_Qty.sql` | SQL which pulls On-hand  quantity data from EBS for a give item/part number and warehouse location |
| `Create_On-Hand_Qty` | `EBSScripts/Create_On-Hand_Qty.sql` | pl/sql executes in EBS , create onhand quatity records in interface table for the parameters Inv_org_id,Item,quantity, default values passed for Miscellaneous Receipt,Subinventory and system derives dynamically for fnd_user & fnd_login  |
| `Reserve_On-Hand_Qty` | `EBSScripts/Reserve_On-Hand_Qty.sql` | TDB |

### [Retrieve_On-Hand_Qty]

- **Purpose**:  SQL to pull On-hand quantity
- **Key Features**:
    

### [Create_On-Hand_Qty]

- **Purpose**: PL/SQL to create On-hand quantity
- **Key Features**: create onhand quatity records in interface table for the parameters, in the back ground transactoin managers are scheduled to run frequnetly(2minutes)
- 


### Testing
All basic testing completed and uploded the testing result here ALL_BASIC_TESTING_RESULTS.xlsx


