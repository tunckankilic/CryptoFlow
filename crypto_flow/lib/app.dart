import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
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

/// Main CryptoWave application
class CryptoWaveApp extends StatefulWidget {
  const CryptoWaveApp({super.key});

  @override
  State<CryptoWaveApp> createState() => _CryptoWaveAppState();
}

class _CryptoWaveAppState extends State<CryptoWaveApp> {
  late final GoRouter _router;
  late final AuthNotifier _authNotifier;

  @override
  void initState() {
    super.initState();
    // Create AuthNotifier and router once — store notifier for disposal
    _authNotifier = AuthNotifier(getIt<AuthBloc>());
    _router = createAppRouter(getIt<AuthBloc>(), authNotifier: _authNotifier);
  }

  @override
  void dispose() {
    _authNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Repositories (for widgets that need direct access)
        Provider<SettingsRepository>(
          create: (_) => getIt<SettingsRepository>(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // Global BLoCs — use .value() since they are lazySingletons in GetIt.
          // Initial events are dispatched once here; subsequent rebuilds reuse
          // the same instance without re-dispatching.
          BlocProvider<AuthBloc>.value(
            value: getIt<AuthBloc>()..add(const AuthCheckRequested()),
          ),
          BlocProvider<WatchlistBloc>.value(
            value: getIt<WatchlistBloc>()..add(const LoadWatchlist()),
          ),
          BlocProvider<PortfolioBloc>.value(
            value: getIt<PortfolioBloc>()..add(const LoadPortfolio()),
          ),
          BlocProvider<JournalBloc>.value(
            value: getIt<JournalBloc>(),
          ),
          BlocProvider<JournalStatsBloc>.value(
            value: getIt<JournalStatsBloc>(),
          ),
          BlocProvider<AlertBloc>.value(
            value: getIt<AlertBloc>()..add(const LoadAlerts()),
          ),
          BlocProvider<SettingsBloc>.value(
            value: getIt<SettingsBloc>()..add(const LoadSettings()),
          ),
          BlocProvider<NotificationBloc>.value(
            value: getIt<NotificationBloc>()
              ..add(const InitializeNotificationsEvent()),
          ),
        ],
        child: BlocBuilder<SettingsBloc, SettingsState>(
          buildWhen: (prev, curr) => prev.themeMode != curr.themeMode,
          builder: (context, settingsState) {
            return BlocListener<NotificationBloc, NotificationState>(
              listener: (context, state) {
                // Handle navigation when a notification is tapped
                if (state is NotificationReady &&
                    state.pendingNavigation != null) {
                  final notification = state.pendingNavigation!;

                  // Get the navigation action from the handler
                  final action =
                      NotificationNavigationHandler.getNavigationAction(
                          notification);

                  if (action != null) {
                    // Perform navigation based on action type
                    if (action.isPush) {
                      context.push(action.route);
                    } else {
                      context.go(action.route);
                    }

                    // Clear the pending navigation by emitting a new state
                    // This prevents re-navigation on rebuilds
                    context.read<NotificationBloc>().add(
                          const ClearPendingNavigation(),
                        );
                  }
                }
              },
              child: MaterialApp.router(
                title: 'CryptoWave',
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
              ),
            );
          },
        ),
      ),
    );
  }
}
