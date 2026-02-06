# Changelog

All notable changes to CryptoWave will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-02-06

### Added
- 🎯 **CryptoWave Rebrand**: Complete rebranding from CryptoFlow to CryptoWave with updated branding, app name, and visual identity
- 📔 **Trading Journal**: Comprehensive trade journaling system
  - Record trade entries and exits with automatic P&L calculation
  - Emotional state tracking (confident, fearful, greedy, FOMO, revenge, neutral)
  - Strategy tagging and custom trade tags
  - Chart screenshot attachments
  - Trade duration tracking
  - Filter by symbol, date range, and tags
- 📊 **Advanced Analytics Dashboard**:
  - Win rate and profit factor metrics
  - Average risk-reward ratio tracking
  - Equity curve visualization
  - Drawdown analysis
  - Performance breakdown by period (daily, weekly, monthly, all-time)
  - PnL distribution charts
- 📄 **PDF Report Export**:
  - Professional trading reports with statistics summary
  - Complete trade history with metrics
  - Exportable and shareable analysis documents
- 🏷️ **Tag Management**: Organize trades with custom tags for better analysis
- 📸 **Screenshot Support**: Attach chart images to journal entries for trade review

### Changed
- Redesigned portfolio page with tabbed interface (Holdings / Journal / Analytics)
- Enhanced navigation with journal-specific routes
- Improved cross-feature integration:
  - "Log Trade" quick action from market detail page
  - "Add to Journal" action from portfolio holdings
  - Journal entry navigation throughout the app

### Technical
- Added `JournalBloc` and `JournalStatsBloc` to app state management
- Implemented journal repository with Drift database persistence
- Created use cases for journal entries, statistics, and analytics
- Added PDF generation service with professional formatting
- Enhanced dependency injection with journal module support

## [1.x.x] - Previous Versions

### Features Implemented
- 💰 **Portfolio Tracking**: Real-time holdings with P&L calculation
- 🚨 **Price Alerts**: Custom alerts with push notifications
- ⭐ **Watchlist Management**: Track favorite cryptocurrencies
- 📈 **Market Data**: Live prices via Binance WebSocket API
- 📊 **Interactive Charts**: Candlestick charts with multiple timeframes
- 📖 **Order Book**: Real-time bid/ask visualization
- 🔐 **Biometric Authentication**: Face ID and Touch ID support
- 🔒 **App Lock Screen**: Additional security layer
- 📱 **Push Notifications**: FCM integration for alerts
- 📲 **Deep Linking**: Navigate directly to specific screens
- 🏠 **iOS Home Screen Widgets**: Quick portfolio view
- 🎨 **Dark Mode**: Theme support
- 🎓 **Onboarding Flow**: First-time user experience
- ✅ **Comprehensive Testing**: Unit, widget, and integration tests

### Development Milestones
- Clean architecture with feature-based modules
- BLoC pattern for state management
- Drift for local database
- GoRouter for navigation
- Design system package for consistent UI
- CI/ CD pipeline with GitHub Actions
- Fastlane integration for iOS deployment

---

## Version Format

- **Major.Minor.Patch** (e.g., 2.0.0)
  - **Major**: Breaking changes or major feature additions
  - **Minor**: New features, backward compatible
  - **Patch**: Bug fixes and minor improvements

## Categories

- **Added**: New features
- **Changed**: Changes to existing functionality
- **Deprecated**: Soon-to-be removed features
- **Removed**: Removed features
- **Fixed**: Bug fixes
- **Security**: Vulnerability fixes
- **Technical**: Internal improvements

---

For more information, visit the [GitHub repository](https://github.com/tunckankilic/CryptoFlow).
