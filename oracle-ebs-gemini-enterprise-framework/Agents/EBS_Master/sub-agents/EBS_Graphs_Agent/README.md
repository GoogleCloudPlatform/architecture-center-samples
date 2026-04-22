# EBS Graphs Agent

The EBS Graphs Agent is a visualisation specialist sub-agent. It receives structured data (typically provided by EBS_SQL_Agent) and renders it as charts or formatted tables. Charts are produced using matplotlib with a non-interactive `Agg` backend and saved as PNG artifacts. Tables are returned as Markdown strings.

## Responsibilities

- Render bar, line, and pie charts from tabular data
- Render formatted Markdown tables
- Accept data in JSON array or CSV format (auto-detected)
- Sort data by any column before rendering
- Save PNG chart artifacts for downstream display

## Data Input Formats

| Format | Detection | Example |
|---|---|---|
| JSON array | Input starts with `[` | `[{"month":"Jan","revenue":1200}, …]` |
| CSV with header | Input starts with a letter and contains commas | `month,revenue\nJan,1200\n…` |

The agent auto-detects the format. No format hint is needed.

## Tool Reference

### `render_table`

Renders data as a Markdown table.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `data` | string | yes | JSON array or CSV string |
| `title` | string | no | Table title (rendered as a heading above the table) |
| `sort_column` | string | no | Column name to sort by before rendering |
| `sort_order` | string | no | `"asc"` (default) or `"desc"` |

Returns a Markdown string.

---

### `render_bar_chart`

Renders a vertical bar chart and saves it as a PNG artifact.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `data` | string | yes | JSON array or CSV string |
| `x_column` | string | yes | Column to use for the X-axis (categories) |
| `y_column` | string | yes | Column to use for bar heights (numeric) |
| `title` | string | no | Chart title |
| `sort_column` | string | no | Column name to sort by before rendering |
| `sort_order` | string | no | `"asc"` or `"desc"` |

Returns the artifact filename of the saved PNG.

---

### `render_line_chart`

Renders a line chart and saves it as a PNG artifact.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `data` | string | yes | JSON array or CSV string |
| `x_column` | string | yes | Column to use for the X-axis (ordered categories or dates) |
| `y_columns` | string | yes | Comma-separated column name(s) for Y-axis series. Example: `"Revenue"` or `"Revenue,Cost,Profit"` |
| `title` | string | no | Chart title |
| `sort_column` | string | no | Column name to sort by before rendering |
| `sort_order` | string | no | `"asc"` or `"desc"` |

Returns the artifact filename of the saved PNG.

---

### `render_pie_chart`

Renders a pie chart and saves it as a PNG artifact.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `data` | string | yes | JSON array or CSV string |
| `label_column` | string | yes | Column containing the slice labels |
| `value_column` | string | yes | Column containing the numeric values |
| `title` | string | no | Chart title |
| `sort_column` | string | no | Column name to sort by before rendering |
| `sort_order` | string | no | `"asc"` or `"desc"` |

Returns the artifact filename of the saved PNG.

## Chart Type Selection Guide

| Data characteristic | Recommended chart |
|---|---|
| Compare values across discrete categories | Bar chart |
| Show a trend over time or an ordered sequence | Line chart |
| Show proportional composition (parts of a whole) | Pie chart |
| Multi-column tabular data with no clear visual story | Table |

## Typical Workflow

The EBS_Graphs_Agent does not query EBS directly. It is always given data by the EBS Master Agent, which first retrieves it via EBS_SQL_Agent:

```
User: "Show me a bar chart of AP invoices by vendor for this month"
      │
EBS Master
      ├──▶ EBS_SQL_Agent  ──▶  SQL query  ──▶  JSON result
      │
      └──▶ EBS_Graphs_Agent(data=<json>, x_column="vendor", y_column="total_amount")
                  │
                  └──▶  render_bar_chart  ──▶  PNG artifact saved
```

## Output

- **Charts**: Saved as PNG artifacts via `tool_context.save_artifact()`. The artifact key/filename is returned and can be referenced for display in the front-end.
- **Tables**: Returned as a Markdown string directly in the agent response.

## Environment Variables

| Variable | Description | Default |
|---|---|---|
| `GOOGLE_CLOUD_PROJECT` | GCP project ID | required |
| `GOOGLE_CLOUD_PROJECT_NUMBER` | GCP project number | required |
| `GOOGLE_CLOUD_LOCATION` | GCP region | required |
| `GOOGLE_CLOUD_BUCKET_NAME` | Artifact storage bucket (PNG artifacts saved here) | required |

Copy `env.example` (from a sibling agent directory) to `.env` and populate before running locally. The Graphs Agent does not connect to EBS or a database directly, so no MCP server URL is required.

## Deployment

```bash
cd Agents/EBS_Master/agents/EBS_Graphs_Agent
python -c "from agent import root_agent; print(root_agent)"
```

The Graphs Agent is stateless and has no external service dependencies beyond GCP artifact storage. In production it is loaded as a sub-agent by EBS_Master.

## Key Files

| File | Purpose |
|---|---|
| `agent.py` | Agent definition, all four tool implementations, matplotlib rendering logic |
| `agent_config.py` | Instruction text, chart type selection rules |
| `__init__.py` | Package export |
| `requirements.txt` | Python dependencies (matplotlib, Pillow) |
