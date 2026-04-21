# EBS API Agent

The EBS API Agent is a specialist sub-agent that performs transactional operations against Oracle E-Business Suite via REST and SOAP APIs. It is invoked by the EBS Master Agent and is responsible for session management, financial document creation (invoices, purchase orders), user/vendor management, and subscription handling.

All API calls are made through the **MCP Oracle EBS** server (`mcp-oracle-ebs`), which translates MCP tool calls into EBS API requests.

## Responsibilities

- Establish and maintain an EBS session (login → initialize)
- Create, query, and void AP invoices and invoice lines
- Manage vendor and vendor site records
- Manage FND users (create, update, enable/disable)
- Query and manage subscriptions
- Execute payment commitment and control (APIMPCC) operations

## Session Lifecycle

Every conversation that requires API access follows this sequence:

```
get_session_context          ← check if session already exists in history
    │
    └─ no session ──▶ apinv_login  ──▶  apinv_initialize
                         │
                         └──▶ apinv_get_initialize (verify org context)
                                  │
                                  └──▶  [ perform operations ]
                                              │
                                              └──▶ apinv_logout
```

If `get_session_context` returns an active session from an earlier turn, login and initialize steps are skipped and the existing session is reused.

## Tool Reference

### Authentication & Session

| Tool | Description |
|---|---|
| `apinv_login` | Authenticates with EBS using username/password. Returns a session cookie. |
| `apinv_logout` | Invalidates the current session. Always call on completion or error. |
| `apinv_initialize` | Sets the operating unit and responsibility context for the session. |
| `apinv_get_initialize` | Retrieves the current initialization state (org ID, responsibility). |
| `get_session_context` | Returns session metadata from the current conversation history. |

### AP Invoice (APINV)

| Tool | Description |
|---|---|
| `apinv_get_invoice_interface` | Query invoice interface records by status or invoice number. |
| `apinv_create_invoice_interface` | Create an invoice header in the AP interface table. |
| `apinv_create_invoice_line_interface` | Add a line to an existing interface invoice. |
| `apinv_submit_invoice_import` | Submit the Invoice Import concurrent request to process interface records. |
| `apinv_get_ap_invoices` | Query validated AP invoices. |
| `apinv_validate_invoice` | Trigger invoice validation for a specific invoice. |
| `apinv_cancel_invoice` | Cancel a validated invoice (destructive — requires confirmation). |
| `apinv_void_payment` | Void a payment associated with an invoice (destructive). |

### Payment Commitment & Control (APIMPCC)

| Tool | Description |
|---|---|
| `apimpcc_get_commitments` | Query payment commitments. |
| `apimpcc_create_commitment` | Create a new payment commitment. |
| `apimpcc_update_commitment` | Update an existing commitment. |
| `apimpcc_cancel_commitment` | Cancel a commitment (destructive). |

### Vendor Management

| Tool | Description |
|---|---|
| `apinv_get_vendor` | Query vendor records by name, number, or ID. |
| `apinv_create_vendor` | Create a new supplier/vendor record. |
| `apinv_create_vendor_site` | Create a vendor site (address/payment site). |
| `apinv_update_vendor` | Update vendor attributes. |

### Access Control & Metadata

| Tool | Description |
|---|---|
| `get_access_control` | List responsibilities and org units available to the current user. |
| `get_responsibilities` | Return the EBS responsibilities for a given user. |
| `get_org_units` | Return operating units accessible in the current session. |

### FND User Management

| Tool | Description |
|---|---|
| `fnd_user_create` | Create a new FND user account. |
| `fnd_user_update` | Update user attributes (email, end date, etc.). |
| `fnd_user_is_active` | Check whether a user account is active. |

### Subscriptions

| Tool | Description |
|---|---|
| `subscription_get` | Retrieve subscription records. |
| `subscription_create` | Create a new subscription. |
| `subscription_update` | Update subscription attributes. |
| `subscription_cancel` | Cancel a subscription (destructive). |

## Invoice Creation Workflow

Creating an AP invoice requires three steps in sequence:

**Step 1 — Create invoice header**

```
apinv_create_invoice_interface(
    vendor_id, vendor_site_id,
    invoice_num, invoice_date, invoice_amount,
    invoice_currency_code, org_id
)
```

**Step 2 — Create invoice lines** (one call per line)

```
apinv_create_invoice_line_interface(
    invoice_interface_id,    ← returned from Step 1
    line_number, line_type_lookup_code,
    amount, description
)
```

**Step 3 — Submit import**

```
apinv_submit_invoice_import(org_id)
```

This submits an Oracle concurrent request. The returned request ID can be used to check completion status. Invoice records appear in `AP_INVOICES_ALL` after the request completes.

## Destructive Operations

The following operations are irreversible. Before executing any of them, query the target record first and confirm the key details:

| Operation | Tool | Pre-check |
|---|---|---|
| Cancel invoice | `apinv_cancel_invoice` | `apinv_get_ap_invoices` |
| Void payment | `apinv_void_payment` | `apinv_get_ap_invoices` |
| Cancel commitment | `apimpcc_cancel_commitment` | `apimpcc_get_commitments` |
| Cancel subscription | `subscription_cancel` | `subscription_get` |

## Response Format

All responses follow the `AgentResponseSchema` structure:

| Field | Type | Description |
|---|---|---|
| `ok` | boolean | `true` if the operation succeeded |
| `source_agent` | string | Always `"EBS_API_Agent"` |
| `error_code` | string \| null | Machine-readable error code on failure |
| `retryable` | boolean | Whether the caller should retry after a transient fault |
| `message` | string | Human-readable summary |
| `data` | object \| null | Returned records or operation result |

## Environment Variables

| Variable | Description | Default |
|---|---|---|
| `GOOGLE_CLOUD_PROJECT` | GCP project ID | required |
| `GOOGLE_CLOUD_PROJECT_NUMBER` | GCP project number | required |
| `GOOGLE_CLOUD_LOCATION` | GCP region | required |
| `GOOGLE_CLOUD_BUCKET_NAME` | Artifact storage bucket | required |
| `MCP_SERVER_EBS_URL` | MCP Oracle EBS server endpoint | `https://mcp-oracle-ebs-{PROJECT_NUMBER}.{LOCATION}.run.app/mcp` |
| `DEBUG` | Enable verbose logging | `false` |

Copy `env.example` to `.env` and populate before running locally.

## Deployment

```bash
cd Agents/EBS_Master/agents/EBS_API_Agent
python deploy.py
```

This deploys the agent to GCP Agent Engine as a standalone agent. In production it is loaded as a sub-agent by EBS_Master and does not need to be deployed independently.

## Key Files

| File | Purpose |
|---|---|
| `agent.py` | Agent definition and MCP toolset configuration |
| `agent_config.py` | Instruction text, session rules, tool catalogue, response schema |
| `deploy.py` | GCP Agent Engine deployment script |
| `requirements.txt` | Python dependencies |
| `env.example` | Environment variable template |
