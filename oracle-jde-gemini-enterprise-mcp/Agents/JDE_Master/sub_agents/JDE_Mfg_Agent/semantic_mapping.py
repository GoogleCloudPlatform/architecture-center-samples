import json
import os
import logging

logger = logging.getLogger("JDE_Mfg_Agent")

SEMANTIC_MAP_FILES = [
    "jde_discrete_mfg_semantic_map.json",
]

def load_semantic_maps(base_dir: str) -> list:
    """Loads semantic map JSON files from the semantic_maps subdirectory."""
    maps = []
    maps_dir = os.path.join(base_dir, "semantic_maps")
    for filename in SEMANTIC_MAP_FILES:
        filepath = os.path.join(maps_dir, filename)
        if os.path.exists(filepath):
            try:
                with open(filepath, "r", encoding="utf-8") as f:
                    maps.append(json.load(f))
            except Exception as e:
                logger.error(f"Error loading {filename}: {e}", exc_info=True)
    return maps


def build_semantic_context(semantic_maps: list) -> str:
    """Builds a prompt-ready string from a list of semantic map dicts."""
    context = (
        "Use the following JDE 9.2 Discrete Manufacturing semantic map to understand the "
        "PRODDTA schema, analytical views, and JDE Orchestrator v3 services:\n\n"
    )
    for smap in semantic_maps:
        if not isinstance(smap, dict):
            continue
        context += f"Module: {smap.get('module', 'Unknown')}\n"
        context += f"Description: {smap.get('description', '')}\n"
        context += "Tables & Analytical Views:\n"
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
            context += f"  - {join.get('description', '')}: {join.get('join_condition', '')}\n"
        if smap.get("example_queries"):
            context += "Example Queries:\n"
            for eq in smap.get("example_queries", []):
                context += f"  - {eq.get('description', '')}: {eq.get('sql', '')}\n"
        context += "\n"
    return context
