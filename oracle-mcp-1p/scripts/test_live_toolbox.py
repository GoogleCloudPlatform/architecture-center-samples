#!/usr/bin/env python3
"""
test_live_toolbox.py

Validates every Oracle EBS tool via the official MCP Toolbox CLI binary ('toolbox invoke')
against the live Oracle database (apps_ai@apps.example.com:1521/EBSDB) using ebs/tools.yaml.
"""

import json
import os
import subprocess
import sys
import yaml

BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
EBS_YAML = os.path.join(BASE_DIR, "ebs", "tools.yaml")

SAMPLE_INVOCATION_PAYLOADS = {
    "ebs_get_constituent_notice_details": {"transaction_id": "100027", "org_id": "1448"},
    "ebs_get_document_attachment": {"document_id": "157", "entity_name": ""},
    "ebs_search_foia_records": {"query_keyword": "Standard", "start_date": "", "end_date": "", "org_id": 204},
    "ebs_get_employee_personnel_file": {"person_id": 27, "employee_number": ""},
    "ebs_get_agency_policy_rules": {"policy_category": "EXPENSE", "rule_name": "", "org_id": "204", "as_of_date": ""},
    "ebs_search_policy_attachments": {"keyword": "policy", "policy_category": "", "entity_name": ""},
    "ebs_get_intake_attachments": {"intake_queue_id": "1", "applicant_id": "", "entity_name": "PER_PERF_MGMT_PLANS", "include_content": "N"},
    "ebs_verify_party_identity": {"legal_name": "Michael Wilkinson", "tax_id_hash": "", "postal_code": "20148", "party_id": ""},
    "ebs_get_sourcing_rfp_details": {"auction_header_id": "", "rfp_number": "30613"},
    "ebs_get_vendor_bids": {"auction_header_id": "44623", "bid_number": "", "vendor_name": "", "include_prices": "N"},
    "ebs_get_expense_reports": {"report_header_id": "1001", "employee_id": "27", "start_date": "", "end_date": "", "include_receipts": "N"},
    "ebs_list_expense_reports": {"org_id": "204", "employee_id": "", "status": "", "start_date": "", "end_date": "", "min_total": "", "offset": "0"},
    "ebs_find_duplicate_expense_lines": {"org_id": "204", "start_date": "", "end_date": "", "min_amount": "100"},
    "ebs_get_award_terms": {"org_id": "", "award_number": "", "as_of_date": ""},
    "ebs_get_award_expenditures": {"award_number": "1001", "start_date": "", "end_date": ""},
    "ebs_get_expense_report_approval_and_payment": {"report_header_id": "39254", "org_id": "", "start_date": "", "end_date": ""},
    "ebs_get_po_invoice_match": {"invoice_id": "1001", "po_header_id": "1001", "po_number": ""},
    "ebs_list_operating_units": {"name_pattern": "%Vision%"},
    "ebs_list_attachment_entities": {"keyword": "PO"},
    "ebs_list_lookup_values": {"lookup_type": "FOB_VALUES", "keyword": ""},
    "ebs_lookup_parties_and_vendors": {"search_name": "Office", "org_id": "204"},
    "ebs_lookup_employees": {"name_keyword": "Smith", "employee_number": ""},
    "ebs_lookup_recent_transactions": {"doc_type": "PO", "doc_number": "", "org_id": "204"},
    "ebs_describe_table": {"table_name": "PON_BID_HEADERS"},
    "ebs_get_attachment_text": {"document_id": "969", "start_chunk": ""}
}

def main():
    if not os.path.exists(EBS_YAML):
        print(f"[!] Error: {EBS_YAML} does not exist. Run sync_sql_to_yaml.py first.")
        sys.exit(1)

    with open(EBS_YAML, "r") as f:
        cfg = yaml.safe_load(f)

    tools = cfg.get("tools", {})
    wrapped = [name for name, tdef in tools.items() if tdef.get("authRequired")]
    if wrapped:
        print(f"[!] {len(wrapped)} tools in {EBS_YAML} require an authenticated ID token (PL/SQL security wrapper).")
        print("    'toolbox invoke' cannot send one; test them through the HTTP API instead (README §2.6).")
        sys.exit(2)
    print(f"[*] Invoking {len(tools)} tools via 'toolbox invoke' using {EBS_YAML}...\n")

    passed = 0
    failed = 0

    for tool_name in tools:
        args = SAMPLE_INVOCATION_PAYLOADS.get(tool_name, {})
        cmd = ["toolbox", "invoke", tool_name, json.dumps(args), "--config", EBS_YAML]
        proc = subprocess.run(cmd, capture_output=True, text=True)

        # Toolbox logs to stderr; only treat non-zero or ERROR as failure
        if proc.returncode == 0 and "ERROR" not in proc.stderr and "Error:" not in proc.stderr:
            print(f"  [PASS] {tool_name}")
            passed += 1
        else:
            err = proc.stderr.strip() if proc.stderr else proc.stdout.strip()
            print(f"  [FAIL] {tool_name}\n         -> {err}\n")
            failed += 1

    print(f"\nSummary: {passed} passed, {failed} failed out of {len(tools)} tools.")
    if failed > 0:
        sys.exit(1)


if __name__ == "__main__":
    main()
