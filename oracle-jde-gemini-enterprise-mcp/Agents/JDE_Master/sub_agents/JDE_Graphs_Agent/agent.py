from google.adk import Agent
from google.adk.tools.tool_context import ToolContext
from google.genai.types import (
    AutomaticFunctionCallingConfig,
    SafetySetting,
    HarmCategory,
    HarmBlockThreshold,
    GenerateContentConfig,
    Part,
    Blob,
)

import csv
import io
import json
import logging
import os
import re
import sys
import textwrap
import types

from matplotlib.backends.backend_agg import FigureCanvasAgg
from matplotlib.figure import Figure
import matplotlib.ticker as mticker

# gemini 3 endpoints are currently only accessible in global, so we need to set this env var for the agent to work properly.
os.environ.setdefault("GOOGLE_CLOUD_LOCATION", "us-central1")

# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------
_debug = os.environ.get("DEBUG", "false").lower() == "true"
logger = logging.getLogger("JDE_Graphs_Agent")
logger.setLevel(logging.DEBUG if _debug else logging.INFO)

_BASE_DIR = os.path.dirname(os.path.realpath(__file__))
sys.path.append(_BASE_DIR)

# ---------------------------------------------------------------------------
# Agent config
# ---------------------------------------------------------------------------
try:
    from . import agent_config
except ImportError:
    try:
        import importlib.util as _ilu
        _spec = _ilu.spec_from_file_location(
            "agent_config", os.path.join(_BASE_DIR, "agent_config.py")
        )
        agent_config = _ilu.module_from_spec(_spec)  # type: ignore[no-redef]
        _spec.loader.exec_module(agent_config)  # type: ignore[union-attr]
        logger.debug("Loaded agent_config via importlib from %s", _BASE_DIR)
    except Exception as e:
        logger.error(f"Error importing agent_config: {e}", exc_info=True)
        agent_config = types.SimpleNamespace(  # type: ignore[assignment]
            name="JDE_graph_Agent",
            model="gemini-2.5-flash",
            description="Executive business visualisation agent that turns tabular JSON or CSV data into high-resolution business charts and tables.",
            instruction="Render the provided data as an executive-grade business chart or table with clear headings, formatted values, and structured legends.",
        )

# ---------------------------------------------------------------------------
# Helper utilities
# ---------------------------------------------------------------------------


def _success_envelope(data=None) -> dict:
    return {
        "ok": True,
        "source_agent": "JDE_Graphs_Agent",
        "data": data,
    }


def _error_envelope(*, error_code: str, message: str, retryable: bool, data=None) -> dict:
    return {
        "ok": False,
        "source_agent": "JDE_Graphs_Agent",
        "error_code": error_code,
        "retryable": retryable,
        "message": message,
        "data": data,
    }


def _parse_numeric(val) -> float:
    """Parse a numeric value, stripping currency symbols, commas, or percent signs if present."""
    if val is None:
        return 0.0
    if isinstance(val, (int, float)):
        return float(val)
    s = str(val).strip()
    if not s or s.lower() in ("null", "none", "n/a", "-"):
        return 0.0
    s = re.sub(r"[$,%\s]", "", s)
    try:
        return float(s)
    except ValueError:
        logger.warning(f"Failed to parse numeric value from {val!r}, defaulting to 0.0")
        return 0.0


def _detect_is_currency(title: str, col_name: str, raw_rows: list[dict]) -> bool:
    """Heuristically detect whether the metric represents currency (USD)."""
    combined = f"{title} {col_name}".lower()
    currency_keywords = (
        "usd", "$", "amount", "price", "cost", "expense", "revenue", "budget",
        "allotment", "deduction", "threshold", "benefit", "pay", "salary",
        "invoice", "bid", "claimed", "disallowed", "rejected", "overage", "cap",
    )
    if any(k in combined for k in currency_keywords):
        return True
    for r in raw_rows:
        v = str(r.get(col_name, ""))
        if "$" in v:
            return True
    return False


