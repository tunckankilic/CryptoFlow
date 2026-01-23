import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:design_system/design_system.dart';

// BLoCs
import 'package:portfolio/portfolio.dart';
import 'package:alerts/alerts.dart';
import 'package:watchlist/watchlist.dart';
import 'package:settings/settings.dart';
import 'package:auth/auth.dart';

import 'di/injection_container.dart';
import 'navigation/app_router.dart';

/// Main CryptoFlow application
class CryptoFlowApp extends StatelessWidget {
  const CryptoFlowApp({super.key});

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

            // Navigation
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
