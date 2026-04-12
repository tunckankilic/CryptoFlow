"""
CryptoFlow Data Migration — Shared Utilities

Provides common helpers for all migration scripts:
- Firebase / DynamoDB client init
- UID mapping
- Batch writes with retry
- Date/numeric conversions
- ULID generation
- Logging & error recording
- Progress tracking
"""

import csv
import json
import logging
import os
import sys
import time
from datetime import datetime, timezone
from decimal import Decimal, InvalidOperation
from pathlib import Path
from typing import Any, Iterator

import boto3
import firebase_admin
from firebase_admin import credentials, firestore
from google.cloud.firestore_v1.base_document import DocumentSnapshot
from tqdm import tqdm
from ulid import ULID

import config


# ═══════════════════════════════════════════════════════════════════════════════
# Firebase
# ═══════════════════════════════════════════════════════════════════════════════

_firebase_app = None
_firestore_client = None


def get_firestore_client() -> firestore.firestore.Client:
    """Initialize and return a singleton Firestore client."""
    global _firebase_app, _firestore_client
    if _firestore_client is None:
        cred = credentials.Certificate(config.FIREBASE_CREDENTIALS_PATH)
        _firebase_app = firebase_admin.initialize_app(cred)
        _firestore_client = firestore.client()
    return _firestore_client


# ═══════════════════════════════════════════════════════════════════════════════
# DynamoDB
# ═══════════════════════════════════════════════════════════════════════════════

_dynamodb_resource = None


def _get_dynamodb_resource():
    global _dynamodb_resource
    if _dynamodb_resource is None:
        _dynamodb_resource = boto3.resource("dynamodb", region_name=config.AWS_REGION)
    return _dynamodb_resource


def get_dynamodb_table(logical_name: str):
    """Get a DynamoDB Table object by logical name (e.g. 'alerts')."""
    table_name = config.TABLE_NAMES[logical_name]
    return _get_dynamodb_resource().Table(table_name)


# ═══════════════════════════════════════════════════════════════════════════════
# UID Mapping
# ═══════════════════════════════════════════════════════════════════════════════

_uid_map: dict[str, str] | None = None


def load_uid_mapping() -> dict[str, str]:
    """Load Firebase UID → Cognito UID mapping from CSV.

    CSV format: firebase_uid,cognito_uid (with header row)
    Returns dict mapping firebase_uid → cognito_uid.
    """
    global _uid_map
    if _uid_map is not None:
        return _uid_map

    if config.USE_FIREBASE_UID:
        _uid_map = {}
        return _uid_map

    path = config.UID_MAPPING_PATH
    if not os.path.exists(path):
        print(f"ERROR: UID mapping file not found: {path}", file=sys.stderr)
        print("Set USE_FIREBASE_UID=true to skip mapping.", file=sys.stderr)
        sys.exit(1)

    _uid_map = {}
    with open(path, "r") as f:
        reader = csv.DictReader(f)
        for row in reader:
            fb_uid = row["firebase_uid"].strip()
            cog_uid = row["cognito_uid"].strip()
            if fb_uid in _uid_map:
                print(f"WARNING: Duplicate firebase_uid in mapping: {fb_uid}", file=sys.stderr)
            _uid_map[fb_uid] = cog_uid

    return _uid_map


def map_uid(firebase_uid: str) -> str | None:
    """Map a Firebase UID to a Cognito UID. Returns None if unmapped."""
    if config.USE_FIREBASE_UID:
        return firebase_uid
    mapping = load_uid_mapping()
    return mapping.get(firebase_uid)


# ═══════════════════════════════════════════════════════════════════════════════
# Batch Write
# ═══════════════════════════════════════════════════════════════════════════════


def dynamo_batch_write(
    table,
    items: list[dict],
    dry_run: bool = False,
    logger: logging.Logger | None = None,
) -> tuple[int, int]:
    """Write items to DynamoDB using batch_writer.

    Returns (success_count, error_count).
    """
    log = logger or logging.getLogger(__name__)
    if dry_run:
        log.info(f"[DRY RUN] Would write {len(items)} items to {table.table_name}")
        for item in items[:3]:
            log.debug(f"  Sample: {json.dumps(_serialize_for_log(item), default=str)[:200]}")
        return len(items), 0

    success = 0
    errors = 0
    try:
        with table.batch_writer() as batch:
            for item in items:
                try:
                    batch.put_item(Item=item)
                    success += 1
                except Exception as e:
                    log.error(f"Failed to write item: {e}")
                    errors += 1
    except Exception as e:
        log.error(f"Batch write failed: {e}")
        # Fall back to individual writes for remaining items
        for item in items[success + errors :]:
            try:
                table.put_item(Item=item)
                success += 1
            except Exception as e2:
                log.error(f"Individual write failed: {e2}")
                errors += 1

    return success, errors