def _format_value(val: float, is_currency: bool = False) -> str:
    """Format a number for executive display on data labels and legends."""
    abs_v = abs(val)
    if is_currency:
        if abs_v >= 1000 and abs(val - round(val)) < 1e-4:
            return f"${val:,.0f}"
        elif abs_v >= 100 and abs(val - round(val)) < 1e-4:
            return f"${val:,.0f}"
        else:
            return f"${val:,.2f}"
    else:
        if abs(val - round(val)) < 1e-4:
            return f"{int(round(val)):,}"
        return f"{val:,.2f}"


def _parse_data(data: str) -> list[dict]:
    """Parse a JSON or CSV string into a list of row dicts, raising ValueError on bad input."""
    logger.debug(f"_parse_data called with data length={len(data)} chars, preview={data[:80]!r}")
    stripped = data.strip()
    if stripped.startswith("```"):
        stripped = re.sub(r"^```(?:json|csv)?\s*", "", stripped, flags=re.IGNORECASE)
        stripped = re.sub(r"\s*```$", "", stripped).strip()
    if stripped.startswith("[") or stripped.startswith("{"):
        try:
            parsed = json.loads(stripped)
            if isinstance(parsed, dict):
                for k in ("rows", "data", "items", "results"):
                    if isinstance(parsed.get(k), list) and parsed[k]:
                        return parsed[k]
                raise ValueError("JSON dictionary must contain a non-empty list in 'rows', 'data', 'items', or 'results'")
            if isinstance(parsed, list) and parsed:
                return parsed
            raise ValueError("JSON input must be a non-empty list of objects or a dictionary containing rows.")
        except json.JSONDecodeError as exc:
            raise ValueError(f"Invalid JSON data: {exc}") from exc
    reader = csv.DictReader(io.StringIO(stripped))
    rows = list(reader)
    if not rows:
        raise ValueError("data must be a non-empty JSON array of objects or a CSV string with a header row.")
    return rows


def _sort_data(rows: list[dict], sort_column: str, sort_order: str) -> list[dict]:
    """Return rows sorted by *sort_column*."""
    if not sort_column:
        return rows

    reverse = sort_order.strip().lower() == "desc"

    def _key(row: dict):
        val = row.get(sort_column, "")
        try:
            return (0, _parse_numeric(val))
        except (TypeError, ValueError):
            return (1, str(val).lower())

    return sorted(rows, key=_key, reverse=reverse)


def _fig_to_png_bytes(fig: Figure) -> bytes:
    """Render a matplotlib Figure to high-DPI PNG bytes with generous padding."""
    FigureCanvasAgg(fig)
    buf = io.BytesIO()
    fig.savefig(
        buf,
        format="png",
        dpi=180,
        bbox_inches="tight",
        pad_inches=0.38,
        facecolor=fig.get_facecolor(),
        edgecolor="none",
    )
    buf.seek(0)
    png_bytes = buf.read()
    logger.debug(f"PNG rendered: {len(png_bytes)} bytes")
    return png_bytes


# ---------------------------------------------------------------------------
# Executive Styling and Palettes
# ---------------------------------------------------------------------------
COLOR_PALETTES = {
    "corporate": [
        "#0B57D0",  # Google Executive Blue
        "#D93025",  # Executive Crimson / Alert
        "#188038",  # Executive Emerald Green
        "#F29900",  # Executive Amber Gold
        "#7627BB",  # Executive Royal Purple
        "#007B83",  # Executive Deep Teal
        "#1E3A8A",  # Navy Slate
        "#C2410C",  # Rust Orange
    ],
    "default": [
        "#0B57D0", "#188038", "#F29900", "#D93025", "#7627BB", "#007B83", "#334155", "#0284C7"
    ],
    "vibrant": [
        "#1A73E8", "#EA4335", "#34A853", "#FBBC04", "#9334E6", "#00ACC1", "#F4511E", "#3949AB"
    ],
    "monochrome_blue": [
        "#0B57D0", "#1D4ED8", "#2563EB", "#3B82F6", "#60A5FA", "#93C5FD", "#1E3A8A", "#1E40AF"
    ],
    "pastel": [
        "#3B82F6", "#10B981", "#F59E0B", "#EF4444", "#8B5CF6", "#14B8A6", "#64748B", "#EC4899"
    ],
}


