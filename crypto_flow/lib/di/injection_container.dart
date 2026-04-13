import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

// Package imports
import 'package:alerts/alerts.dart';
import 'package:auth/auth.dart';
import 'package:notifications/notifications.dart';
import 'package:portfolio/portfolio.dart';
import 'package:watchlist/watchlist.dart';
import 'package:settings/settings.dart';

// DI modules
import 'core_module.dart';
import 'market_module.dart';
import 'portfolio_module.dart';
import 'alerts_module.dart';
import 'watchlist_module.dart';
import 'settings_module.dart';
import 'auth_module.dart';
import 'notification_module.dart';

final getIt = GetIt.instance;

/// Configure all dependencies
Future<void> configureDependencies() async {
  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  if (!Hive.isAdapterRegistered(10)) {
    Hive.registerAdapter(UserSettingsModelAdapter());
  }
  if (!Hive.isAdapterRegistered(11)) {
    Hive.registerAdapter(WatchlistItemModelAdapter());
  }
  if (!Hive.isAdapterRegistered(12)) {
    Hive.registerAdapter(PriceAlertModelAdapter());
  }
  if (!Hive.isAdapterRegistered(13)) {
    Hive.registerAdapter(NotificationSettingsModelAdapter());
  }

  // Open Hive boxes
  await Hive.openBox<UserSettingsModel>('settings');
  await Hive.openBox<WatchlistItemModel>('watchlist');
  await Hive.openBox<PriceAlertModel>('alerts');

  // Initialize Firebase
  await Firebase.initializeApp();

  // Register modules
  await registerCoreModule();
  await registerMarketModule();
  await registerPortfolioModule();
  await registerAlertsModule();
  await registerWatchlistModule();
  await registerSettingsModule();
  await registerAuthModule();
  await initNotificationModule(getIt);
}

/// Dispose all resources — close global BLoCs before resetting GetIt
Future<void> disposeDependencies() async {
  // Close global singleton BLoCs to cancel their stream subscriptions
  if (getIt.isRegistered<AuthBloc>()) await getIt<AuthBloc>().close();
  if (getIt.isRegistered<PortfolioBloc>()) await getIt<PortfolioBloc>().close();
  if (getIt.isRegistered<JournalBloc>()) await getIt<JournalBloc>().close();
  if (getIt.isRegistered<JournalStatsBloc>()) {
    await getIt<JournalStatsBloc>().close();
  }
  if (getIt.isRegistered<AlertBloc>()) await getIt<AlertBloc>().close();
  if (getIt.isRegistered<WatchlistBloc>()) await getIt<WatchlistBloc>().close();
  if (getIt.isRegistered<SettingsBloc>()) await getIt<SettingsBloc>().close();
  if (getIt.isRegistered<NotificationBloc>()) {
    await getIt<NotificationBloc>().close();
  }

  await getIt.reset();
  await Hive.close();
}
