import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/biometric/biometric_bloc.dart';
import '../bloc/biometric/biometric_event.dart';
import '../bloc/biometric/biometric_state.dart';
import '../../domain/services/biometric_service.dart';

/// Settings tile for enabling/disabling biometric authentication
class BiometricSettingTile extends StatefulWidget {
  const BiometricSettingTile({super.key});

  @override
  State<BiometricSettingTile> createState() => _BiometricSettingTileState();
}

class _BiometricSettingTileState extends State<BiometricSettingTile> {
  final BiometricService _biometricService = BiometricService();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BiometricBloc, BiometricState>(
      builder: (context, state) {
        if (state is BiometricNotAvailable) {
          return const SizedBox.shrink();
        }

        final isAvailable = state is BiometricAvailable;
        final isEnabled = isAvailable ? (state).isEnabled : false;
        final types = isAvailable ? (state).types : [];

        return FutureBuilder<List>(
          future: _biometricService.getAvailableTypes(),
          builder: (context, snapshot) {
            final biometricTypes = snapshot.data ?? types;

            return ListTile(
              leading: Icon(
                _biometricService.getIcon(biometricTypes.cast()),
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                _biometricService.getLabel(biometricTypes.cast()),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              subtitle: Text(
                isEnabled
                    ? 'Uygulama açılışında doğrulama gerekli'
                    : 'Hızlı ve güvenli giriş için etkinleştirin',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
              ),
              trailing: Switch.adaptive(
                value: isEnabled,
                onChanged: isAvailable
                    ? (value) {
                        if (value) {
                          context
                              .read<BiometricBloc>()
                              .add(const EnableBiometric());
                        } else {
                          context
                              .read<BiometricBloc>()
                              .add(const DisableBiometric());
                        }
                      }
                    : null,
              ),
            );
          },
        );
      },
    );
  }
}
