import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:design_system/design_system.dart';

// BLoCs
import 'package:portfolio/portfolio.dart';
import 'package:alerts/alerts.dart';
import 'package:watchlist/watchlist.dart';
import 'package:settings/settings.dart';
import 'package:auth/auth.dart';
import 'package:notifications/notifications.dart' hide LoadSettings;

import 'di/injection_container.dart';
import 'navigation/app_router.dart';
import 'presentation/widgets/biometric_guard.dart';

/// Main CryptoFlow application
class CryptoFlowApp extends StatefulWidget {
  const CryptoFlowApp({super.key});

  @override
  State<CryptoFlowApp> createState() => _CryptoFlowAppState();
}

class _CryptoFlowAppState extends State<CryptoFlowApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Create router once with AuthBloc
    _router = createAppRouter(getIt<AuthBloc>());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Global BLoCs (shared across pages)
        BlocProvider<AuthBloc>(
          create: (_) => getIt<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider<WatchlistBloc>(
          create: (_) => getIt<WatchlistBloc>()..add(const LoadWatchlist()),
        ),
        BlocProvider<PortfolioBloc>(
          create: (_) => getIt<PortfolioBloc>()..add(const LoadPortfolio()),
        ),
        BlocProvider<AlertBloc>(
          create: (_) => getIt<AlertBloc>()..add(const LoadAlerts()),
        ),
        BlocProvider<SettingsBloc>(
          create: (_) => getIt<SettingsBloc>()..add(const LoadSettings()),
        ),
        BlocProvider<NotificationBloc>(
          create: (_) => getIt<NotificationBloc>()
            ..add(const InitializeNotificationsEvent()),
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        buildWhen: (prev, curr) => prev.themeMode != curr.themeMode,
        builder: (context, settingsState) {
          return MaterialApp.router(
            title: 'CryptoFlow',
            debugShowCheckedModeBanner: false,

            // Theming
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsState.themeMode,

            // Navigation - use cached router
            routerConfig: _router,

            // Biometric guard wrapper
            builder: (context, child) {
              return BiometricGuard(child: child!);
            },
          );
        },
      ),
    );
  }
}