def _get_colors(palette_name: str, count: int) -> list[str]:
    palette = COLOR_PALETTES.get((palette_name or "corporate").lower(), COLOR_PALETTES["corporate"])
    return [palette[i % len(palette)] for i in range(count)]


def _humanize_label(text: str) -> str:
    """Turn snake_case or raw column identifiers into clean Title Case headings."""
    if not text:
        return ""
    cleaned = str(text).replace("_", " ").strip()
    if cleaned.islower() or cleaned.isupper():
        cleaned = cleaned.title()
    for acr in ("USD", "PSFT", "FOIA", "SNAP", "TANF", "RFP", "SLA", "GSA", "CFR", "PII", "PHI", "FTI", "CJIS", "YTD", "PO", "AP", "ID"):
        cleaned = re.sub(rf"\b{acr}\b", acr, cleaned, flags=re.IGNORECASE)
    return cleaned


def _draw_executive_header_and_footer(
    fig: Figure,
    title: str,
    subtitle: str,
    kpi_pill_text: str = "",
):
    """Draw a consistent executive header block, KPI summary badge, and source footer on the figure."""
    fig.patch.set_facecolor("#FFFFFF")

    # Full-width top title row (never overlaps the KPI pill on the subtitle row)
    fig.suptitle(
        title,
        x=0.04,
        y=0.968,
        ha="left",
        va="top",
        fontsize=14.5,
        fontweight="bold",
        color="#0F172A",
    )
    if subtitle:
        fig.text(
            0.04,
            0.902,
            subtitle,
            ha="left",
            va="center",
            fontsize=10.0,
            fontweight="normal",
            color="#475569",
        )
    if kpi_pill_text:
        fig.text(
            0.96,
            0.902,
            kpi_pill_text,
            ha="right",
            va="center",
            fontsize=9.5,
            fontweight="bold",
            color="#0B57D0",
            bbox=dict(
                boxstyle="round,pad=0.40",
                facecolor="#EFF6FF",
                edgecolor="#BFDBFE",
                linewidth=1.2,
            ),
        )

    # Footer metadata line at very bottom
    fig.text(
        0.04,
        0.012,
        "Source: Oracle JD Edwards EnterpriseOne 9.2 (JPD920 / Branch M30) • Discrete Manufacturing Analytics",
        ha="left",
        va="bottom",
        fontsize=8.5,
        style="italic",
        color="#64748B",
    )


# ---------------------------------------------------------------------------
# Visualisation tools
# ---------------------------------------------------------------------------


def render_table(
    data: str,
    title: str = "",
    sort_column: str = "",
    sort_order: str = "asc",
) -> dict:
    """Render tabular JSON or CSV data as a Markdown table."""
    logger.info(f"render_table called: title={title!r}, sort_column={sort_column!r}, sort_order={sort_order!r}")
    try:
        rows = _sort_data(_parse_data(data), sort_column, sort_order)
        columns = list(rows[0].keys())

        header = "| " + " | ".join(str(c) for c in columns) + " |"
        separator = "| " + " | ".join("---" for _ in columns) + " |"
        body_lines = [
            "| " + " | ".join(str(row.get(c, "")) for c in columns) + " |"
            for row in rows
        ]

        table_md = "\n".join([header, separator] + body_lines)
        if title:
            table_md = f"**{title}**\n\n{table_md}"

        return {
            "status": "success",
            "result": table_md,
            **_success_envelope({"result": table_md}),
        }
    except Exception as exc:
        logger.error(f"render_table error: {exc}", exc_info=True)
        return {
            "status": "error",
            "error": str(exc),
            **_error_envelope(
                error_code="VISUALIZATION_ERROR",
                message=str(exc),
                retryable=False,
            ),
        }


