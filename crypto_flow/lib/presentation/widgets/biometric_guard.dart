import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auth/presentation/pages/lock_screen.dart';
import 'package:settings/settings.dart';

/// Widget that wraps the app and manages biometric lock state
class BiometricGuard extends StatefulWidget {
  final Widget child;

  const BiometricGuard({
    super.key,
    required this.child,
  });

  @override
  State<BiometricGuard> createState() => _BiometricGuardState();
}

class _BiometricGuardState extends State<BiometricGuard>
    with WidgetsBindingObserver {
  bool _isLocked = false;
  bool _wasInBackground = false;
  late SettingsRepository _settingsRepository;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _settingsRepository = context.read<SettingsRepository>();
    _checkInitialLock();
  }

  Future<void> _checkInitialLock() async {
    final result = await _settingsRepository.getSettings();
    result.fold(
      (failure) {},
      (settings) {
        if (settings.biometricEnabled) {
          setState(() => _isLocked = true);
        }
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      _wasInBackground = true;
    }

    if (state == AppLifecycleState.resumed && _wasInBackground) {
      _wasInBackground = false;
      _checkLockOnBackground();
    }
  }

  Future<void> _checkLockOnBackground() async {
    final result = await _settingsRepository.getSettings();
    result.fold(
      (failure) {},
      (settings) {
        if (settings.biometricEnabled && settings.lockOnBackground) {
          setState(() => _isLocked = true);
        }
      },
    );
  }

  void _handleUnlock() {
    setState(() => _isLocked = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLocked) {
      return LockScreen(
        onUnlocked: _handleUnlock,
        child: widget.child,
      );
    }
    return widget.child;
  }
}
