import 'package:flutter/material.dart';
import '../../domain/services/biometric_service.dart';

/// Lock screen shown when biometric authentication is required
class LockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;
  final Widget child;

  const LockScreen({
    super.key,
    required this.onUnlocked,
    required this.child,
  });

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final BiometricService _biometricService = BiometricService();
  bool _isLocked = true;

  @override
  void initState() {
    super.initState();
    // Auto-trigger biometric prompt
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticate();
    });
  }

  Future<void> _authenticate() async {
    final result = await _biometricService.authenticate(
      reason: 'CryptoWave\'a erişmek için doğrulayın',
    );

    if (result == BiometricResult.success) {
      setState(() => _isLocked = false);
      widget.onUnlocked();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLocked) {
      return widget.child;
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    size: 48,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  'CryptoWave Kilitli',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Devam etmek için kimliğinizi doğrulayın',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Biometric button
                FutureBuilder<List>(
                  future: _biometricService.getAvailableTypes(),
                  builder: (context, snapshot) {
                    final types = snapshot.data ?? [];
                    return _buildBiometricButton(types, colorScheme);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricButton(List types, ColorScheme colorScheme) {
    return ElevatedButton.icon(
      onPressed: _authenticate,
      icon: Icon(_biometricService.getIcon(types.cast())),
      label: Text(_biometricService.getLabel(types.cast())),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(200, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
