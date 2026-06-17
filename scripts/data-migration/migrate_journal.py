#!/usr/bin/env python3
"""
CryptoFlow Data Migration — Journal Entries

Source: Firestore users/{uid}/data/journal (likely does not exist — local Drift/SQLite only)
Target: DynamoDB journal-entries (PK: userId, SK: entryId)

Strategy: If Firestore data exists, migrate it. Otherwise, log and skip.
Journal entries use local int IDs; for DynamoDB we generate ULID or convert to JNL-{id:08d}.

Note: DynamoDB does not allow empty StringSets — tags must be omitted if empty.
"""

import argparse
import json
import sys

from tqdm import tqdm

import config
import migration_utils as mu


def transform_journal_entry(user_id: str, entry: dict) -> dict:
    """Transform a Firestore journal entry into a DynamoDB item."""
    now = mu.now_iso()

    # ID: use existing string ID, convert int, or generate ULID
    raw_id = entry.get("id")
    if raw_id is not None:
        entry_id = f"JNL-{int(raw_id):08d}" if isinstance(raw_id, (int, float)) else str(raw_id)
    else:
        entry_id = mu.generate_ulid()

    item = {
        "userId": user_id,
        "entryId": entry_id,
        "symbol": entry.get("symbol", ""),
        "createdAt": mu.firestore_timestamp_to_iso(entry.get("createdAt")) or now,
        "updatedAt": mu.firestore_timestamp_to_iso(entry.get("updatedAt")) or now,
    }

    # Required string fields
    if entry.get("side"):
        item["side"] = entry["side"]  # 'long' or 'short'

    # Numeric fields
    for field in ("entryPrice", "exitPrice", "quantity", "pnl", "pnlPercentage", "riskRewardRatio"):
        val = mu.to_decimal(entry.get(field))
        if val is not None:
            item[field] = val

    # Optional string fields
    for field in ("strategy", "emotion", "notes", "screenshotPath"):
        if entry.get(field):
            item[field] = entry[field]

    # Date fields
    for field in ("entryDate", "exitDate"):
        val = mu.firestore_timestamp_to_iso(entry.get(field))
        if val:
            item[field] = val

    # Tags — DynamoDB StringSet (must not be empty)
    tags = entry.get("tags")
    if tags:
        # Handle both JSON string and native list
        if isinstance(tags, str):
            try:
                tags = json.loads(tags)
            except (json.JSONDecodeError, ValueError):
                tags = [tags]
        if isinstance(tags, list) and len(tags) > 0:
            item["tags"] = set(str(t) for t in tags)

    return item


def migrate(dry_run: bool = False, batch_size: int = 100):
    logger = mu.setup_logging("migrate_journal")
    error_recorder = mu.MigrationErrorRecorder("journal_entries")

    logger.info("Counting Firestore users...")
    total_users = mu.count_firestore_users()
    logger.info(f"Found {total_users} users")

    table = mu.get_dynamodb_table("journal_entries")
    total_processed = 0
    total_success = 0
    total_errors = 0
    total_records = 0
    total_no_data = 0
    skipped_no_mapping = 0

    progress = tqdm(total=total_users, desc="Migrating journal entries", unit="user")

    for user_batch in mu.iter_firestore_users(batch_size=batch_size):
        items_to_write = []

        for user_doc in user_batch:
            firebase_uid = user_doc.id
            cognito_uid = mu.map_uid(firebase_uid)

            if cognito_uid is None:
                skipped_no_mapping += 1
                progress.update(1)
                continue

            journal_data = mu.get_user_data_doc(firebase_uid, config.FIRESTORE_JOURNAL_DOC)
            if journal_data is None:
                total_no_data += 1
                progress.update(1)
                total_processed += 1
                continue

            # Journal data could be { entries: [...] } or { items: [...] }
            entries = journal_data.get("entries", journal_data.get("items", []))

            for entry in entries:
                try:
                    item = transform_journal_entry(cognito_uid, entry)
                    items_to_write.append(item)
                    total_records += 1
                except Exception as e:
                    logger.error(f"Transform error for user {firebase_uid}: {e}")
                    error_recorder.record(firebase_uid, str(entry.get("id", "?")), e, entry)
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
    if total_no_data > 0:
        logger.info(
            f"{total_no_data}/{total_processed} users had no journal data in Firestore "
            "(journal entries are stored locally in Drift/SQLite)"
        )

    error_recorder.close()
    mu.print_summary(
        "migrate_journal",
        total_processed,
        total_records,
        total_success,
        total_errors,
        error_recorder,
        dry_run,
    )
    return total_errors == 0


def main():
    parser = argparse.ArgumentParser(description="Migrate journal entries from Firestore to DynamoDB")
    mu.add_common_args(parser)
    args = parser.parse_args()
    mu.apply_common_args(args)

    success = migrate(dry_run=args.dry_run, batch_size=args.batch_size)
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
