import 'dart:async';
import 'package:alerts/domain/entities/price_alert.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_alerts.dart';
import '../../domain/usecases/create_alert.dart';
import '../../domain/usecases/delete_alert.dart';
import '../../domain/usecases/toggle_alert.dart';
import '../../domain/usecases/check_alerts.dart';
import '../../domain/repositories/alert_repository.dart';
import 'package:core/usecases/usecase.dart';
import 'alert_event.dart';
import 'alert_state.dart';

/// BLoC for managing alert state
class AlertBloc extends Bloc<AlertEvent, AlertState> {
  final GetAlerts getAlerts;
  final CreateAlert createAlert;
  final DeleteAlert deleteAlert;
  final ToggleAlert toggleAlert;
  final CheckAlerts checkAlerts;
  final AlertRepository repository;

  StreamSubscription? _alertsSubscription;

  AlertBloc({
    required this.getAlerts,
    required this.createAlert,
    required this.deleteAlert,
    required this.toggleAlert,
    required this.checkAlerts,
    required this.repository,
  }) : super(const AlertInitial()) {
    on<LoadAlerts>(_onLoadAlerts);
    on<CreateAlertEvent>(_onCreateAlert);
    on<DeleteAlertEvent>(_onDeleteAlert);
    on<ToggleAlertEvent>(_onToggleAlert);
    on<CheckAlertsEvent>(_onCheckAlerts);
    on<AlertsUpdated>(_onAlertsUpdated);
  }

  /// Load all alerts
  Future<void> _onLoadAlerts(
    LoadAlerts event,
    Emitter<AlertState> emit,
  ) async {
    emit(const AlertLoading());

    final result = await getAlerts(NoParams());

    result.fold(
      (failure) => emit(AlertError(message: failure.message)),
      (alerts) {
        emit(_buildLoadedState(alerts));

        // Start watching for updates
        _alertsSubscription?.cancel();
        _alertsSubscription = repository.watchAlerts().listen((_) {
          add(const AlertsUpdated());
        });
      },
    );
  }

  /// Create a new alert
  Future<void> _onCreateAlert(
    CreateAlertEvent event,
    Emitter<AlertState> emit,
  ) async {
    final result = await createAlert(CreateAlertParams(alert: event.alert));

    result.fold(
      (failure) => emit(AlertError(message: failure.message)),
      (_) {
        // Reload alerts
        add(const LoadAlerts());
      },
    );
  }

  /// Delete an alert
  Future<void> _onDeleteAlert(
    DeleteAlertEvent event,
    Emitter<AlertState> emit,
  ) async {
    final result = await deleteAlert(DeleteAlertParams(id: event.id));

    result.fold(
      (failure) => emit(AlertError(message: failure.message)),
      (_) {
        // Reload alerts
        add(const LoadAlerts());
      },
    );
  }

  /// Toggle alert active status
  Future<void> _onToggleAlert(
    ToggleAlertEvent event,
    Emitter<AlertState> emit,
  ) async {
    final result = await toggleAlert(
      ToggleAlertParams(id: event.id, isActive: event.isActive),
    );

    result.fold(
      (failure) => emit(AlertError(message: failure.message)),
      (_) {
        // Reload alerts
        add(const LoadAlerts());
      },
    );
  }

  /// Check alerts against current prices
  Future<void> _onCheckAlerts(
    CheckAlertsEvent event,
    Emitter<AlertState> emit,
  ) async {
    final result = await checkAlerts(
      CheckAlertsParams(currentPrices: event.currentPrices),
    );

    result.fold(
      (failure) {
        // Don't emit error for check failures, just log
      },
      (triggeredAlerts) {
        if (triggeredAlerts.isNotEmpty) {
          // Reload to get updated state
          add(const LoadAlerts());
        }
      },
    );
  }

  /// Handle alerts updated from storage
  Future<void> _onAlertsUpdated(
    AlertsUpdated event,
    Emitter<AlertState> emit,
  ) async {
    final result = await getAlerts(NoParams());

    result.fold(
      (failure) => emit(AlertError(message: failure.message)),
      (alerts) => emit(_buildLoadedState(alerts)),
    );
  }

  /// Build loaded state with categorized alerts
  AlertLoaded _buildLoadedState(List<dynamic> alerts) {
    final typedAlerts = alerts.cast<PriceAlert>();
    final activeAlerts =
        typedAlerts.where((a) => a.isActive && !a.isTriggered).toList();
    final triggeredAlerts = typedAlerts.where((a) => a.isTriggered).toList();

    return AlertLoaded(
      alerts: typedAlerts,
      activeAlerts: activeAlerts,
      triggeredAlerts: triggeredAlerts,
    );
  }

  @override
  Future<void> close() {
    _alertsSubscription?.cancel();
    return super.close();
  }
}
