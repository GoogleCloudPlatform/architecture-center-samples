"""Shared logging configuration for Google Cloud Run services and ADK agents.

CANONICAL SOURCE — do not edit copies directly.
Copies live alongside each deployable service/agent and are refreshed from
this file by their respective ``deploy_gcloud.sh`` scripts before building.

Emits structured JSON logs to stdout in the format recognised by Google Cloud
Logging.  Special fields used:

* ``severity``   — mapped to Cloud Logging native severity (DEBUG … CRITICAL).
* ``logging.googleapis.com/sourceLocation`` — links log entries to the exact
  source file and line in the Cloud Console.
* ``labels``     — populated from Cloud Run env vars ``K_SERVICE`` /
  ``K_REVISION`` so log entries can be filtered per service revision without
  needing to parse the log payload.

Timestamps are omitted because Cloud Logging adds them automatically from the
stdout ingestion timestamp.

Usage::

    from logging_config import configure_logging
    logger = configure_logging(__name__)
"""

import json
import logging
import os
import sys

# Cloud Run injects these env vars; fall back gracefully for local runs.
_SERVICE_LABELS: dict = {k: v for k, v in {
    "k_service": os.environ.get("K_SERVICE", ""),
    "k_revision": os.environ.get("K_REVISION", ""),
}.items() if v}


class CloudRunFormatter(logging.Formatter):
    """Emit single-line JSON log records understood by Google Cloud Logging.

    Special Cloud Logging fields populated:
    - ``severity``                              — log level mapped to Cloud Logging severity.
    - ``logging.googleapis.com/sourceLocation`` — file, line, and function name.
    - ``labels``                                — Cloud Run service/revision from env vars.
    """

    _LEVEL_MAP = {
        logging.DEBUG: "DEBUG",
        logging.INFO: "INFO",
        logging.WARNING: "WARNING",
        logging.ERROR: "ERROR",
        logging.CRITICAL: "CRITICAL",
    }

    def format(self, record: logging.LogRecord) -> str:
        entry: dict = {
            "severity": self._LEVEL_MAP.get(record.levelno, "DEFAULT"),
            "message": record.getMessage(),
            "name": record.name,
            "logging.googleapis.com/sourceLocation": {
                "file": record.pathname,
                "line": str(record.lineno),
                "function": record.funcName,
            },
        }
        if _SERVICE_LABELS:
            entry["labels"] = _SERVICE_LABELS
        if record.exc_info:
            entry["exception"] = self.formatException(record.exc_info)
        return json.dumps(entry)


_logging_configured = False


def configure_logging(name: str) -> logging.Logger:
    """Configure root logging with Cloud Run JSON format and return a named logger.

    Reads the ``DEBUG`` environment variable (case-insensitive) to set the log
    level.  Safe to call from multiple modules — root handler setup runs only
    once; subsequent calls simply return the named logger.

    Args:
        name: Logger name, typically ``__name__`` of the calling module.

    Returns:
        A :class:`logging.Logger` instance for ``name``.
    """
    global _logging_configured
    if not _logging_configured:
        debug = os.environ.get("DEBUG", "false").lower() == "true"
        handler = logging.StreamHandler(sys.stdout)
        handler.setFormatter(CloudRunFormatter())
        logging.basicConfig(
            level=logging.DEBUG if debug else logging.INFO,
            handlers=[handler],
            force=True,
        )
        _logging_configured = True
    return logging.getLogger(name)
