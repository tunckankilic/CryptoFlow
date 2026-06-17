# CryptoFlow — Flutter app

> 📖 Full project documentation lives at the **[repository root README](../README.md)** — features, architecture, tech stack, and AWS setup.

This directory contains the Flutter application (a Clean Architecture monorepo under `packages/`).

## Quick start

```bash
flutter pub get

# Generate code (DI, Drift, JSON) — root + Drift packages
for p in . packages/market packages/portfolio; do (cd "$p" && dart run build_runner build); done

# Run (provide AWS config via --dart-define-from-file; see root README)
flutter run --dart-define-from-file=config.json
```

## Tests

```bash
flutter test
```

See the [root README](../README.md) for backend configuration, build, and architecture details.
