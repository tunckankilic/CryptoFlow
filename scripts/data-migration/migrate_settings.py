#!/usr/bin/env python3
"""
CryptoFlow Data Migration — User Settings

Source: Firestore users/{uid}/data/settings (may not exist — local Hive only)
Target: DynamoDB user-settings (PK: userId)

Strategy: If Firestore data exists, migrate it. Otherwise, create a default
settings record so every user has an entry in DynamoDB.
"""

import argparse
import sys

from tqdm import tqdm

import config
import migration_utils as mu

DEFAULT_NOTIFICATION_PREFERENCES = {
    "priceAlerts": True,
    "portfolioAlerts": True,
    "newsAlerts": False,
    "marketUpdates": False,
    "soundEnabled": True,
    "vibrationEnabled": True,
}


def transform_settings(user_id: str, settings: dict | None) -> dict:
    """Transform Firestore settings into a DynamoDB item.

    If settings is None, creates a default record.
    """
    now = mu.now_iso()

    if settings is None:
        return {
            "userId": user_id,
            "notificationPreferences": DEFAULT_NOTIFICATION_PREFERENCES.copy(),
            "updatedAt": now,
        }

    # Build notification preferences from available fields
    notif_prefs = {}
    for key in ("priceAlerts", "portfolioAlerts", "newsAlerts", "marketUpdates", "soundEnabled", "vibrationEnabled"):
        val = settings.get(key)
        if val is not None:
            notif_prefs[key] = bool(val)
        else:
            notif_prefs[key] = DEFAULT_NOTIFICATION_PREFERENCES[key]

    # Check for nested notificationPreferences object
    nested = settings.get("notificationPreferences")
    if isinstance(nested, dict):
        for key in DEFAULT_NOTIFICATION_PREFERENCES:
            if key in nested:
                notif_prefs[key] = bool(nested[key])

    item = {
        "userId": user_id,
        "notificationPreferences": notif_prefs,
        "updatedAt": mu.firestore_timestamp_to_iso(settings.get("updatedAt")) or now,
    }

    # Preserve other settings fields if present
    for key in ("themeMode", "currency", "locale"):
        if settings.get(key):
            item[key] = settings[key]

    return item


def migrate(dry_run: bool = False, batch_size: int = 100):
    logger = mu.setup_logging("migrate_settings")
    error_recorder = mu.MigrationErrorRecorder("user_settings")

    logger.info("Counting Firestore users...")
    total_users = mu.count_firestore_users()
    logger.info(f"Found {total_users} users")

    table = mu.get_dynamodb_table("user_settings")
    total_processed = 0
    total_success = 0
    total_errors = 0
    total_records = 0
    total_defaults = 0
    skipped_no_mapping = 0

    progress = tqdm(total=total_users, desc="Migrating settings", unit="user")

    for user_batch in mu.iter_firestore_users(batch_size=batch_size):
        items_to_write = []

        for user_doc in user_batch:
            firebase_uid = user_doc.id
            cognito_uid = mu.map_uid(firebase_uid)

            if cognito_uid is None:
                skipped_no_mapping += 1
                progress.update(1)
                continue

            settings_data = mu.get_user_data_doc(firebase_uid, config.FIRESTORE_SETTINGS_DOC)

            try:
                item = transform_settings(cognito_uid, settings_data)
                items_to_write.append(item)
                total_records += 1
                if settings_data is None:
                    total_defaults += 1
            except Exception as e:
                logger.error(f"Transform error for user {firebase_uid}: {e}")
                error_recorder.record(firebase_uid, "settings", e, settings_data or {})
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
    if total_defaults > 0:
        logger.info(f"Created {total_defaults} default settings records (no Firestore data)")

    error_recorder.close()
    mu.print_summary(
        "migrate_settings",
        total_processed,
        total_records,
        total_success,
        total_errors,
        error_recorder,
        dry_run,
    )
    return total_errors == 0


def main():
    parser = argparse.ArgumentParser(description="Migrate user settings from Firestore to DynamoDB")
    mu.add_common_args(parser)
    args = parser.parse_args()
    mu.apply_common_args(args)

    success = migrate(dry_run=args.dry_run, batch_size=args.batch_size)
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
