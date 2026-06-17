"""
CryptoFlow Data Migration — Configuration Module

Loads environment variables and provides table name resolution
following the Terraform naming pattern: {prefix}-{environment}-{logical_name}
"""

import os
import sys


def _require_env(name: str) -> str:
    value = os.environ.get(name)
    if not value:
        print(f"ERROR: Required environment variable '{name}' is not set.", file=sys.stderr)
        sys.exit(1)
    return value


# ── Required ──────────────────────────────────────────────────────────────────
FIREBASE_CREDENTIALS_PATH = _require_env("FIREBASE_CREDENTIALS_PATH")

# ── Optional with defaults ────────────────────────────────────────────────────
AWS_REGION = os.environ.get("AWS_REGION", "eu-central-1")
TABLE_PREFIX = os.environ.get("TABLE_PREFIX", "cryptoflow")
TABLE_ENVIRONMENT = os.environ.get("TABLE_ENVIRONMENT", "prod")
UID_MAPPING_PATH = os.environ.get("UID_MAPPING_PATH", "./uid_mapping.csv")
USE_FIREBASE_UID = os.environ.get("USE_FIREBASE_UID", "false").lower() in ("true", "1", "yes")
LOG_LEVEL = os.environ.get("LOG_LEVEL", "INFO").upper()
ERROR_LOG_DIR = os.environ.get("ERROR_LOG_DIR", "./migration_errors")

# ── Table name resolution ─────────────────────────────────────────────────────
_prefix = f"{TABLE_PREFIX}-{TABLE_ENVIRONMENT}"

TABLE_NAMES = {
    "users": f"{_prefix}-users",
    "user_settings": f"{_prefix}-user-settings",
    "portfolio_holdings": f"{_prefix}-portfolio-holdings",
    "portfolio_transactions": f"{_prefix}-portfolio-transactions",
    "journal_entries": f"{_prefix}-journal-entries",
    "alerts": f"{_prefix}-alerts",
    "watchlist": f"{_prefix}-watchlist",
    "device_tokens": f"{_prefix}-device-tokens",
    "ws_connections": f"{_prefix}-ws-connections",
}

# ── Firestore collection paths ────────────────────────────────────────────────
# Based on CloudSyncService: users/{uid}/data/{type}
FIRESTORE_USERS_COLLECTION = "users"
FIRESTORE_DATA_SUBCOLLECTION = "data"
FIRESTORE_PORTFOLIO_DOC = "portfolio"
FIRESTORE_WATCHLIST_DOC = "watchlist"
FIRESTORE_ALERTS_DOC = "alerts"
FIRESTORE_SETTINGS_DOC = "settings"
FIRESTORE_JOURNAL_DOC = "journal"
