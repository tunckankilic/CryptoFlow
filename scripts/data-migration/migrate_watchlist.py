#!/usr/bin/env python3
"""
CryptoFlow Data Migration — Watchlist

Source: Firestore users/{uid}/data/watchlist → { items: [...], updatedAt }
Target: DynamoDB watchlist (PK: userId, SK: symbol)

Natural idempotency: (userId, symbol) composite key is deterministic.
"""

import argparse
import sys

from tqdm import tqdm

import config
import migration_utils as mu


def transform_watchlist_item(user_id: str, item: dict) -> dict:
    """Transform a Firestore watchlist item into a DynamoDB item."""
    symbol = item.get("symbol", "")
    added_at = mu.firestore_timestamp_to_iso(item.get("addedAt")) or mu.now_iso()

    dynamo_item = {
        "userId": user_id,
        "symbol": symbol,
        "addedAt": added_at,
    }

    order = item.get("order")
    if order is not None:
        dynamo_item["order"] = int(order)

    return dynamo_item


def migrate(dry_run: bool = False, batch_size: int = 100):
    logger = mu.setup_logging("migrate_watchlist")
    error_recorder = mu.MigrationErrorRecorder("watchlist")

    logger.info("Counting Firestore users...")
    total_users = mu.count_firestore_users()
    logger.info(f"Found {total_users} users")

    table = mu.get_dynamodb_table("watchlist")
    total_processed = 0
    total_success = 0
    total_errors = 0
    total_records = 0
    skipped_no_mapping = 0

    progress = tqdm(total=total_users, desc="Migrating watchlist", unit="user")

    for user_batch in mu.iter_firestore_users(batch_size=batch_size):
        items_to_write = []

        for user_doc in user_batch:
            firebase_uid = user_doc.id
            cognito_uid = mu.map_uid(firebase_uid)

            if cognito_uid is None:
                skipped_no_mapping += 1
                progress.update(1)
                continue

            watchlist_data = mu.get_user_data_doc(firebase_uid, config.FIRESTORE_WATCHLIST_DOC)
            if watchlist_data is None:
                progress.update(1)
                total_processed += 1
                continue

            items = watchlist_data.get("items", [])

            for item in items:
                try:
                    dynamo_item = transform_watchlist_item(cognito_uid, item)
                    items_to_write.append(dynamo_item)
                    total_records += 1
                except Exception as e:
                    logger.error(f"Transform error for user {firebase_uid}: {e}")
                    error_recorder.record(firebase_uid, item.get("symbol", "?"), e, item)
                    total_errors += 1

            total_processed += 1
            progress.update(1)

        if items_to_write:
            s, err = mu.dynamo_batch_write(table, items_to_write, dry_run=dry_run, logger=logger)
            total_success += s
            total_errors += err

    progress.close()

    if skipped_no_mapping > 0:
        logger.warning(f"Skipped {skipped_no_mapping} users with no UID mapping")

    error_recorder.close()
    mu.print_summary(
        "migrate_watchlist",
        total_processed,
        total_records,
        total_success,
        total_errors,
        error_recorder,
        dry_run,
    )
    return total_errors == 0


def main():
    parser = argparse.ArgumentParser(description="Migrate watchlist from Firestore to DynamoDB")
    mu.add_common_args(parser)
    args = parser.parse_args()
    mu.apply_common_args(args)

    success = migrate(dry_run=args.dry_run, batch_size=args.batch_size)
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