# ═══════════════════════════════════════════════════════════════════════════════
# Data Conversions
# ═══════════════════════════════════════════════════════════════════════════════


def firestore_timestamp_to_iso(ts: Any) -> str | None:
    """Convert various timestamp formats to ISO8601 string.

    Handles: Firestore Timestamp, datetime, int (milliseconds epoch), str passthrough.
    """
    if ts is None:
        return None

    # Firestore Timestamp object
    if hasattr(ts, "seconds") and hasattr(ts, "nanoseconds"):
        dt = datetime.fromtimestamp(ts.seconds + ts.nanoseconds / 1e9, tz=timezone.utc)
        return dt.isoformat()

    # Python datetime
    if isinstance(ts, datetime):
        if ts.tzinfo is None:
            ts = ts.replace(tzinfo=timezone.utc)
        return ts.isoformat()

    # Integer — assume milliseconds since epoch
    if isinstance(ts, (int, float)):
        if ts > 1e12:  # milliseconds
            ts = ts / 1000.0
        dt = datetime.fromtimestamp(ts, tz=timezone.utc)
        return dt.isoformat()

    # String passthrough
    if isinstance(ts, str):
        return ts

    return None


def to_decimal(value: Any) -> Decimal | None:
    """Convert a numeric value to Decimal via string to avoid float artifacts."""
    if value is None:
        return None
    try:
        return Decimal(str(value))
    except (InvalidOperation, ValueError):
        return None


def generate_ulid() -> str:
    """Generate a new ULID string."""
    return str(ULID())


def now_iso() -> str:
    """Return current UTC time as ISO8601 string."""
    return datetime.now(timezone.utc).isoformat()


# ═══════════════════════════════════════════════════════════════════════════════
# Firestore Iteration
# ═══════════════════════════════════════════════════════════════════════════════


def iter_firestore_users(batch_size: int = 100) -> Iterator[list[DocumentSnapshot]]:
    """Paginate through Firestore users collection, yielding batches."""
    fs = get_firestore_client()
    users_ref = fs.collection(config.FIRESTORE_USERS_COLLECTION)

    query = users_ref.order_by("__name__").limit(batch_size)
    docs = list(query.stream())

    while docs:
        yield docs
        last_doc = docs[-1]
        query = users_ref.order_by("__name__").start_after(last_doc).limit(batch_size)
        docs = list(query.stream())


def get_user_data_doc(firebase_uid: str, doc_name: str) -> dict | None:
    """Fetch a user's data sub-document from Firestore.

    Path: users/{uid}/data/{doc_name}
    Returns the document data dict, or None if not found.
    """
    fs = get_firestore_client()
    doc_ref = (
        fs.collection(config.FIRESTORE_USERS_COLLECTION)
        .document(firebase_uid)
        .collection(config.FIRESTORE_DATA_SUBCOLLECTION)
        .document(doc_name)
    )
    doc = doc_ref.get()
    if doc.exists:
        return doc.to_dict()
    return None


def count_firestore_users() -> int:
    """Count total users in Firestore (for progress bars)."""
    fs = get_firestore_client()
    # Use aggregation if available, else iterate
    try:
        from google.cloud.firestore_v1.aggregation import AggregationQuery

        agg = AggregationQuery(fs.collection(config.FIRESTORE_USERS_COLLECTION))
        agg.count(alias="total")
        results = agg.get()
        for result in results:
            for r in result:
                return r.value
    except Exception:
        pass

    # Fallback: count by iterating (slower)
    count = 0
    for batch in iter_firestore_users(batch_size=500):
        count += len(batch)
    return count


# ═══════════════════════════════════════════════════════════════════════════════
# Logging
# ═══════════════════════════════════════════════════════════════════════════════


