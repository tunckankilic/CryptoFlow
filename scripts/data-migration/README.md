# CryptoFlow — Firestore → DynamoDB Data Migration

Migration scripts for transferring user data from Firebase Firestore to AWS DynamoDB.

## Prerequisites

- Python 3.10+
- AWS CLI configured with appropriate credentials (`eu-central-1` region)
- Firebase service account JSON file
- UID mapping file (Firebase UID → Cognito UID) unless using `--use-firebase-uid`

## Setup

```bash
cd scripts/data-migration
pip install -r requirements.txt
```

## Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `FIREBASE_CREDENTIALS_PATH` | Yes | — | Path to Firebase service account JSON |
| `AWS_REGION` | No | `eu-central-1` | AWS region for DynamoDB |
| `TABLE_PREFIX` | No | `cryptoflow` | DynamoDB table name prefix |
| `TABLE_ENVIRONMENT` | No | `prod` | Environment suffix (dev/staging/prod) |
| `UID_MAPPING_PATH` | No | `./uid_mapping.csv` | Path to UID mapping CSV |
| `USE_FIREBASE_UID` | No | `false` | Skip UID mapping, use Firebase UIDs directly |
| `LOG_LEVEL` | No | `INFO` | Logging level (DEBUG/INFO/WARNING/ERROR) |
| `ERROR_LOG_DIR` | No | `./migration_errors` | Directory for error logs |

Table names are resolved as: `{TABLE_PREFIX}-{TABLE_ENVIRONMENT}-{logical_name}`
(e.g., `cryptoflow-prod-alerts`)

## UID Mapping File Format

CSV file with header row:

```csv
firebase_uid,cognito_uid
abc123,550e8400-e29b-41d4-a716-446655440000
def456,6ba7b810-9dad-11d1-80b4-00c04fd430c8
```

If your Cognito setup reuses Firebase UIDs, use `--use-firebase-uid` to skip mapping.

## Execution Order

Run each script with `--dry-run` first to preview changes, then without for live migration.

```bash
# Set required environment variable
export FIREBASE_CREDENTIALS_PATH=/path/to/service-account.json

# Step 1: Portfolio holdings
python migrate_portfolio.py --dry-run
python migrate_portfolio.py

# Step 2: Watchlist
python migrate_watchlist.py --dry-run
python migrate_watchlist.py

# Step 3: Price alerts
python migrate_alerts.py --dry-run
python migrate_alerts.py

# Step 4: User settings
python migrate_settings.py --dry-run
python migrate_settings.py

# Step 5: Journal entries (likely empty — local-only data)
python migrate_journal.py --dry-run
python migrate_journal.py

# Step 6: Verify migration
python verify_migration.py --output migration_report.json

# Step 7: Rollback (only if needed)
python rollback.py                              # Preview mode
python rollback.py --confirm-rollback            # Full rollback
python rollback.py --confirm-rollback --tables alerts,watchlist  # Selective
```

## Common CLI Options

All migration scripts support:

| Flag | Description |
|------|-------------|
| `--dry-run` | Preview changes without writing to DynamoDB |
| `--batch-size N` | Firestore users per batch (default: 100) |
| `--uid-mapping PATH` | Override UID mapping file path |
| `--use-firebase-uid` | Skip UID mapping, use Firebase UIDs directly |

## Firestore Data Structure

Based on `CloudSyncService`, data is stored as:

```
users/{uid}                         → user document (lastSyncAt)
users/{uid}/data/portfolio          → { holdings: [...], updatedAt }
users/{uid}/data/watchlist          → { items: [...], updatedAt }
users/{uid}/data/alerts             → { alerts: [...], updatedAt }
users/{uid}/data/settings           → { ... } (may not exist)
users/{uid}/data/journal            → { entries: [...] } (may not exist)
```

**Important notes:**
- **Transactions** are NOT synced to Firestore (stored locally in Drift/SQLite). The `portfolio-transactions` table will remain empty after migration.
- **Journal entries** are typically local-only. The migration script handles missing data gracefully.
- **Settings** may not exist in Firestore. The script creates default records for users without cloud settings.

## DynamoDB Target Tables

| Table | PK | SK | Notes |
|-------|----|----|-------|
| `portfolio-holdings` | `userId` | `holdingId` | Deterministic ID: `HLD-{sha256(userId+symbol)[:16]}` |
| `portfolio-transactions` | `userId` | `transactionId` | Remains empty (local-only data) |
| `watchlist` | `userId` | `symbol` | Natural idempotency via composite key |
| `alerts` | `userId` | `alertId` | GSI: `status-index` (status → alertId) |
| `user-settings` | `userId` | — | Default created if no Firestore data |
| `journal-entries` | `userId` | `entryId` | Format: `JNL-{id:08d}` or ULID |

## Error Handling

- **Record-level errors**: Logged and skipped; script continues. Failed records saved to `migration_errors/errors_{table}_{timestamp}.jsonl`
- **Batch-level errors**: Retried as individual writes to isolate the problematic record
- **Fatal errors**: Script aborts (connection failures, missing credentials)
- **Summary**: Every script prints a summary with total/success/error counts

## Rollback

The rollback script has multiple safety features:

1. **Preview mode** (default): Shows what would be deleted without `--confirm-rollback`
2. **JSONL backup**: Exports all table data before deletion (skip with `--skip-backup`)
3. **10-second countdown**: Ctrl+C to cancel
4. **Selective rollback**: `--tables alerts,watchlist` to target specific tables

Backups are saved to `migration_errors/rollback_backups/`.

## Idempotency

All scripts are safe to re-run:
- Portfolio holdings use deterministic IDs based on `userId + symbol`
- Watchlist uses `(userId, symbol)` natural composite key
- Alerts use existing Firestore IDs
- Settings and journal use put-item (overwrites with same key)
