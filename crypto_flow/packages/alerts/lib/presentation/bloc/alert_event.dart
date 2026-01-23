import 'package:equatable/equatable.dart';
import '../../domain/entities/price_alert.dart';

/// Base class for all alert events
abstract class AlertEvent extends Equatable {
  const AlertEvent();

  @override
  List<Object?> get props => [];
}

/// Load all alerts
class LoadAlerts extends AlertEvent {
  const LoadAlerts();
}

/// Create a new alert
class CreateAlertEvent extends AlertEvent {
  final PriceAlert alert;

  const CreateAlertEvent(this.alert);

  @override
  List<Object?> get props => [alert];
}

/// Delete an alert
class DeleteAlertEvent extends AlertEvent {
  final String id;

  const DeleteAlertEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// Toggle alert active status
class ToggleAlertEvent extends AlertEvent {
  final String id;
  final bool isActive;

  const ToggleAlertEvent(this.id, this.isActive);

  @override
  List<Object?> get props => [id, isActive];
}

/// Check alerts against current prices
class CheckAlertsEvent extends AlertEvent {
  final Map<String, double> currentPrices;

  const CheckAlertsEvent(this.currentPrices);

  @override
  List<Object?> get props => [currentPrices];
}

/// Alerts updated from storage
class AlertsUpdated extends AlertEvent {
  const AlertsUpdated();
}
