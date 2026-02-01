import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/settings.dart';
import '../../../domain/services/biometric_service.dart';
import 'biometric_event.dart';
import 'biometric_state.dart';

/// BLoC for managing biometric authentication state
class BiometricBloc extends Bloc<BiometricEvent, BiometricState> {
  final BiometricService _biometricService;
  final SettingsRepository _settingsRepository;

  BiometricBloc({
    required BiometricService biometricService,
    required SettingsRepository settingsRepository,
  })  : _biometricService = biometricService,
        _settingsRepository = settingsRepository,
        super(const BiometricInitial()) {
    on<CheckBiometricAvailability>(_onCheck);
    on<AuthenticateWithBiometric>(_onAuthenticate);
    on<EnableBiometric>(_onEnable);
    on<DisableBiometric>(_onDisable);
    on<ResetBiometricState>(_onReset);
  }

  Future<void> _onCheck(
    CheckBiometricAvailability event,
    Emitter<BiometricState> emit,
  ) async {
    emit(const BiometricChecking());

    final isAvailable = await _biometricService.isAvailable();
    if (!isAvailable) {
      emit(const BiometricNotAvailable());
      return;
    }

    final types = await _biometricService.getAvailableTypes();
    final settingsResult = await _settingsRepository.getSettings();

    final isEnabled = settingsResult.fold(
      (failure) => false,
      (settings) => settings.biometricEnabled,
    );

    emit(BiometricAvailable(types: types, isEnabled: isEnabled));
  }

  Future<void> _onAuthenticate(
    AuthenticateWithBiometric event,
    Emitter<BiometricState> emit,
  ) async {
    final result = await _biometricService.authenticate(reason: event.reason);

    switch (result) {
      case BiometricResult.success:
        emit(const BiometricAuthenticated());
        break;
      case BiometricResult.lockedOut:
        emit(const BiometricLockedOut(permanent: false));
        break;
      case BiometricResult.permanentlyLocked:
        emit(const BiometricLockedOut(permanent: true));
        break;
      case BiometricResult.notAvailable:
      case BiometricResult.notEnrolled:
        emit(const BiometricNotAvailable());
        break;
      default:
        emit(const BiometricFailed(message: 'Doğrulama başarısız'));
    }
  }

  Future<void> _onEnable(
    EnableBiometric event,
    Emitter<BiometricState> emit,
  ) async {
    // First authenticate to confirm user identity
    final result = await _biometricService.authenticate(
      reason: 'Biometric login\'i aktifleştirmek için doğrulayın',
    );

    if (result == BiometricResult.success) {
      await _settingsRepository.updateBiometricEnabled(true);
      add(const CheckBiometricAvailability());
    } else {
      emit(const BiometricFailed(message: 'Doğrulama başarısız'));
    }
  }

  Future<void> _onDisable(
    DisableBiometric event,
    Emitter<BiometricState> emit,
  ) async {
    await _settingsRepository.updateBiometricEnabled(false);
    add(const CheckBiometricAvailability());
  }

  void _onReset(
    ResetBiometricState event,
    Emitter<BiometricState> emit,
  ) {
    add(const CheckBiometricAvailability());
  }
}
