#!/usr/bin/env python3
"""
CryptoFlow Data Migration — Price Alerts

Source: Firestore users/{uid}/data/alerts → { alerts: [...], updatedAt }
Target: DynamoDB alerts (PK: userId, SK: alertId) + GSI: status-index

Key transformations:
  - Type enum: percent_up → percentUp, percent_down → percentDown
  - Status derivation: isTriggered/isActive → status (active|triggered|disabled)
  - Timestamps: milliseconds epoch → ISO8601
"""

import argparse
import sys

from tqdm import tqdm

import config
import migration_utils as mu

# Firestore snake_case → DynamoDB camelCase mapping
_ALERT_TYPE_MAP = {
    "above": "above",
    "below": "below",
    "percent_up": "percentUp",
    "percent_down": "percentDown",
    # Already camelCase (in case Firestore data is mixed)
    "percentUp": "percentUp",
    "percentDown": "percentDown",
}

VALID_ALERT_TYPES = {"above", "below", "percentUp", "percentDown"}


def _derive_status(alert: dict) -> str:
    """Derive DynamoDB status field from Firestore isTriggered/isActive."""
    if alert.get("isTriggered"):
        return "triggered"
    if alert.get("isActive", True):
        return "active"
    return "disabled"


def transform_alert(user_id: str, alert: dict, logger) -> dict | None:
    """Transform a Firestore alert into a DynamoDB item.

    Returns None if the alert type is invalid (skipped).
    """
    # Type mapping with validation
    raw_type = alert.get("type", "")
    alert_type = _ALERT_TYPE_MAP.get(raw_type)
    if alert_type is None or alert_type not in VALID_ALERT_TYPES:
        logger.warning(f"Unknown alert type '{raw_type}' for user {user_id}, skipping")
        return None

    alert_id = str(alert.get("id", mu.generate_ulid()))
    status = _derive_status(alert)

    item = {
        "userId": user_id,
        "alertId": alert_id,
        "symbol": alert.get("symbol", ""),
        "type": alert_type,
        "status": status,
        "isTriggered": alert.get("isTriggered", False),
        "repeatEnabled": alert.get("repeatEnabled", False),
        "createdAt": mu.firestore_timestamp_to_iso(alert.get("createdAt")) or mu.now_iso(),
    }

    # Conditional numeric fields
    target_price = mu.to_decimal(alert.get("targetPrice"))
    if target_price is not None:
        item["targetPrice"] = target_price

    percent_change = mu.to_decimal(alert.get("percentChange"))
    if percent_change is not None:
        item["percentChange"] = percent_change

    base_price = mu.to_decimal(alert.get("basePrice"))
    if base_price is not None:
        item["basePrice"] = base_price

    # Conditional string fields
    if alert.get("note"):
        item["note"] = alert["note"]

    triggered_at = mu.firestore_timestamp_to_iso(alert.get("triggeredAt"))
    if triggered_at:
        item["triggeredAt"] = triggered_at
        item["lastTriggerDate"] = triggered_at

    return item


def migrate(dry_run: bool = False, batch_size: int = 100):
    logger = mu.setup_logging("migrate_alerts")
    error_recorder = mu.MigrationErrorRecorder("alerts")

    logger.info("Counting Firestore users...")
    total_users = mu.count_firestore_users()
    logger.info(f"Found {total_users} users")

    table = mu.get_dynamodb_table("alerts")
    total_processed = 0
    total_success = 0
    total_errors = 0
    total_records = 0
    total_skipped_type = 0
    skipped_no_mapping = 0

    progress = tqdm(total=total_users, desc="Migrating alerts", unit="user")

    for user_batch in mu.iter_firestore_users(batch_size=batch_size):
        items_to_write = []

        for user_doc in user_batch:
            firebase_uid = user_doc.id
            cognito_uid = mu.map_uid(firebase_uid)

            if cognito_uid is None:
                skipped_no_mapping += 1
                progress.update(1)
                continue

            alerts_data = mu.get_user_data_doc(firebase_uid, config.FIRESTORE_ALERTS_DOC)
            if alerts_data is None:
                progress.update(1)
                total_processed += 1
                continue

            alerts = alerts_data.get("alerts", [])

            for alert in alerts:
                try:
                    item = transform_alert(cognito_uid, alert, logger)
                    if item is None:
                        total_skipped_type += 1
                        continue
                    items_to_write.append(item)
                    total_records += 1
                except Exception as e:
                    logger.error(f"Transform error for user {firebase_uid}: {e}")
                    error_recorder.record(firebase_uid, str(alert.get("id", "?")), e, alert)
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
    if total_skipped_type > 0:
        logger.warning(f"Skipped {total_skipped_type} alerts with invalid type")

    error_recorder.close()
    mu.print_summary(
        "migrate_alerts",
        total_processed,
        total_records,
        total_success,
        total_errors,
        error_recorder,
        dry_run,
    )
    return total_errors == 0


def main():
    parser = argparse.ArgumentParser(description="Migrate price alerts from Firestore to DynamoDB")
    mu.add_common_args(parser)
    args = parser.parse_args()
    mu.apply_common_args(args)

    success = migrate(dry_run=args.dry_run, batch_size=args.batch_size)
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
