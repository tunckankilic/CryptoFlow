import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Pages
import 'package:market/market.dart';
import 'package:portfolio/portfolio.dart';
import 'package:alerts/alerts.dart';
import 'package:watchlist/watchlist.dart';
import 'package:settings/settings.dart';
import 'package:auth/auth.dart';

import '../di/injection_container.dart';
import 'app_shell.dart';

/// Notifier that listens to AuthBloc and notifies GoRouter to refresh
class AuthNotifier extends ChangeNotifier {
  late final StreamSubscription<AuthState> _subscription;

  AuthNotifier(AuthBloc authBloc) {
    _subscription = authBloc.stream.listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// App router configuration using GoRouter
GoRouter createAppRouter(AuthBloc authBloc) {
  final authNotifier = AuthNotifier(authBloc);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: authNotifier,
    redirect: (context, state) async {
      final authState = authBloc.state;
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToOnboarding = state.matchedLocation == '/onboarding';

      // If auth is still loading or initial, don't redirect
      if (authState is AuthInitial || authState is AuthLoading) {
        return null;
      }

      // Check onboarding status
      final settingsRepo = getIt<SettingsRepository>();
      final settingsResult = await settingsRepo.getSettings();
      final hasSeenOnboarding = settingsResult.fold(
        (_) => false,
        (settings) => settings.hasSeenOnboarding,
      );

      // If haven't seen onboarding and not already going there
      if (!hasSeenOnboarding && !isGoingToOnboarding) {
        return '/onboarding';
      }

      // If user is not authenticated and not going to login/onboarding
      if (authState is AuthUnauthenticated) {
        return (isGoingToLogin || isGoingToOnboarding) ? null : '/login';
      }

      // If user is authenticated and going to login/onboarding, redirect to home
      if (authState is AuthAuthenticated &&
          (isGoingToLogin || isGoingToOnboarding)) {
        return '/';
      }

      // No redirect needed
      return null;
    },
    routes: [
      // Shell route for bottom navigation
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'markets',
            pageBuilder: (context, state) => NoTransitionPage(
              child: BlocProvider(
                create: (_) => getIt<TickerListBloc>(),
                child: const MarketListPage(),
              ),
            ),
          ),
          GoRoute(
            path: '/watchlist',
            name: 'watchlist',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: WatchlistPage(),
            ),
          ),
          GoRoute(
            path: '/portfolio',
            name: 'portfolio',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PortfolioPage(),
            ),
          ),
          GoRoute(
            path: '/alerts',
            name: 'alerts',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AlertsPage(),
            ),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsPage(),
            ),
          ),
        ],
      ),
      // Detail routes (outside shell for full-screen)
      GoRoute(
        path: '/ticker/:symbol',
        name: 'ticker-detail',
        builder: (context, state) {
          final symbol = state.pathParameters['symbol']!;
          return BlocProvider(
            create: (_) => getIt<TickerDetailBloc>()
              ..add(LoadTickerDetail(symbol))
              ..add(SubscribeToTickerUpdates(symbol)),
            child: TickerDetailPage(symbol: symbol),
          );
        },
      ),
      GoRoute(
        path: '/portfolio/add',
        name: 'add-transaction',
        builder: (context, state) => const AddTransactionPage(),
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<TickerListBloc>()..add(const LoadTickers()),
          child: const SearchPage(),
        ),
      ),
      // Auth routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
      // Onboarding route
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => OnboardingPage(
          settingsRepository: getIt<SettingsRepository>(),
        ),
      ),
    ],
  );
}
