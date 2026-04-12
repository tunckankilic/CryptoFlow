#!/usr/bin/env python3
"""
CryptoFlow Data Migration — Portfolio Holdings

Source: Firestore users/{uid}/data/portfolio → { holdings: [...], updatedAt }
Target: DynamoDB portfolio-holdings (PK: userId, SK: holdingId)

Note: Transactions are NOT synced to Firestore (local Drift/SQLite only).
      The portfolio-transactions table will remain empty after this migration.
"""

import argparse
import hashlib
import sys

from tqdm import tqdm

import config
import migration_utils as mu


def _deterministic_holding_id(user_id: str, symbol: str) -> str:
    """Generate a deterministic holdingId from userId + symbol.

    Holdings in Firestore have no unique ID; symbol is the natural key.
    We create a stable ID so re-runs produce the same holdingId.
    """
    raw = f"{user_id}:{symbol}".encode()
    digest = hashlib.sha256(raw).hexdigest()[:16]
    return f"HLD-{digest}"


def transform_holding(user_id: str, holding: dict, doc_updated_at) -> dict:
    """Transform a Firestore holding into a DynamoDB item."""
    symbol = holding.get("symbol", "")
    now = mu.now_iso()
    updated_at = mu.firestore_timestamp_to_iso(doc_updated_at) or now

    item = {
        "userId": user_id,
        "holdingId": _deterministic_holding_id(user_id, symbol),
        "symbol": symbol,
        "createdAt": updated_at,
        "updatedAt": updated_at,
    }

    # Optional fields
    if holding.get("baseAsset"):
        item["baseAsset"] = holding["baseAsset"]

    quantity = mu.to_decimal(holding.get("quantity"))
    if quantity is not None:
        item["quantity"] = quantity

    avg_price = mu.to_decimal(holding.get("avgBuyPrice"))
    if avg_price is not None:
        item["avgBuyPrice"] = avg_price

    first_buy = holding.get("firstBuyDate")
    if first_buy:
        item["firstBuyDate"] = mu.firestore_timestamp_to_iso(first_buy) or str(first_buy)

    if holding.get("notes"):
        item["notes"] = holding["notes"]

    return item


def migrate(dry_run: bool = False, batch_size: int = 100):
    logger = mu.setup_logging("migrate_portfolio")
    error_recorder = mu.MigrationErrorRecorder("portfolio_holdings")

    logger.info("Counting Firestore users...")
    total_users = mu.count_firestore_users()
    logger.info(f"Found {total_users} users")

    table = mu.get_dynamodb_table("portfolio_holdings")
    total_processed = 0
    total_success = 0
    total_errors = 0
    total_records = 0
    skipped_no_mapping = 0

    progress = tqdm(total=total_users, desc="Migrating portfolio holdings", unit="user")

    for user_batch in mu.iter_firestore_users(batch_size=batch_size):
        items_to_write = []

        for user_doc in user_batch:
            firebase_uid = user_doc.id
            cognito_uid = mu.map_uid(firebase_uid)

            if cognito_uid is None:
                skipped_no_mapping += 1
                logger.debug(f"Skipped user {firebase_uid}: no UID mapping")
                progress.update(1)
                continue

            # Fetch portfolio data document
            portfolio_data = mu.get_user_data_doc(firebase_uid, config.FIRESTORE_PORTFOLIO_DOC)
            if portfolio_data is None:
                logger.debug(f"User {firebase_uid}: no portfolio data")
                progress.update(1)
                total_processed += 1
                continue

            holdings = portfolio_data.get("holdings", [])
            doc_updated_at = portfolio_data.get("updatedAt")

            for holding in holdings:
                try:
                    item = transform_holding(cognito_uid, holding, doc_updated_at)
                    items_to_write.append(item)
                    total_records += 1
                except Exception as e:
                    logger.error(f"Transform error for user {firebase_uid}: {e}")
                    error_recorder.record(firebase_uid, holding.get("symbol", "?"), e, holding)
                    total_errors += 1

            total_processed += 1
            progress.update(1)

        # Batch write
        if items_to_write:
            s, err = mu.dynamo_batch_write(table, items_to_write, dry_run=dry_run, logger=logger)
            total_success += s
            total_errors += err

    progress.close()

    if skipped_no_mapping > 0:
        logger.warning(f"Skipped {skipped_no_mapping} users with no UID mapping")

    # Warn about transactions
    logger.info(
        "NOTE: Transactions are NOT in Firestore (local Drift/SQLite only). "
        "portfolio-transactions table remains empty."
    )

    error_recorder.close()
    mu.print_summary(
        "migrate_portfolio",
        total_processed,
        total_records,
        total_success,
        total_errors,
        error_recorder,
        dry_run,
    )
    return total_errors == 0


def main():
    parser = argparse.ArgumentParser(description="Migrate portfolio holdings from Firestore to DynamoDB")
    mu.add_common_args(parser)
    args = parser.parse_args()
    mu.apply_common_args(args)

    success = migrate(dry_run=args.dry_run, batch_size=args.batch_size)
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
