# Oracle-ebs-scripts and APPS_AI Database Integration Guide

This repository contains a comprehensive suite of SQL and PL/SQL scripts designed for Oracle E-Business Suite (EBS) integration, specifically focusing AI-driven data retrieval (APPS_AI).

## Components and Modules

1. APPS_AI Database Integration Guide
2. ebs-scripts for use-cases

# 1. APPS_AI Database Integration Guide 
# execute user creation script against Oracle EBS PDB database
Execution Instructions to create APPS_AI schema
To execute this file using the SYSTEM or SYSDBA account:

# Step A: Move the file to the Database Server
If you are working on a remote server, upload create_apps_ai.sql to a directory where the oracle user has read permissions (e.g., /tmp or your home directory).

# Step B: Log in via SQL*Plus
Open your terminal and log in as the SYSDBA user. If you are on the local server, you can use:

Bash sqlplus / as sysdba If logging in remotely as SYSTEM:

Bash sqlplus system/your_password@your_host:1521/your_service_name

Step C: Run the script
Once you see the SQL> prompt, run the script by using the @ symbol followed by the path to your file:

sqlplus system @/tmp/create_apps_ai.sql

Verification After the script finishes, you should verify that the user can log in and that the schema switch is working. Run this from your terminal:
ex: Bash sqlplus apps_ai/apps_ai@EBSDB Once logged in, run this command:

SQL SELECT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') FROM dual; Expected Result: The output should be APPS. This confirms that even though you logged in as apps_ai, you are automatically looking at the E-Business Suite base tables.

# APPS_AI Security Configuration 
This repository contains the necessary scripts to configure the APPS_AI user schema, Before executing functional scripts, configure the APPS_AI user schema. Choose one of the two following security postures based on your organizational requirements.

# Option a: Global Read Access
Best for broad AI discovery and cross-module analysis.

Logic: Provides SELECT ANY TABLE (Read-Only) to mimic APPS user access without write permissions.

Action:
1. Run  GRANT SELECT ANY TABLE TO APPS_AI;
2. Run @GrantToApps_AI.sql (Foundational execution & special object grants).

# Option b: Restricted Module Access
Best for production environments following the Principle of Least Privilege.

Logic: Explicitly grants access only to necessary objects (~3,000 specific grants).

Action: 1. Run @GrantToApps_AIRESTRICTED.sql

# 2. ebs-scripts for use-cases

### [Apps initialize]
This appsInitialisefromemailid.sql plsql code execute scripts which read email id and get the neccessary deatils required for user initialize in EBS.
- **Purpose**: Apps, Multi-Org, operating unit initilisation.
- **Key Features**:
    - User apps initialize.
    - Initialize Multi-Org for Inventory ( inventory is used for the usecase).
    - Set Policy Context to work within one specific Operating Unit .

### 
This directory contains the sql and pl sql code to pull data from ebs and execute scripts in EBS.
- **Purpose**: SQL and PL?SQL scripts to be called from agents.
- **Key Features**:
    - Retrieve On-hand.
    - Create On-hand.
    - Reserve item from location.
    - Supplier and Site creation
    - Payables invoice creation

#### Scripts
This custom packages bundles few key features and use-cases.

ge_ebs_mcp_tools.pls
ge_ebs_mcp_tools.plb


### Testing
All basic testing completed and uploded the testing result here ALL_BASIC_TESTING_RESULTS.xlsx


