import json
import os
import logging

logger = logging.getLogger("PSFT_SQL_Agent")

# Filenames of semantic map JSON files expected under the semantic_maps subdirectory.
SEMANTIC_MAP_FILES = [
    "ar_semantic_map.json",
    "ap_semantic_map.json",
    "gl_semantic_map.json",
    "inventory_semantic_map.json",
    "po_semantic_map.json",
    "om_semantic_map.json",
    "hr_semantic_map.json",
    "gov_public_sector_semantic_map.json",
]

def load_semantic_maps(base_dir: str) -> list:
    """Loads semantic map JSON files from the semantic_maps subdirectory."""
    logger.debug("Entering load_semantic_maps")
    maps = []
    maps_dir = os.path.join(base_dir, "semantic_maps")
    logger.debug(f"Base directory for semantic maps: {maps_dir}")

    for filename in SEMANTIC_MAP_FILES:
        filepath = os.path.join(maps_dir, filename)
        logger.debug(f"Checking for semantic map file: {filepath}")

        if os.path.exists(filepath):
            try:
                with open(filepath, "r", encoding="utf-8") as f:
                    data = json.load(f)
                    maps.append(data)
                    logger.debug(f"Successfully loaded and parsed JSON from {filename}")
            except json.JSONDecodeError as e:
                logger.error(f"JSON decode error in {filename}: {e}", exc_info=True)
            except Exception as e:
                logger.error(f"Error loading {filename}: {e}", exc_info=True)
        else:
            logger.warning(f"Semantic map file not found: {filename}")

    logger.info(f"Total semantic maps loaded: {len(maps)}")
    return maps


def build_semantic_context(semantic_maps: list) -> str:
    """Builds a prompt-ready string from a list of semantic map dicts."""
    logger.debug("Building semantic context string from loaded maps...")
    parts = [
        "Use the following semantic map to understand the database schema and "
        "relationships when generating SQL or answering data questions:\n\n"
    ]

    for smap in semantic_maps:
        try:
            if not isinstance(smap, dict):
                logger.warning(
                    f"Skipping malformed semantic map (expected dict, got {type(smap)})"
                )
                continue

            module_name = smap.get("module", "Unknown")
            logger.debug(f"Processing semantic map for module: {module_name}")

            parts.append(f"Module: {module_name}\n")
            parts.append(f"Description: {smap.get('description', '')}\n")
            parts.append("Tables:\n")
            for table in smap.get("tables") or []:
                table_name = table.get("table_name", "Unknown Table")
                parts.append(
                    f"  - {table_name} ({table.get('business_name', '')}): "
                    f"{table.get('description', '')}\n"
                )
                parts.append("    Columns:\n")
                for col in table.get("columns") or []:
                    col_name = col.get("name", "Unknown Column")
                    parts.append(f"      * {col_name}: {col.get('description', '')}\n")
            parts.append("Common Joins:\n")
            for join in smap.get("common_joins") or []:
                parts.append(
                    f"  - {join.get('description', '')}: {join.get('join_condition', '')}\n"
                )
            if smap.get("example_queries"):
                parts.append("Example Queries:\n")
                for eq in smap.get("example_queries") or []:
                    parts.append(f"  - {eq.get('description', '')}: {eq.get('sql', '')}\n")
            parts.append("\n")
        except Exception as e:
            logger.error(f"Error processing semantic map entry: {e}", exc_info=True)
            continue

    context = "".join(parts)
    logger.debug(f"Finished building semantic context. Length: {len(context)} characters.")
    return context
