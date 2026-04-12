#!/usr/bin/env python3
"""
CryptoFlow Data Migration — Rollback Script

Deletes migrated data from DynamoDB tables. Safety features:
  - Requires --confirm-rollback flag to execute
  - Creates JSONL backup before deletion
  - 10-second countdown with Ctrl+C cancel
  - Selective table rollback with --tables flag
"""

import argparse
import json
import os
import sys
import time
from datetime import datetime

import boto3
from tqdm import tqdm

import config
import migration_utils as mu

ROLLBACK_TABLES = [
    "portfolio_holdings",
    "portfolio_transactions",
    "watchlist",
    "alerts",
    "user_settings",
    "journal_entries",
]


def _get_table_key_schema(table) -> tuple[str, str | None]:
    """Extract PK and SK attribute names from table key schema."""
    pk = None
    sk = None
    for key in table.key_schema:
        if key["KeyType"] == "HASH":
            pk = key["AttributeName"]
        elif key["KeyType"] == "RANGE":
            sk = key["AttributeName"]
    return pk, sk


def _backup_table(table, backup_dir: str, table_key: str) -> int:
    """Export all items from a DynamoDB table to a JSONL backup file.

    Returns the number of items backed up.
    """
    os.makedirs(backup_dir, exist_ok=True)
    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_path = os.path.join(backup_dir, f"rollback_backup_{table_key}_{ts}.jsonl")

    count = 0
    scan_kwargs = {}
    with open(backup_path, "w") as f:
        while True:
            response = table.scan(**scan_kwargs)
            for item in response.get("Items", []):
                f.write(json.dumps(item, default=str) + "\n")
                count += 1
            if "LastEvaluatedKey" not in response:
                break
            scan_kwargs["ExclusiveStartKey"] = response["LastEvaluatedKey"]

    print(f"  Backed up {count} items to {backup_path}")
    return count


def _delete_all_items(table, pk_name: str, sk_name: str | None) -> int:
    """Delete all items from a DynamoDB table. Returns count of deleted items."""
    deleted = 0
    scan_kwargs = {}

    while True:
        response = table.scan(**scan_kwargs)
        items = response.get("Items", [])

        with table.batch_writer() as batch:
            for item in items:
                key = {pk_name: item[pk_name]}
                if sk_name:
                    key[sk_name] = item[sk_name]
                batch.delete_item(Key=key)
                deleted += 1

        if "LastEvaluatedKey" not in response:
            break
        scan_kwargs["ExclusiveStartKey"] = response["LastEvaluatedKey"]

    return deleted


def rollback(
    tables: list[str] | None = None,
    skip_backup: bool = False,
    confirm: bool = False,
):
    logger = mu.setup_logging("rollback")

    if not confirm:
        print("ERROR: Rollback requires --confirm-rollback flag.")
        print("Run with --confirm-rollback to execute, or without to preview.")
        print()
        # Preview mode: show what would be deleted
        target_tables = tables or ROLLBACK_TABLES
        for table_key in target_tables:
            table = mu.get_dynamodb_table(table_key)
            count_resp = table.scan(Select="COUNT")
            count = count_resp.get("Count", 0)
            print(f"  {config.TABLE_NAMES[table_key]}: {count} items would be deleted")
        return True

    target_tables = tables or ROLLBACK_TABLES

    # Countdown
    print(f"\n{'!'*60}")
    print(f"  WARNING: About to DELETE ALL DATA from {len(target_tables)} tables!")
    print(f"  Tables: {', '.join(target_tables)}")
    print(f"{'!'*60}")
    print("\nPress Ctrl+C within 10 seconds to cancel...\n")

    try:
        for i in range(10, 0, -1):
            print(f"  {i}...", flush=True)
            time.sleep(1)
    except KeyboardInterrupt:
        print("\n\nRollback CANCELLED.")
        return True

    print("\nStarting rollback...\n")

    backup_dir = os.path.join(config.ERROR_LOG_DIR, "rollback_backups")
    total_deleted = 0

    for table_key in tqdm(target_tables, desc="Rolling back tables"):
        table = mu.get_dynamodb_table(table_key)
        pk_name, sk_name = _get_table_key_schema(table)

        logger.info(f"Rolling back {config.TABLE_NAMES[table_key]}...")

        # Backup first (unless skipped)
        if not skip_backup:
            _backup_table(table, backup_dir, table_key)

        # Delete all items
        deleted = _delete_all_items(table, pk_name, sk_name)
        total_deleted += deleted
        logger.info(f"  Deleted {deleted} items from {config.TABLE_NAMES[table_key]}")

    print(f"\n{'='*60}")
    print(f"Rollback Complete")
    print(f"{'='*60}")
    print(f"  Tables rolled back: {len(target_tables)}")
    print(f"  Total items deleted: {total_deleted}")
    if not skip_backup:
        print(f"  Backups saved to: {backup_dir}")
    print(f"{'='*60}\n")

    return True


def main():
    parser = argparse.ArgumentParser(description="Rollback DynamoDB migration (delete migrated data)")
    parser.add_argument(
        "--confirm-rollback",
        action="store_true",
        help="Required flag to actually execute the rollback",
    )
    parser.add_argument(
        "--tables",
        default=None,
        help="Comma-separated list of tables to rollback (default: all migration tables)",
    )
    parser.add_argument(
        "--skip-backup",
        action="store_true",
        help="Skip JSONL backup before deletion (not recommended)",
    )

    args = parser.parse_args()

    tables = None
    if args.tables:
        tables = [t.strip() for t in args.tables.split(",")]
        # Validate table names
        for t in tables:
            if t not in ROLLBACK_TABLES:
                print(f"ERROR: Unknown table '{t}'. Valid tables: {', '.join(ROLLBACK_TABLES)}")
                sys.exit(1)

    success = rollback(
        tables=tables,
        skip_backup=args.skip_backup,
        confirm=args.confirm_rollback,
    )
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