def render_bar_chart(
    data: str,
    x_column: str,
    y_column: str,
    title: str = "Executive Category Comparison",
    sort_column: str = "",
    sort_order: str = "asc",
    palette: str = "corporate",
    tool_context: ToolContext = None,
) -> dict:
    """Render tabular JSON or CSV data as an executive-grade business bar chart with clear headings, direct data labels, and a structured legend."""
    logger.info(f"render_bar_chart called: x={x_column!r}, y={y_column!r}, title={title!r}")
    try:
        raw_rows = _parse_data(data)
        rows = _sort_data(raw_rows, sort_column, sort_order)
        if not rows:
            return {
                "status": "error",
                "error": "No data available to render chart.",
                **_error_envelope(
                    error_code="NO_DATA",
                    message="No data available to render chart.",
                    retryable=False,
                ),
            }
        if x_column not in rows[0]:
            raise ValueError(f"x_column '{x_column}' not found in data. Available columns: {list(rows[0].keys())}")
        if y_column not in rows[0]:
            raise ValueError(f"y_column '{y_column}' not found in data. Available columns: {list(rows[0].keys())}")
        x_vals = [str(row.get(x_column, "")).strip() for row in rows]
        y_vals = [_parse_numeric(row.get(y_column, 0)) for row in rows]
        is_curr = _detect_is_currency(title, y_column, rows)

        total_val = sum(y_vals)
        max_val = max(y_vals) if y_vals else 1.0
        min_val = min(y_vals) if y_vals else 0.0
        max_idx = y_vals.index(max_val) if y_vals else 0
        top_cat = x_vals[max_idx] if x_vals else "N/A"

        fig = Figure(figsize=(12.0, 6.6))
        ax = fig.add_subplot(111)
        fig.subplots_adjust(left=0.09, right=0.62, top=0.80, bottom=0.23)
        ax.set_facecolor("#F8FAFC")

        colors = _get_colors(palette, len(x_vals))
        wrap_w = 13 if len(x_vals) >= 5 else (16 if len(x_vals) == 4 else 20)
        wrapped_x = [textwrap.fill(lbl, width=wrap_w) for lbl in x_vals]

        bars = ax.bar(
            range(len(x_vals)),
            y_vals,
            color=colors,
            edgecolor="#FFFFFF",
            linewidth=1.5,
            width=0.56,
            zorder=3,
        )

        # Clean grid and spines
        ax.spines["top"].set_visible(False)
        ax.spines["right"].set_visible(False)
        ax.spines["left"].set_color("#CBD5E1")
        ax.spines["bottom"].set_color("#94A3B8")
        ax.spines["bottom"].set_linewidth(1.2)
        ax.grid(axis="y", linestyle="--", linewidth=0.8, alpha=0.85, color="#E2E8F0", zorder=0)
        ax.set_axisbelow(True)

        # Y-axis formatting & headroom for direct bar labels
        ax.set_ylim(min(0.0, min_val * 1.1), max_val * 1.25 if max_val > 0 else 10)
        if is_curr:
            ax.yaxis.set_major_formatter(
                mticker.FuncFormatter(lambda x, pos: f"${x:,.0f}" if abs(x) >= 10 else f"${x:,.2f}")
            )
        else:
            ax.yaxis.set_major_formatter(
                mticker.FuncFormatter(lambda x, pos: f"{int(x):,}" if abs(x - round(x)) < 1e-4 else f"{x:,.1f}")
            )

        ax.set_xticks(range(len(x_vals)))
        rot = 0 if len(x_vals) <= 5 else 15
        ha_align = "center" if rot == 0 else "right"
        x_fs = 8.8 if len(x_vals) >= 5 else 9.5
        ax.set_xticklabels(wrapped_x, rotation=rot, ha=ha_align, fontsize=x_fs, fontweight="bold", color="#1E293B")
        ax.tick_params(axis="y", labelsize=10, colors="#334155")

        x_heading = _humanize_label(x_column)
        y_heading = _humanize_label(y_column) + (" (USD)" if is_curr and "USD" not in y_column.upper() else "")
        ax.set_xlabel(x_heading, labelpad=8, fontsize=11, fontweight="bold", color="#334155")
        ax.set_ylabel(y_heading, labelpad=10, fontsize=11, fontweight="bold", color="#334155")

        # Direct value + percentage labels above every bar
        for bar, val in zip(bars, y_vals):
            pct = (val / total_val * 100.0) if total_val > 0 else 0.0
            val_str = _format_value(val, is_curr)
            label_text = f"{val_str}\n({pct:.1f}%)" if len(x_vals) <= 6 and total_val > 0 else val_str
            ax.annotate(
                label_text,
                xy=(bar.get_x() + bar.get_width() / 2.0, bar.get_height()),
                xytext=(0, 6),
                textcoords="offset points",
                ha="center",
                va="bottom",
                fontsize=9.5,
                fontweight="bold",
                color="#0F172A",
            )

        # Structured Executive Legend on the right (wrapped cleanly, no truncation)
        legend_handles = []
        legend_labels = []
        for bar, cat, val in zip(bars, x_vals, y_vals):
            pct = (val / total_val * 100.0) if total_val > 0 else 0.0
            wrapped_cat = textwrap.fill(cat, width=36)
            legend_handles.append(bar)
            legend_labels.append(f"{wrapped_cat}\n   {_format_value(val, is_curr)} ({pct:.1f}%)")

        leg = ax.legend(
            legend_handles,
            legend_labels,
            title=f"{x_heading} Breakdown",
            bbox_to_anchor=(1.03, 1.0),
            loc="upper left",
            frameon=True,
            facecolor="#F8FAFC",
            edgecolor="#CBD5E1",
            fontsize=9.0,
            title_fontsize=10.5,
            labelspacing=0.80,
            borderpad=0.9,
        )
        leg.get_title().set_fontweight("bold")
        leg.get_title().set_color("#0F172A")

        subtitle = f"Metric: {y_heading}  |  Highest: {textwrap.shorten(top_cat, width=58, placeholder='…')} ({_format_value(max_val, is_curr)})"
        kpi_pill = f"Total: {_format_value(total_val, is_curr)}  •  {len(x_vals)} Categories"
        _draw_executive_header_and_footer(fig, title, subtitle, kpi_pill)

        png_bytes = _fig_to_png_bytes(fig)
        safe_name = re.sub(r"[^a-z0-9_]+", "_", title.lower()).strip("_") or "bar_chart"
        filename = f"{safe_name}.png"
        if tool_context is not None:
            artifact = Part(inline_data=Blob(mime_type="image/png", data=png_bytes))
            tool_context.save_artifact(filename=filename, artifact=artifact)

        logger.info(f"render_bar_chart succeeded: {len(x_vals)} bars, saved as {filename!r}")
        return {
            "status": "success",
            "filename": filename,
            "summary": f"Rendered executive bar chart '{title}' across {len(x_vals)} categories (Total: {_format_value(total_val, is_curr)}, Top: {top_cat} at {_format_value(max_val, is_curr)}).",
            **_success_envelope({"filename": filename}),
        }
    except Exception as exc:
        logger.error(f"render_bar_chart error: {exc}", exc_info=True)
        return {
            "status": "error",
            "error": str(exc),
            **_error_envelope(
                error_code="VISUALIZATION_ERROR",
                message=str(exc),
                retryable=False,
            ),
        }


