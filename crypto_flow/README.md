[![Codemagic build status](https://api.codemagic.io/apps/YOUR_APP_ID/ios-release/status_badge.svg)](https://codemagic.io/apps/YOUR_APP_ID/ios-release/latest_build)
[![Coverage](https://img.shields.io/badge/coverage-85%25-brightgreen.svg)](https://github.com/tunckankilic/CryptoWave)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.24-02569B?logo=flutter)](https://flutter.dev)

# CryptoWave 🌊

A comprehensive cryptocurrency portfolio tracker and trading journal built with Flutter, featuring real-time market data, advanced analytics, and professional reporting capabilities.

## Features

# Market & Portfolio
- **Real-time Market Data**: Live cryptocurrency prices powered by Binance WebSocket API
- **Portfolio Tracking**: Monitor your holdings with automatic P&L calculations
- **Price Alerts**: Set custom alerts with push notifications
- **Watchlist Management**: Track your favorite cryptocurrencies
- **Live Charts**: Interactive candlestick charts with multiple timeframes
- **Order Book**: Real-time bid/ask ladder visualization

# Trading Journal
- **Trade Logging**: Record entries, exits, P&L, and position sizes
- **Emotional State Tracking**: Document your trading psychology
- **Strategy Management**: Tag trades with strategies for pattern analysis
- **Chart Screenshots**: Attach trade setup screenshots for review
- **Trade Duration**: Automatic calculation of holding time
- **Custom Tags**: Organize trades with flexible tagging system

# Advanced Analytics
- **Win Rate Analysis**: Track trading performance over time
- **Profit Factor**: Calculate risk-adjusted returns
- **Equity Curve**: Visualize account growth
- **Drawdown Analysis**: Identify maximum losses
- **R:R Ratio**: Average risk-reward metrics
- **Performance by Period**: Daily, weekly, monthly breakdowns

# Professional Reports
- **PDF Export**: Generate comprehensive trading reports
- **Statistics Summary**: Win rate, avg R:R, profit factor
- **Trade History**: Detailed journal entries with metrics
- **Shareable**: Export and share your trading analysis

# Security & UX
- **Biometric Authentication**: Face ID / Touch ID support
- **App Lock**: Secure your data with PIN or biometric
- **Dark Mode**: Easy on the eyes for extended use
- **Deep Linking**: Quick navigation from notifications
- **Home Screen Widgets**: iOS widgets for quick portfolio view
- **Onboarding Flow**: Smooth first-time user experience

## Architecture

Built using **Clean Architecture** with feature-based modules:

```
crypto_wave/
├── lib/
│   ├── di/              # Dependency injection
│   ├── navigation/      # GoRouter configuration
│   └── presentation/    # Main app & shell
├── packages/
│   ├── core/           # Shared utilities
│   ├── design_system/  # UI components & theming
│   ├── market/         # Market data & tickers
│   ├── portfolio/      # Holdings & journal
│   ├── alerts/         # Price alerts
│   ├── watchlist/      # Favorite symbols
│   ├── settings/       # User preferences
│   ├── auth/           # Authentication
│   └── notifications/  # Push notifications
```

# Tech Stack

- **Framework**: Flutter 3.19
- **State Management**: BLoC pattern with flutter_bloc
- **Local Database**: Drift (SQLite)
- **Navigation**: GoRouter
- **Real-time Data**: WebSocket (Binance API)
- **PDF Generation**: pdf package
- **Authentication**: local_auth for biometrics
- **Notifications**: Firebase Cloud Messaging
- **Testing**: mocktail, bloc_test

## Getting Started

# Prerequisites

- Flutter SDK 3.19 or higher
- Xcode 15+ (for iOS)
- CocoaPods (for iOS dependencies)

# Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/tunckankilic/CryptoFlow
   cd CryptoFlow/crypto_flow
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code** (for Drift and JSON serialization)
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

# Running Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

# Building for Production

```bash
# iOS
flutter build ios --release

# Android
flutter build apk --release
```

## Screenshots

> Coming soon! Screenshots will be added showing portfolio dashboard, trading journal, analytics charts, and more.

##  Documentation

For detailed information about specific features:
- [Trading Journal Guide](docs/journal.md) _(coming soon)_
- [Analytics Dashboard](docs/analytics.md) _(coming soon)_
- [API Integration](docs/api.md) _(coming soon)_

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Market data provided by [Binance API](https://binance-docs.github.io/apidocs/)
- Icons and design inspiration from the Flutter community
- All contributors who helped build this project

## 📧 Contact

Tunç Kankılıç - [@tunckankilic](https://github.com/tunckankilic)

Project Link: [https://github.com/tunckankilic/CryptoFlow](https://github.com/tunckankilic/CryptoFlow)

---

**Made with ❤️ using Flutter**