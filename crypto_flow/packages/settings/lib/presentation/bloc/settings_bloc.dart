import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/usecases/usecase.dart';
import '../../domain/usecases/get_settings.dart';
import '../../domain/usecases/update_theme.dart';
import '../../domain/usecases/update_currency.dart';
import '../../domain/repositories/settings_repository.dart';
import 'settings_event.dart';
import 'settings_state.dart';

/// BLoC for managing settings state
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetSettings getSettings;
  final UpdateTheme updateTheme;
  final UpdateCurrency updateCurrency;
  final SettingsRepository repository;

  StreamSubscription? _settingsSubscription;

  SettingsBloc({
    required this.getSettings,
    required this.updateTheme,
    required this.updateCurrency,
    required this.repository,
  }) : super(const SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateThemeEvent>(_onUpdateTheme);
    on<UpdateCurrencyEvent>(_onUpdateCurrency);
    on<SettingsUpdated>(_onSettingsUpdated);
  }

  /// Load settings
  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());

    final result = await getSettings(NoParams());

    result.fold(
      (failure) => emit(SettingsError(message: failure.message)),
      (settings) {
        emit(SettingsLoaded(settings: settings));

        // Start watching for updates
        _settingsSubscription?.cancel();
        _settingsSubscription = repository.watchSettings().listen((_) {
          add(const SettingsUpdated());
        });
      },
    );
  }

  /// Update theme
  Future<void> _onUpdateTheme(
    UpdateThemeEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final result = await updateTheme(
      UpdateThemeParams(themeMode: event.themeMode),
    );

    result.fold(
      (failure) => emit(SettingsError(message: failure.message)),
      (_) {
        // Optimistically update the state
        if (state is SettingsLoaded) {
          final current = state as SettingsLoaded;
          emit(current.copyWith(
            settings: current.settings.copyWith(themeMode: event.themeMode),
          ));
        }
      },
    );
  }

  /// Update currency
  Future<void> _onUpdateCurrency(
    UpdateCurrencyEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final result = await updateCurrency(
      UpdateCurrencyParams(currency: event.currency),
    );

    result.fold(
      (failure) => emit(SettingsError(message: failure.message)),
      (_) {
        // Optimistically update the state
        if (state is SettingsLoaded) {
          final current = state as SettingsLoaded;
          emit(current.copyWith(
            settings: current.settings.copyWith(currency: event.currency),
          ));
        }
      },
    );
  }

  /// Handle settings updated from storage
  Future<void> _onSettingsUpdated(
    SettingsUpdated event,
    Emitter<SettingsState> emit,
  ) async {
    final result = await getSettings(NoParams());

    result.fold(
      (failure) => emit(SettingsError(message: failure.message)),
      (settings) => emit(SettingsLoaded(settings: settings)),
    );
  }

  @override
  Future<void> close() {
    _settingsSubscription?.cancel();
    return super.close();
  }
}