def render_line_chart(
    data: str,
    x_column: str,
    y_columns: str,
    title: str = "Executive Trend Analysis",
    sort_column: str = "",
    sort_order: str = "asc",
    palette: str = "corporate",
    tool_context: ToolContext = None,
) -> dict:
    """Render tabular JSON or CSV data as an executive-grade line chart with shaded area fill, node callouts, and structured legend."""
    logger.info(f"render_line_chart called: x={x_column!r}, y_columns={y_columns!r}, title={title!r}")
    try:
        raw_rows = _parse_data(data)
        rows = _sort_data(raw_rows, sort_column, sort_order)
        if not rows:
            return {
                "status": "error",
                "error": "No data available to render chart.",
                **_error_envelope(
                    error_code="NO_DATA",
                    message="No data available to render chart.",
                    retryable=False,
                ),
            }
        if x_column not in rows[0]:
            raise ValueError(f"x_column '{x_column}' not found in data. Available columns: {list(rows[0].keys())}")
        x_vals = [str(row.get(x_column, "")).strip() for row in rows]
        y_col_list = [c.strip() for c in y_columns.split(",") if c.strip()]
        if not y_col_list:
            raise ValueError("y_columns must specify at least one column.")
        for col in y_col_list:
            if col not in rows[0]:
                raise ValueError(f"y_column '{col}' not found in data. Available columns: {list(rows[0].keys())}")
        is_curr = _detect_is_currency(title, y_col_list[0], rows)

        fig = Figure(figsize=(12.0, 6.6))
        ax = fig.add_subplot(111)
        fig.subplots_adjust(left=0.09, right=0.64, top=0.80, bottom=0.22)
        ax.set_facecolor("#F8FAFC")

        colors = _get_colors(palette, len(y_col_list))
        all_vals = []

        for i, col in enumerate(y_col_list):
            y_vals = [_parse_numeric(row.get(col, 0)) for row in rows]
            all_vals.extend(y_vals)
            clean_col = _humanize_label(col)
            max_val = max(y_vals) if y_vals else 0.0
            line_label = f"{clean_col} (Max: {_format_value(max_val, is_curr)})"
            ax.plot(
                range(len(x_vals)),
                y_vals,
                marker="o",
                markersize=7.5,
                markerfacecolor="#FFFFFF",
                markeredgewidth=2.2,
                markeredgecolor=colors[i],
                linewidth=2.8,
                color=colors[i],
                label=line_label,
                zorder=4,
            )
            if len(y_col_list) == 1:
                ax.fill_between(range(len(x_vals)), y_vals, color=colors[i], alpha=0.10, zorder=2)

            for idx, val in enumerate(y_vals):
                ax.annotate(
                    _format_value(val, is_curr),
                    xy=(idx, val),
                    xytext=(0, 8),
                    textcoords="offset points",
                    ha="center",
                    va="bottom",
                    fontsize=9.0,
                    fontweight="bold",
                    color="#0F172A",
                )

        max_v = max(all_vals) if all_vals else 10.0
        min_v = min(all_vals) if all_vals else 0.0
        ax.set_ylim(min(0.0, min_v * 1.1), max_v * 1.25 if max_v > 0 else 10.0)

        ax.spines["top"].set_visible(False)
        ax.spines["right"].set_visible(False)
        ax.spines["left"].set_color("#CBD5E1")
        ax.spines["bottom"].set_color("#94A3B8")
        ax.grid(axis="y", linestyle="--", linewidth=0.8, alpha=0.85, color="#E2E8F0", zorder=0)

        if is_curr:
            ax.yaxis.set_major_formatter(
                mticker.FuncFormatter(lambda x, pos: f"${x:,.0f}" if abs(x) >= 10 else f"${x:,.2f}")
            )

        wrapped_x = [textwrap.fill(lbl, width=18) for lbl in x_vals]
        ax.set_xticks(range(len(x_vals)))
        rot = 0 if len(x_vals) <= 6 else 18
        ax.set_xticklabels(wrapped_x, rotation=rot, ha="center" if rot == 0 else "right", fontsize=9.5, fontweight="bold", color="#1E293B")
        ax.tick_params(axis="y", labelsize=10, colors="#334155")

        x_heading = _humanize_label(x_column)
        y_heading = _humanize_label(y_col_list[0]) if len(y_col_list) == 1 else "Metric Value"
        ax.set_xlabel(x_heading, labelpad=8, fontsize=11, fontweight="bold", color="#334155")
        ax.set_ylabel(y_heading, labelpad=10, fontsize=11, fontweight="bold", color="#334155")

        leg = ax.legend(
            title="Series & Peak Summary",
            bbox_to_anchor=(1.03, 1.0),
            loc="upper left",
            frameon=True,
            facecolor="#F8FAFC",
            edgecolor="#CBD5E1",
            fontsize=9.5,
            title_fontsize=10.5,
            borderpad=0.9,
        )
        leg.get_title().set_fontweight("bold")
        leg.get_title().set_color("#0F172A")

        subtitle = f"Trend across {len(x_vals)} intervals  |  Peak Value: {_format_value(max_v, is_curr)}"
        kpi_pill = f"{len(y_col_list)} Series  •  {len(x_vals)} Data Points"
        _draw_executive_header_and_footer(fig, title, subtitle, kpi_pill)

        png_bytes = _fig_to_png_bytes(fig)
        safe_name = re.sub(r"[^a-z0-9_]+", "_", title.lower()).strip("_") or "line_chart"
        filename = f"{safe_name}.png"
        if tool_context is not None:
            artifact = Part(inline_data=Blob(mime_type="image/png", data=png_bytes))
            tool_context.save_artifact(filename=filename, artifact=artifact)

        return {
            "status": "success",
            "filename": filename,
            "summary": f"Rendered executive line chart '{title}' with {len(x_vals)} points.",
            **_success_envelope({"filename": filename}),
        }
    except Exception as exc:
        logger.error(f"render_line_chart error: {exc}", exc_info=True)
        return {
            "status": "error",
            "error": str(exc),
            **_error_envelope(
                error_code="VISUALIZATION_ERROR",
                message=str(exc),
                retryable=False,
            ),
        }


