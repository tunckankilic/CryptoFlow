import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/settings.dart';

/// Settings tile for enabling/disabling lock on background
/// Note: This is a display-only tile. Toggle functionality requires UpdateLockOnBackground event.
class LockOnBackgroundTile extends StatelessWidget {
  const LockOnBackgroundTile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        if (state is SettingsLoaded) {
          // Only show if biometric is enabled
          if (!state.settings.biometricEnabled) {
            return const SizedBox.shrink();
          }

          return ListTile(
            leading: const Icon(Icons.phonelink_lock),
            title: const Text('Lock on Background'),
            subtitle: Text(
              state.settings.lockOnBackground
                  ? 'App locks when returning from background'
                  : 'App stays unlocked on background return',
            ),
            trailing: Icon(
              state.settings.lockOnBackground ? Icons.lock : Icons.lock_open,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
