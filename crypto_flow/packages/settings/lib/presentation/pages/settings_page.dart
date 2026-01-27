import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

/// Settings page for user preferences
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SettingsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<SettingsBloc>().add(const LoadSettings());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is SettingsLoaded) {
            return _SettingsContent(state: state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  final SettingsLoaded state;

  const _SettingsContent({required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // Appearance Section
        _SectionHeader(title: 'Appearance'),
        _ThemeTile(currentTheme: state.themeMode),
        const Divider(),

        // Currency Section
        _SectionHeader(title: 'Currency'),
        _CurrencyTile(currentCurrency: state.currency),
        const Divider(),

        // Account Section
        _SectionHeader(title: 'Account'),
        const _ProfileTile(),
        const Divider(),

        // About Section
        _SectionHeader(title: 'About'),
        const ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('Version'),
          subtitle: Text('1.0.0'),
        ),
        const ListTile(
          leading: Icon(Icons.code),
          title: Text('CryptoFlow'),
          subtitle: Text('Real-time cryptocurrency tracker'),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final ThemeMode currentTheme;

  const _ThemeTile({required this.currentTheme});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        currentTheme == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
      ),
      title: const Text('Theme'),
      subtitle: Text(_getThemeLabel(currentTheme)),
      trailing: SegmentedButton<ThemeMode>(
        segments: const [
          ButtonSegment(
            value: ThemeMode.light,
            icon: Icon(Icons.light_mode),
          ),
          ButtonSegment(
            value: ThemeMode.system,
            icon: Icon(Icons.settings_suggest),
          ),
          ButtonSegment(
            value: ThemeMode.dark,
            icon: Icon(Icons.dark_mode),
          ),
        ],
        selected: {currentTheme},
        onSelectionChanged: (selected) {
          context.read<SettingsBloc>().add(UpdateThemeEvent(selected.first));
        },
      ),
    );
  }

  String _getThemeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
}

class _CurrencyTile extends StatelessWidget {
  final String currentCurrency;

  const _CurrencyTile({required this.currentCurrency});

  static const currencies = ['USD', 'EUR', 'GBP', 'BTC', 'ETH'];

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.attach_money),
      title: const Text('Display Currency'),
      subtitle: Text(currentCurrency),
      trailing: DropdownButton<String>(
        value: currentCurrency,
        underline: const SizedBox.shrink(),
        items: currencies
            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
            .toList(),
        onChanged: (value) {
          if (value != null) {
            context.read<SettingsBloc>().add(UpdateCurrencyEvent(value));
          }
        },
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.person),
      title: const Text('Profile'),
      subtitle: const Text('Manage your account and data'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.go('/profile'),
    );
  }
}