def render_pie_chart(
    data: str,
    label_column: str,
    value_column: str,
    title: str = "Executive Portfolio Share Breakdown",
    sort_column: str = "",
    sort_order: str = "desc",
    palette: str = "corporate",
    tool_context: ToolContext = None,
) -> dict:
    """Render tabular JSON or CSV data as an executive donut/pie chart with center KPI callout, slice percentages, and a detailed business legend."""
    logger.info(f"render_pie_chart called: label={label_column!r}, value={value_column!r}, title={title!r}")
    try:
        raw_rows = _parse_data(data)
        rows = _sort_data(raw_rows, sort_column or value_column, sort_order or "desc")
        if not rows:
            return {
                "status": "error",
                "error": "No data available to render chart.",
                **_error_envelope(
                    error_code="NO_DATA",
                    message="No data available to render chart.",
                    retryable=False,
                ),
            }
        if label_column not in rows[0]:
            raise ValueError(f"label_column '{label_column}' not found in data. Available columns: {list(rows[0].keys())}")
        if value_column not in rows[0]:
            raise ValueError(f"value_column '{value_column}' not found in data. Available columns: {list(rows[0].keys())}")
        labels = [str(row.get(label_column, "")).strip() for row in rows]
        values = [_parse_numeric(row.get(value_column, 0)) for row in rows]
        if any(v < 0 for v in values):
            values = [abs(v) for v in values]
        is_curr = _detect_is_currency(title, value_column, rows)

        total_val = sum(values)
        if total_val <= 0:
            raise ValueError("Total value must be greater than zero to render a pie chart.")
        max_val = max(values) if values else 0.0
        max_idx = values.index(max_val) if values else 0
        top_label = labels[max_idx] if labels else "N/A"
        top_pct = (max_val / total_val * 100.0) if total_val > 0 else 0.0

        fig = Figure(figsize=(12.0, 6.6))
        ax = fig.add_subplot(111)
        fig.subplots_adjust(left=0.04, right=0.54, top=0.80, bottom=0.14)

        colors = _get_colors(palette, len(labels))

        def _autopct_fmt(pct: float) -> str:
            if pct < 4.5:
                return ""
            val = pct * total_val / 100.0
            return f"{pct:.1f}%\n({_format_value(val, is_curr)})"

        wedges, texts, autotexts = ax.pie(
            values,
            labels=None,  # Clean executive legend on the right prevents label clipping
            autopct=_autopct_fmt,
            pctdistance=0.74,
            startangle=140,
            colors=colors,
            wedgeprops=dict(width=0.52, edgecolor="#FFFFFF", linewidth=2.5),
        )

        for autotext in autotexts:
            autotext.set_color("#FFFFFF")
            autotext.set_fontsize(9.5)
            autotext.set_fontweight("bold")

        # Center KPI Callout inside the Donut Hole
        ax.text(
            0,
            0.08,
            "TOTAL",
            ha="center",
            va="center",
            fontsize=9.5,
            fontweight="bold",
            color="#64748B",
        )
        ax.text(
            0,
            -0.08,
            _format_value(total_val, is_curr),
            ha="center",
            va="center",
            fontsize=15.0,
            fontweight="bold",
            color="#0F172A",
        )

        # Structured Executive Legend Box on the right with full Category, Exact Value, and Share %
        label_heading = _humanize_label(label_column)
        val_heading = _humanize_label(value_column)
        legend_labels = []
        for lbl, val in zip(labels, values):
            pct = (val / total_val * 100.0) if total_val > 0 else 0.0
            wrapped_lbl = textwrap.fill(lbl, width=42)
            legend_labels.append(f"{wrapped_lbl}\n   {_format_value(val, is_curr)}  ({pct:.1f}% share)")

        leg = ax.legend(
            wedges,
            legend_labels,
            title=f"{label_heading} & {val_heading} Share",
            bbox_to_anchor=(1.02, 0.96),
            loc="upper left",
            frameon=True,
            facecolor="#F8FAFC",
            edgecolor="#CBD5E1",
            fontsize=9.2,
            title_fontsize=10.5,
            labelspacing=0.85,
            borderpad=1.0,
        )
        leg.get_title().set_fontweight("bold")
        leg.get_title().set_color("#0F172A")

        ax.set_aspect("equal")

        subtitle = (
            f"Primary Driver: {textwrap.shorten(top_label, width=62, placeholder='…')} "
            f"({_format_value(max_val, is_curr)} / {top_pct:.1f}% of Total)"
        )
        kpi_pill = f"Total: {_format_value(total_val, is_curr)}  •  {len(labels)} Categories"
        _draw_executive_header_and_footer(fig, title, subtitle, kpi_pill)

        png_bytes = _fig_to_png_bytes(fig)
        safe_name = re.sub(r"[^a-z0-9_]+", "_", title.lower()).strip("_") or "pie_chart"
        filename = f"{safe_name}.png"
        if tool_context is not None:
            artifact = Part(inline_data=Blob(mime_type="image/png", data=png_bytes))
            tool_context.save_artifact(filename=filename, artifact=artifact)

        logger.info(f"render_pie_chart succeeded: {len(labels)} slices, saved as {filename!r}")
        return {
            "status": "success",
            "filename": filename,
            "summary": f"Rendered executive donut/pie chart '{title}' across {len(labels)} categories (Total: {_format_value(total_val, is_curr)}, Top Category: {top_label} at {_format_value(max_val, is_curr)} / {top_pct:.1f}%).",
            **_success_envelope({"filename": filename}),
        }
    except Exception as exc:
        logger.error(f"render_pie_chart error: {exc}", exc_info=True)
        return {
            "status": "error",
            "error": str(exc),
            **_error_envelope(
                error_code="VISUALIZATION_ERROR",
                message=str(exc),
                retryable=False,
            ),
        }


# ---------------------------------------------------------------------------
# Root agent
# ---------------------------------------------------------------------------

root_agent = Agent(
    name=agent_config.name,
    model=agent_config.model,
    description=agent_config.description,
    instruction=agent_config.instruction,
    tools=[render_table, render_bar_chart, render_line_chart, render_pie_chart],
    generate_content_config=GenerateContentConfig(
        automatic_function_calling=AutomaticFunctionCallingConfig(disable=True),
        temperature=0,
        safety_settings=[
            SafetySetting(
                category=HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT,
                threshold=HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
            ),
            SafetySetting(
                category=HarmCategory.HARM_CATEGORY_HARASSMENT,
                threshold=HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
            ),
            SafetySetting(
                category=HarmCategory.HARM_CATEGORY_HATE_SPEECH,
                threshold=HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
            ),
            SafetySetting(
                category=HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT,
                threshold=HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
            ),
        ],
    ),
)
