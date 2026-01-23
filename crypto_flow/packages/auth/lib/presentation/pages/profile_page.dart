import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Package imports for blocs
import 'package:portfolio/portfolio.dart';
import 'package:alerts/alerts.dart';
import 'package:watchlist/watchlist.dart';

import '../../data/services/export_service.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/profile_header.dart';

/// Profile page displaying user information and settings
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
          if (state is AuthUnauthenticated) {
            // Navigate back or to login
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return _buildAuthenticatedContent(context, state);
          }

          if (state is AuthLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return _buildUnauthenticatedContent(context);
        },
      ),
    );
  }

  Widget _buildAuthenticatedContent(
    BuildContext context,
    AuthAuthenticated state,
  ) {
    final theme = Theme.of(context);
    final user = state.user;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile Header
          ProfileHeader(user: user),

          const Divider(),

          // Account Section
          _buildSectionHeader(context, 'Account'),

          if (user.isAnonymous)
            _buildListTile(
              context,
              icon: Icons.link,
              title: 'Link Account',
              subtitle: 'Connect Google or Apple to save your data',
              onTap: () => _showLinkAccountDialog(context),
            ),

          _buildListTile(
            context,
            icon: Icons.security,
            title: 'Privacy & Security',
            subtitle: 'Manage your privacy settings',
            onTap: () => _showPrivacySettingsDialog(context),
          ),

          const Divider(),

          // Data Section
          _buildSectionHeader(context, 'Data'),

          _buildListTile(
            context,
            icon: Icons.cloud_sync,
            title: 'Sync Status',
            subtitle: user.isAnonymous ? 'Not synced' : 'Synced with cloud',
            trailing: Icon(
              user.isAnonymous ? Icons.cloud_off : Icons.cloud_done,
              color: user.isAnonymous ? Colors.grey : Colors.green,
            ),
          ),

          _buildListTile(
            context,
            icon: Icons.download,
            title: 'Export Data',
            subtitle: 'Download your portfolio and alerts',
            onTap: () => _showExportDataDialog(context),
          ),

          const Divider(),

          // Danger Zone
          _buildSectionHeader(context, 'Danger Zone'),

          _buildListTile(
            context,
            icon: Icons.logout,
            title: 'Sign Out',
            iconColor: theme.colorScheme.primary,
            onTap: () => _showSignOutDialog(context),
          ),

          if (!user.isAnonymous)
            _buildListTile(
              context,
              icon: Icons.delete_forever,
              title: 'Delete Account',
              subtitle: 'Permanently delete your account and data',
              iconColor: theme.colorScheme.error,
              textColor: theme.colorScheme.error,
              onTap: () => _showDeleteAccountDialog(context),
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildUnauthenticatedContent(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 80,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'Not Signed In',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to sync your data across devices',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go('/login'),
              icon: const Icon(Icons.login),
              label: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? iconColor,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: iconColor ?? theme.iconTheme.color),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing:
          trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthBloc>().add(const AuthSignOutRequested());
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This action cannot be undone. All your data including portfolio, '
          'alerts, and watchlist will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthBloc>().add(const AuthDeleteAccountRequested());
            },
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showLinkAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Link Account'),
        content: const Text(
          'Link your guest account to Google or Apple to save your data '
          'and sync across devices.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthBloc>().add(const AuthGoogleSignInRequested());
            },
            icon: const Icon(Icons.g_mobiledata, size: 20),
            label: const Text('Google'),
          ),
          if (Theme.of(context).platform == TargetPlatform.iOS)
            TextButton.icon(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.read<AuthBloc>().add(const AuthAppleSignInRequested());
              },
              icon: const Icon(Icons.apple, size: 20),
              label: const Text('Apple'),
            ),
        ],
      ),
    );
  }

  void _showPrivacySettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Privacy & Security'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.visibility_off),
              title: Text('Data Privacy'),
              subtitle: Text('Your data is stored locally on your device'),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: Icon(Icons.lock),
              title: Text('Secure Storage'),
              subtitle: Text('Sensitive data is encrypted'),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: Icon(Icons.cloud),
              title: Text('Cloud Sync'),
              subtitle: Text('Synced data is secured with Firebase'),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showExportDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Export Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Export your data in JSON format:'),
            const SizedBox(height: 16),
            _buildExportOption(
              context,
              icon: Icons.pie_chart,
              title: 'Portfolio',
              onTap: () async {
                Navigator.of(ctx).pop();
                await _exportPortfolio(context);
              },
            ),
            _buildExportOption(
              context,
              icon: Icons.notifications,
              title: 'Alerts',
              onTap: () async {
                Navigator.of(ctx).pop();
                await _exportAlerts(context);
              },
            ),
            _buildExportOption(
              context,
              icon: Icons.star,
              title: 'Watchlist',
              onTap: () async {
                Navigator.of(ctx).pop();
                await _exportWatchlist(context);
              },
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await _exportAll(context);
              },
              icon: const Icon(Icons.download),
              label: const Text('Export All'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportPortfolio(BuildContext context) async {
    try {
      final portfolioBloc = context.read<PortfolioBloc>();
      final state = portfolioBloc.state;

      if (state is PortfolioLoaded) {
        final holdings = state.holdings
            .map((h) => {
                  'symbol': h.symbol,
                  'quantity': h.quantity,
                  'avgBuyPrice': h.avgBuyPrice,
                })
            .toList();

        final transactions = state.transactions
            .map((t) => {
                  'symbol': t.symbol,
                  'type': t.type.name,
                  'quantity': t.quantity,
                  'price': t.price,
                  'date': t.timestamp.toIso8601String(),
                })
            .toList();

        final success = await ExportService.exportPortfolio(
          holdings: holdings,
          transactions: transactions,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success
                  ? 'Portfolio exported successfully!'
                  : 'Failed to export portfolio'),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No portfolio data to export')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export error: $e')),
        );
      }
    }
  }

  Future<void> _exportAlerts(BuildContext context) async {
    try {
      final alertBloc = context.read<AlertBloc>();
      final state = alertBloc.state;

      if (state is AlertLoaded) {
        final alerts = state.alerts
            .map((a) => {
                  'symbol': a.symbol,
                  'targetPrice': a.targetPrice,
                  'type': a.type.name,
                  'isActive': a.isActive,
                  'createdAt': a.createdAt.toIso8601String(),
                })
            .toList();

        final success = await ExportService.exportAlerts(alerts: alerts);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success
                  ? 'Alerts exported successfully!'
                  : 'Failed to export alerts'),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No alerts data to export')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export error: $e')),
        );
      }
    }
  }

  Future<void> _exportWatchlist(BuildContext context) async {
    try {
      final watchlistBloc = context.read<WatchlistBloc>();
      final state = watchlistBloc.state;

      if (state is WatchlistLoaded) {
        final items = state.items
            .map((item) => {
                  'symbol': item.symbol,
                  'addedAt': item.addedAt.toIso8601String(),
                })
            .toList();

        final success = await ExportService.exportWatchlist(items: items);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success
                  ? 'Watchlist exported successfully!'
                  : 'Failed to export watchlist'),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No watchlist data to export')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export error: $e')),
        );
      }
    }
  }

  Future<void> _exportAll(BuildContext context) async {
    try {
      // Get portfolio data
      final portfolioBloc = context.read<PortfolioBloc>();
      final portfolioState = portfolioBloc.state;

      List<Map<String, dynamic>> holdings = [];
      List<Map<String, dynamic>> transactions = [];

      if (portfolioState is PortfolioLoaded) {
        holdings = portfolioState.holdings
            .map((h) => {
                  'symbol': h.symbol,
                  'quantity': h.quantity,
                  'avgBuyPrice': h.avgBuyPrice,
                })
            .toList();

        transactions = portfolioState.transactions
            .map((t) => {
                  'symbol': t.symbol,
                  'type': t.type.name,
                  'quantity': t.quantity,
                  'price': t.price,
                  'date': t.timestamp.toIso8601String(),
                })
            .toList();
      }

      // Get alerts data
      final alertBloc = context.read<AlertBloc>();
      final alertState = alertBloc.state;

      List<Map<String, dynamic>> alerts = [];
      if (alertState is AlertLoaded) {
        alerts = alertState.alerts
            .map((a) => {
                  'symbol': a.symbol,
                  'targetPrice': a.targetPrice,
                  'type': a.type.name,
                  'isActive': a.isActive,
                  'createdAt': a.createdAt.toIso8601String(),
                })
            .toList();
      }

      // Get watchlist data
      final watchlistBloc = context.read<WatchlistBloc>();
      final watchlistState = watchlistBloc.state;

      List<Map<String, dynamic>> watchlistItems = [];
      if (watchlistState is WatchlistLoaded) {
        watchlistItems = watchlistState.items
            .map((item) => {
                  'symbol': item.symbol,
                  'addedAt': item.addedAt.toIso8601String(),
                })
            .toList();
      }

      final success = await ExportService.exportAll(
        holdings: holdings,
        transactions: transactions,
        alerts: alerts,
        watchlistItems: watchlistItems,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'All data exported successfully!'
                : 'Failed to export data'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export error: $e')),
        );
      }
    }
  }

  Widget _buildExportOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
    );
  }
}
