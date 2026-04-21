import json
import os
import logging

logger = logging.getLogger("EBS_SQL_Agent")

# Filenames of semantic map JSON files expected under the semantic_maps subdirectory.
SEMANTIC_MAP_FILES = [
    "ar_semantic_map.json",
    "ap_semantic_map.json",
    "gl_semantic_map.json",
    "inventory_semantic_map.json",
    "po_semantic_map.json",
    "om_semantic_map.json",
    "hr_semantic_map.json",
    # "security_semantic_map.json",
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
                with open(filepath, "r") as f:
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
    context = (
        "Use the following semantic map to understand the database schema and "
        "relationships when generating SQL or answering data questions:\n\n"
    )

    for smap in semantic_maps:
        try:
            if not isinstance(smap, dict):
                logger.warning(
                    f"Skipping malformed semantic map (expected dict, got {type(smap)})"
                )
                continue

            module_name = smap.get("module", "Unknown")
            logger.debug(f"Processing semantic map for module: {module_name}")

            context += f"Module: {module_name}\n"
            context += f"Description: {smap.get('description', '')}\n"
            context += "Tables:\n"
            for table in smap.get("tables", []):
                context += (
                    f"  - {table['table_name']} ({table.get('business_name', '')}): "
                    f"{table.get('description', '')}\n"
                )
                context += "    Columns:\n"
                for col in table.get("columns", []):
                    context += f"      * {col['name']}: {col.get('description', '')}\n"
            context += "Common Joins:\n"
            for join in smap.get("common_joins", []):
                context += (
                    f"  - {join.get('description', '')}: {join.get('join_condition', '')}\n"
                )
            if smap.get("example_queries"):
                context += "Example Queries:\n"
                for eq in smap.get("example_queries", []):
                    context += f"  - {eq.get('description', '')}: {eq.get('sql', '')}\n"
            context += "\n"
        except Exception as e:
            logger.error(f"Error processing semantic map entry: {e}", exc_info=True)
            continue

    logger.debug(f"Finished building semantic context. Length: {len(context)} characters.")
    return context
