from google.adk import Agent
from google.adk.tools import ToolContext
from google.genai.types import (
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
import sys
import types

import matplotlib
matplotlib.use("Agg")  # non-interactive backend — safe for server-side rendering
import matplotlib.pyplot as plt

# gemini 3 endpoints are currently only accessible in global, so we need to set this env var for the agent to work properly.
os.environ['GOOGLE_CLOUD_LOCATION'] = 'global'

# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------
_debug = os.environ.get("DEBUG", "false").lower() == "true"
logging.basicConfig(
    level=logging.DEBUG if _debug else logging.INFO,
    format="[%(levelname)s] %(name)s: %(message)s",
)
logger = logging.getLogger("EBS_Graphs_Agent")
# Set this logger's level directly so it works even when basicConfig is a no-op
# (i.e. when another module has already configured the root logger).
logger.setLevel(logging.DEBUG if _debug else logging.INFO)

# Compute at module parse-time — immune to cwd changes when imported by a parent.
_BASE_DIR = os.path.dirname(os.path.realpath(__file__))
sys.path.append(_BASE_DIR)

# ---------------------------------------------------------------------------
# Agent config
# ---------------------------------------------------------------------------
try:
    from . import agent_config
except ImportError:
    # Load directly from _BASE_DIR using importlib so we never accidentally
    # pick up another agent's agent_config from sys.path.
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
            name="EBS_Graphs_Agent",
            model="gemini-2.5-flash",
            description="Visualisation agent that turns tabular JSON data into charts and tables.",
            instruction="Render the provided data as the most appropriate chart or table.",
        )

# ---------------------------------------------------------------------------
# Helper utilities
# ---------------------------------------------------------------------------


def _success_envelope(data=None) -> dict:
    return {
        "ok": True,
        "source_agent": "EBS_Graphs_Agent",
        "data": data,
    }


def _error_envelope(*, error_code: str, message: str, retryable: bool, data=None) -> dict:
    return {
        "ok": False,
        "source_agent": "EBS_Graphs_Agent",
        "error_code": error_code,
        "retryable": retryable,
        "message": message,
        "data": data,
    }

def _parse_data(data: str) -> list[dict]:
    """Parse a JSON or CSV string into a list of row dicts, raising ValueError on bad input.

    Auto-detects format: tries JSON first (if the string starts with '[' or '{'),
    then falls back to CSV parsing via csv.DictReader.
    """
    logger.debug(f"_parse_data called with data length={len(data)} chars, preview={data[:80]!r}")
    stripped = data.strip()
    if stripped.startswith("[") or stripped.startswith("{"):
        logger.debug("Attempting JSON parse")
        try:
            rows = json.loads(stripped)
            if isinstance(rows, list) and rows:
                logger.debug(f"JSON parse succeeded: {len(rows)} rows, columns={list(rows[0].keys())}")
                return rows
            logger.debug("JSON parsed but result was empty or not a list; falling through to CSV")
        except json.JSONDecodeError as exc:
            logger.debug(f"JSON parse failed ({exc}); falling through to CSV")
    # CSV fallback
    logger.debug("Attempting CSV parse")
    reader = csv.DictReader(io.StringIO(stripped))
    rows = list(reader)
    if not rows:
        raise ValueError("data must be a non-empty JSON array of objects or a CSV string with a header row.")
    logger.debug(f"CSV parse succeeded: {len(rows)} rows, columns={list(rows[0].keys())}")
    return rows


def _sort_data(rows: list[dict], sort_column: str, sort_order: str) -> list[dict]:
    """Return rows sorted by *sort_column*.

    Args:
        rows:        List of row dicts produced by _parse_data.
        sort_column: Column name to sort by.  Empty string means no sorting.
        sort_order:  "asc" (default) or "desc" (case-insensitive).

    Returns:
        A new sorted list (original list is not mutated).
    """
    if not sort_column:
        return rows

    reverse = sort_order.strip().lower() == "desc"
    logger.debug(f"_sort_data: sorting by {sort_column!r}, reverse={reverse}")

    def _key(row: dict):
        val = row.get(sort_column, "")
        try:
            return (0, float(val))   # numeric sort
        except (TypeError, ValueError):
            return (1, str(val).lower())  # string sort

    return sorted(rows, key=_key, reverse=reverse)


