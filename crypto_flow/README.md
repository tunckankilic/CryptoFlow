![CI](https://github.com/tunckankilic/CryptoWave/workflows/CI/badge.svg)
![Release iOS](https://github.com/tunckankilic/CryptoWave/workflows/Release%20iOS/badge.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.19-blue.svg)
![Fastlane](https://img.shields.io/badge/Fastlane-iOS-00F200.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

# crypto_wave

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## What I Did:
- Created notifications package with domain, data, and presentation layers
- Added FCM datasource and local notification datasource
- Implemented NotificationBloc with settings management
- Updated alerts package with notificationEnabled and pushEnabled fields
- Added AlertCheckerService for background price monitoring
- Created notification_module.dart for dependency injection
- Configured iOS push notifications (Info.plist, AppDelegate.swift)
- Integrated NotificationBloc into settings page with toggle controls
- Added NotificationBloc to MultiBlocProvider in app.dart
- Fixed flutter_local_notifications v20 API (named parameters)
- Added unit tests for entities and BLoC (10 tests passing)

## Next On:
- Run tests and bug fixes