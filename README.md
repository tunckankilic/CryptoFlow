# CryptoFlow 🌊

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-iOS-black?logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20%2B%20BLoC-6E40C9.svg)](#architecture)
[![Backend](https://img.shields.io/badge/Backend-AWS%20Cognito-FF9900?logo=amazonaws&logoColor=white)](https://aws.amazon.com/cognito/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A comprehensive cryptocurrency **portfolio tracker and trading journal** built with Flutter — featuring real-time market data over WebSocket, advanced trading analytics, professional PDF reporting, and an AWS-backed authentication stack.

> **Engineering highlights:** Clean Architecture across a **9-package monorepo**, BLoC state management, offline-first persistence with Drift (SQLite), real-time Binance WebSocket streams, and AWS Cognito auth with Google / Apple social sign-in.

---

## Features

### 📈 Market & Portfolio
- **Real-time market data** — live prices over the Binance WebSocket API
- **Portfolio tracking** — holdings with automatic P&L calculation
- **Price alerts** — custom thresholds with local notifications
- **Watchlist** — track your favorite symbols
- **Live charts** — interactive candlesticks across multiple timeframes
- **Order book** — real-time bid/ask ladder visualization

### 📓 Trading Journal
- **Trade logging** — entries, exits, P&L, and position sizes
- **Emotional state tracking** — document trading psychology
- **Strategy tagging** — group trades for pattern analysis
- **Chart screenshots** — attach setups for later review
- **Automatic trade duration** and **custom tags**

### 📊 Advanced Analytics
- **Win rate**, **profit factor**, and **R:R** metrics
- **Equity curve** and **drawdown** analysis
- **Performance by period** — daily / weekly / monthly breakdowns

### 📄 Professional Reports
- **PDF export** of comprehensive trading reports
- **Statistics summary** and detailed trade history
- **Shareable** analysis output

### 🔐 Security & UX
- **AWS Cognito authentication** with email + Google / Apple social sign-in
- **Biometric app lock** — Face ID / Touch ID (`local_auth`)
- **Secure token storage** and session restore
- **Dark mode**, **deep linking**, **iOS home-screen widgets**, and a guided onboarding flow

---

## Architecture

Built with **Clean Architecture** and organized as a feature-based **multi-package monorepo**:

```
CryptoFlow/
└── crypto_flow/
    ├── lib/
    │   ├── di/              # Dependency injection (get_it + injectable)
    │   ├── navigation/      # GoRouter configuration
    │   └── presentation/    # App shell & root widget
    └── packages/
        ├── core/            # Shared utilities, networking, AWS config
        ├── design_system/   # UI components, theming, charts
        ├── market/          # Market data & real-time tickers
        ├── portfolio/       # Holdings & trading journal
        ├── alerts/          # Price alerts
        ├── watchlist/       # Favorite symbols
        ├── settings/        # User preferences
        ├── auth/            # AWS Cognito + social + biometric auth
        └── notifications/   # Local & APNs notifications
```

Each package owns its own `data / domain / presentation` layers and is independently testable.

### Tech Stack

| Area | Technology |
|------|------------|
| Framework | Flutter 3.x / Dart 3 |
| State management | BLoC (`flutter_bloc`) |
| Dependency injection | `get_it` + `injectable` |
| Navigation | `go_router` |
| Local database | Drift (SQLite) |
| Real-time data | Binance WebSocket API |
| Authentication | AWS Cognito (`amplify_auth_cognito`), Google & Apple sign-in, biometrics |
| Backend (AWS) | Cognito (User + Identity Pools), API Gateway (REST + WebSocket), Pinpoint analytics |
| Notifications | `flutter_local_notifications` (local + APNs) |
| PDF / reporting | `pdf` + `printing` |
| Testing | `mocktail`, `bloc_test` |
| CI/CD | GitHub Actions (format, analyze, test, build on every PR) + Codemagic (iOS release to TestFlight) |

---

## Getting Started

### Prerequisites
- Flutter SDK **3.24+** (developed on 3.44 / Dart 3.12)
- Xcode 15+ and CocoaPods (for iOS)
- An AWS backend: Cognito User Pool + Identity Pool, and an API Gateway deployment

### 1. Clone & install
```bash
git clone https://github.com/tunckankilic/CryptoFlow
cd CryptoFlow/crypto_flow
flutter pub get
```

### 2. Generate code (DI, Drift, JSON)
Codegen runs per package — run it in the app root and the packages that use Drift:
```bash
for p in . packages/market packages/portfolio; do (cd "$p" && dart run build_runner build); done
```

### 3. Configure the backend
The app reads AWS settings from `amplify_outputs.json` (Cognito) and compile-time
`--dart-define` values (API Gateway endpoints). Create a `config.json`:

```json
{
  "ENV": "prod",
  "API_BASE_URL": "https://<your-id>.execute-api.<region>.amazonaws.com/prod",
  "WS_BASE_URL": "wss://<your-id>.execute-api.<region>.amazonaws.com/prod",
  "COGNITO_USER_POOL_ID": "<region>_xxxxxxxxx",
  "COGNITO_CLIENT_ID": "xxxxxxxxxxxxxxxxxxxxxxxxxx",
  "COGNITO_IDENTITY_POOL_ID": "<region>:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "AWS_REGION": "eu-central-1"
}
```

> `amplify_outputs.json` contains only public client identifiers (pool/client IDs) — no secrets. Provide your own values for a private deployment.

### 4. Run
```bash
flutter run --dart-define-from-file=config.json
```

### Build for iOS (release)
```bash
flutter build ios --release --dart-define-from-file=config.json
```

---

## Testing

```bash
# Run all tests
flutter test

# With coverage
flutter test --coverage
```

---

## Screenshots

> _Coming soon_ — portfolio dashboard, trading journal, analytics charts, and live market views.

---

## License

This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.

## Contact

**Tunç Kankılıç** — [@tunckankilic](https://github.com/tunckankilic)

Project: [github.com/tunckankilic/CryptoFlow](https://github.com/tunckankilic/CryptoFlow)

---

<sub>Market data provided by the [Binance API](https://binance-docs.github.io/apidocs/). Built with ❤️ using Flutter.</sub>