def _fig_to_png_bytes(fig: plt.Figure) -> bytes:
    """Render a matplotlib Figure to raw PNG bytes."""
    logger.debug("Rendering figure to PNG buffer")
    buf = io.BytesIO()
    fig.savefig(buf, format="png", bbox_inches="tight")
    plt.close(fig)
    buf.seek(0)
    png_bytes = buf.read()
    logger.debug(f"PNG rendered: {len(png_bytes)} bytes")
    return png_bytes


# ---------------------------------------------------------------------------
# Styling and Palettes
# ---------------------------------------------------------------------------
COLOR_PALETTES = {
    "default": ["#4C72B0", "#DD8452", "#55A868", "#C44E52", "#8172B3", "#937860", "#DA8BC3", "#8C8C8C", "#CCB974", "#64B5CD"],
    "corporate": ["#003f5c", "#2f4b7c", "#665191", "#a05195", "#d45087", "#f95d6a", "#ff7c43", "#ffa600"],
    "pastel": ["#fbb4ae", "#b3cde3", "#ccebc5", "#decbe4", "#fed9a6", "#ffffcc", "#e5d8bd", "#fddaec", "#f2f2f2"],
    "monochrome_blue": ["#08306b", "#08519c", "#2171b5", "#4292c6", "#6baed6", "#9ecae1", "#c6dbef", "#deebf7", "#f7fbff"],
    "vibrant": ["#e60049", "#0bb4ff", "#50e991", "#e6d800", "#9b19f5", "#ffa300", "#dc0ab4", "#b3d4ff", "#00bfa0"]
}

def _apply_professional_style(ax, title, x_label=None, y_label=None):
    """Apply a clean, professional style to matplotlib axes."""
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.spines['left'].set_color('#dddddd')
    ax.spines['bottom'].set_color('#dddddd')
    ax.tick_params(colors='#555555', bottom=True, left=True)
    ax.grid(axis='y', linestyle='--', alpha=0.7, color='#eeeeee')
    if title:
        ax.set_title(title, pad=20, fontsize=14, fontweight='bold', color='#333333')
    if x_label:
        ax.set_xlabel(x_label, labelpad=10, fontsize=11, color='#555555')
    if y_label:
        ax.set_ylabel(y_label, labelpad=10, fontsize=11, color='#555555')
    plt.xticks(fontsize=10)
    plt.yticks(fontsize=10)

def _get_colors(palette_name, count):
    """Return a list of colors from the requested palette, looping if necessary."""
    palette = COLOR_PALETTES.get(palette_name.lower(), COLOR_PALETTES["default"])
    return [palette[i % len(palette)] for i in range(count)]


# ---------------------------------------------------------------------------
# Visualisation tools
# ---------------------------------------------------------------------------

def render_table(
    data: str,
    title: str = "",
    sort_column: str = "",
    sort_order: str = "asc",
) -> dict:
    """Render tabular JSON or CSV data as a Markdown table.

    Args:
        data:        A JSON array of objects, or a CSV string with a header row.
                     JSON example: '[{"Month":"Jan","Revenue":1200},{"Month":"Feb","Revenue":1500}]'
                     CSV example:  "Month,Revenue\nJan,1200\nFeb,1500"
        title:       Optional title displayed above the table.
        sort_column: Optional column name to sort rows by before rendering.
        sort_order:  "asc" (ascending, default) or "desc" (descending).

    Returns:
        A dict with keys:
            status  – "success" or "error"
            result  – Markdown table string (on success)
            error   – error message (on failure)
    """
    logger.info(f"render_table called: title={title!r}, sort_column={sort_column!r}, sort_order={sort_order!r}")
    try:
        rows = _sort_data(_parse_data(data), sort_column, sort_order)
        columns = list(rows[0].keys())
        logger.debug(f"render_table: {len(rows)} rows, {len(columns)} columns: {columns}")

        # Build header
        header = "| " + " | ".join(str(c) for c in columns) + " |"
        separator = "| " + " | ".join("---" for _ in columns) + " |"
        body_lines = [
            "| " + " | ".join(str(row.get(c, "")) for c in columns) + " |"
            for row in rows
        ]

        table_md = "\n".join([header, separator] + body_lines)
        if title:
            table_md = f"**{title}**\n\n{table_md}"

        logger.info(f"render_table succeeded: {len(rows)} rows, {len(columns)} columns")
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