def setup_logging(script_name: str) -> logging.Logger:
    """Configure logging with both console and file handlers."""
    logger = logging.getLogger(script_name)
    logger.setLevel(getattr(logging, config.LOG_LEVEL, logging.INFO))

    # Console handler
    console = logging.StreamHandler()
    console.setLevel(logging.INFO)
    console.setFormatter(logging.Formatter("%(levelname)s  %(message)s"))
    logger.addHandler(console)

    # File handler
    os.makedirs(config.ERROR_LOG_DIR, exist_ok=True)
    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    file_handler = logging.FileHandler(
        os.path.join(config.ERROR_LOG_DIR, f"migration_{script_name}_{ts}.log")
    )
    file_handler.setLevel(logging.DEBUG)
    file_handler.setFormatter(
        logging.Formatter("%(asctime)s  %(levelname)s  %(message)s")
    )
    logger.addHandler(file_handler)

    return logger


# ═══════════════════════════════════════════════════════════════════════════════
# Error Recording
# ═══════════════════════════════════════════════════════════════════════════════


class MigrationErrorRecorder:
    """Records individual migration errors to a JSONL file for later retry."""

    def __init__(self, table_name: str):
        os.makedirs(config.ERROR_LOG_DIR, exist_ok=True)
        ts = datetime.now().strftime("%Y%m%d_%H%M%S")
        self.path = os.path.join(
            config.ERROR_LOG_DIR, f"errors_{table_name}_{ts}.jsonl"
        )
        self._file = None
        self.count = 0

    def record(self, user_id: str, record_id: str, error: Exception, raw_data: dict):
        if self._file is None:
            self._file = open(self.path, "a")
        entry = {
            "userId": user_id,
            "recordId": record_id,
            "error_type": type(error).__name__,
            "error_message": str(error),
            "raw_data": _serialize_for_log(raw_data),
            "timestamp": now_iso(),
        }
        self._file.write(json.dumps(entry, default=str) + "\n")
        self._file.flush()
        self.count += 1

    def close(self):
        if self._file:
            self._file.close()


# ═══════════════════════════════════════════════════════════════════════════════
# CLI Helpers
# ═══════════════════════════════════════════════════════════════════════════════


def add_common_args(parser):
    """Add --dry-run, --batch-size, --uid-mapping, --use-firebase-uid to argparse."""
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Preview changes without writing to DynamoDB",
    )
    parser.add_argument(
        "--batch-size",
        type=int,
        default=100,
        help="Number of Firestore users to process per batch (default: 100)",
    )
    parser.add_argument(
        "--uid-mapping",
        default=None,
        help="Path to UID mapping CSV (overrides UID_MAPPING_PATH env var)",
    )
    parser.add_argument(
        "--use-firebase-uid",
        action="store_true",
        help="Use Firebase UIDs directly (skip UID mapping)",
    )


def apply_common_args(args):
    """Apply CLI args to config overrides."""
    if args.uid_mapping:
        config.UID_MAPPING_PATH = args.uid_mapping
    if args.use_firebase_uid:
        config.USE_FIREBASE_UID = True


def print_summary(
    script_name: str,
    total_users: int,
    total_records: int,
    success: int,
    errors: int,
    error_recorder: MigrationErrorRecorder | None = None,
    dry_run: bool = False,
):
    """Print a migration summary."""
    mode = "[DRY RUN] " if dry_run else ""
    print(f"\n{'='*60}")
    print(f"{mode}{script_name} — Migration Summary")
    print(f"{'='*60}")
    print(f"  Users processed:   {total_users}")
    print(f"  Records migrated:  {success}")
    print(f"  Errors:            {errors}")
    if error_recorder and error_recorder.count > 0:
        print(f"  Error log:         {error_recorder.path}")
    print(f"{'='*60}\n")


# ═══════════════════════════════════════════════════════════════════════════════
# Internal
# ═══════════════════════════════════════════════════════════════════════════════


def _serialize_for_log(data: dict) -> dict:
    """Make a dict JSON-serializable for logging."""
    result = {}
    for k, v in data.items():
        if isinstance(v, Decimal):
            result[k] = float(v)
        elif isinstance(v, datetime):
            result[k] = v.isoformat()
        elif isinstance(v, set):
            result[k] = list(v)
        elif isinstance(v, dict):
            result[k] = _serialize_for_log(v)
        else:
            result[k] = v
    return result
