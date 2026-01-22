import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Pages
import 'package:market/market.dart';
import 'package:portfolio/portfolio.dart';
import 'package:alerts/alerts.dart';
import 'package:watchlist/watchlist.dart';
import 'package:settings/settings.dart';

import '../di/injection_container.dart';
import 'app_shell.dart';

/// App router configuration using GoRouter
final appRouter = GoRouter(
  initialLocation: '/',
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
  ],
);