async def render_bar_chart(
    data: str,
    x_column: str,
    y_column: str,
    title: str = "Bar Chart",
    sort_column: str = "",
    sort_order: str = "asc",
    palette: str = "corporate",
    tool_context: ToolContext = None,
) -> dict:
    """Render tabular JSON or CSV data as a vertical bar chart.

    The chart is saved as an image artifact and displayed inline in the ADK UI.

    Args:
        data:        A JSON array of objects or a CSV string with a header row.
        x_column:    Column name to use for the X-axis (categories).
        y_column:    Column name to use for the Y-axis (numeric values).
        title:       Chart title.
        sort_column: Optional column name to sort rows by before rendering.
        sort_order:  "asc" (ascending, default) or "desc" (descending).
        palette:     Color palette to use ("default", "corporate", "pastel", "monochrome_blue", "vibrant").

    Returns:
        A dict with keys:
            status   – "success" or "error"
            filename – artifact filename saved (on success)
            error    – error message (on failure)
    """
    logger.info(f"render_bar_chart called: x={x_column!r}, y={y_column!r}, title={title!r}, sort_column={sort_column!r}, sort_order={sort_order!r}")
    try:
        rows = _sort_data(_parse_data(data), sort_column, sort_order)
        x_vals = [str(row[x_column]) for row in rows]
        y_vals = [float(row[y_column]) for row in rows]
        logger.debug(f"render_bar_chart: {len(x_vals)} bars, x range={x_vals[:3]}..., y range=[{min(y_vals):.2f}, {max(y_vals):.2f}]")

        fig, ax = plt.subplots(figsize=(max(8, len(x_vals) * 0.8), 5.5))
        colors = _get_colors(palette, len(x_vals))
        
        # Use single color if we want bars to be uniform, or multiple colors for categorical diffs.
        # Here we use the first color of the palette for all bars to look cleaner, 
        # unless user wants a rainbow, but let's stick to a solid primary color for standard bars.
        bar_color = _get_colors(palette, 1)[0]
        
        ax.bar(x_vals, y_vals, color=bar_color, edgecolor="none", width=0.7, alpha=0.9)
        _apply_professional_style(ax, title, x_column, y_column)
        plt.xticks(rotation=45, ha="right")
        fig.tight_layout()

        png_bytes = _fig_to_png_bytes(fig)
        filename = f"{title.replace(' ', '_').lower()}.png"
        artifact = Part(inline_data=Blob(mime_type="image/png", data=png_bytes))
        await tool_context.save_artifact(filename=filename, artifact=artifact)

        logger.info(f"render_bar_chart succeeded: {len(x_vals)} bars, saved as {filename!r}")
        return {
            "status": "success",
            "filename": filename,
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


async def render_line_chart(
    data: str,
    x_column: str,
    y_columns: str,
    title: str = "Line Chart",
    sort_column: str = "",
    sort_order: str = "asc",
    palette: str = "corporate",
    tool_context: ToolContext = None,
) -> dict:
    """Render tabular JSON or CSV data as a line chart.

    The chart is saved as an image artifact and displayed inline in the ADK UI.

    Args:
        data:        A JSON array of objects or a CSV string with a header row.
        x_column:    Column name for the X-axis (e.g. dates / periods).
        y_columns:   Comma-separated column name(s) for Y-axis series.
                     Example: "Revenue" or "Revenue,Cost,Profit"
        title:       Chart title.
        sort_column: Optional column name to sort rows by before rendering.
        sort_order:  "asc" (ascending, default) or "desc" (descending).
        palette:     Color palette to use ("default", "corporate", "pastel", "monochrome_blue", "vibrant").

    Returns:
        A dict with keys:
            status   – "success" or "error"
            filename – artifact filename saved (on success)
            error    – error message (on failure)
    """
    logger.info(f"render_line_chart called: x={x_column!r}, y_columns={y_columns!r}, title={title!r}, sort_column={sort_column!r}, sort_order={sort_order!r}")
    try:
        rows = _sort_data(_parse_data(data), sort_column, sort_order)
        x_vals = [str(row[x_column]) for row in rows]
        y_col_list = [c.strip() for c in y_columns.split(",") if c.strip()]
        logger.debug(f"render_line_chart: {len(x_vals)} points, {len(y_col_list)} series: {y_col_list}")

        fig, ax = plt.subplots(figsize=(max(8, len(x_vals) * 0.6), 5.5))
        colors = _get_colors(palette, len(y_col_list))
        
        for i, col in enumerate(y_col_list):
            y_vals = [float(row[col]) for row in rows]
            logger.debug(f"render_line_chart: series {col!r} range=[{min(y_vals):.2f}, {max(y_vals):.2f}]")
            ax.plot(x_vals, y_vals, marker="o", markersize=6, linewidth=2.5, color=colors[i], label=col)
            
        y_label = y_col_list[0] if len(y_col_list) == 1 else None
        _apply_professional_style(ax, title, x_column, y_label)
        
        # Style the legend
        ax.legend(frameon=False, bbox_to_anchor=(1.01, 1), loc='upper left')
        
        plt.xticks(rotation=45, ha="right")
        fig.tight_layout()

        png_bytes = _fig_to_png_bytes(fig)
        filename = f"{title.replace(' ', '_').lower()}.png"
        artifact = Part(inline_data=Blob(mime_type="image/png", data=png_bytes))
        await tool_context.save_artifact(filename=filename, artifact=artifact)

        logger.info(f"render_line_chart succeeded: {len(x_vals)} points, {len(y_col_list)} series, saved as {filename!r}")
        return {
            "status": "success",
            "filename": filename,
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


async def render_pie_chart(
    data: str,
    label_column: str,
    value_column: str,
    title: str = "Pie Chart",
    sort_column: str = "",
    sort_order: str = "asc",
    palette: str = "corporate",
    tool_context: ToolContext = None,
) -> dict:
    """Render tabular JSON or CSV data as a pie chart.

    The chart is saved as an image artifact and displayed inline in the ADK UI.

    Args:
        data:         A JSON array of objects or a CSV string with a header row.
        label_column: Column name whose values become pie-slice labels.
        value_column: Column name whose values become pie-slice sizes (numeric).
        title:        Chart title.
        sort_column:  Optional column name to sort rows by before rendering.
        sort_order:   "asc" (ascending, default) or "desc" (descending).
        palette:      Color palette to use ("default", "corporate", "pastel", "monochrome_blue", "vibrant").

    Returns:
        A dict with keys:
            status   – "success" or "error"
            filename – artifact filename saved (on success)
            error    – error message (on failure)
    """
    logger.info(f"render_pie_chart called: label={label_column!r}, value={value_column!r}, title={title!r}, sort_column={sort_column!r}, sort_order={sort_order!r}")
    try:
        rows = _sort_data(_parse_data(data), sort_column, sort_order)
        labels = [str(row[label_column]) for row in rows]
        values = [float(row[value_column]) for row in rows]
        logger.debug(f"render_pie_chart: {len(labels)} slices: {labels}")

        fig, ax = plt.subplots(figsize=(8, 8))
        colors = _get_colors(palette, len(labels))
        
        # Donut style pie chart for a more modern look
        wedges, texts, autotexts = ax.pie(
            values, 
            labels=labels, 
            autopct="%1.1f%%", 
            startangle=140,
            colors=colors,
            wedgeprops=dict(width=0.6, edgecolor='w', linewidth=2),
            textprops=dict(color='#333333', fontsize=11)
        )
        
        # Make percent text bold
        plt.setp(autotexts, size=10, weight="bold", color="white")
        
        # We handle title manually for styling
        ax.set_title(title, pad=20, fontsize=14, fontweight='bold', color='#333333')
        fig.tight_layout()

        png_bytes = _fig_to_png_bytes(fig)
        filename = f"{title.replace(' ', '_').lower()}.png"
        artifact = Part(inline_data=Blob(mime_type="image/png", data=png_bytes))
        await tool_context.save_artifact(filename=filename, artifact=artifact)

        logger.info(f"render_pie_chart succeeded: {len(labels)} slices, saved as {filename!r}")
        return {
            "status": "success",
            "filename": filename,
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


from google.adk.tools import google_maps_grounding

# ---------------------------------------------------------------------------
# Root agent
# ---------------------------------------------------------------------------

root_agent = Agent(
    name=agent_config.name,
    model=agent_config.model,
    description=agent_config.description,
    instruction=agent_config.instruction,
    tools=[render_table, render_bar_chart, render_line_chart, render_pie_chart, google_maps_grounding],
    generate_content_config=GenerateContentConfig(
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

