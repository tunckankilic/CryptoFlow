import 'package:equatable/equatable.dart';
import '../../domain/entities/price_alert.dart';

/// Base class for all alert states
abstract class AlertState extends Equatable {
  const AlertState();

  @override
  List<Object?> get props => [];
}

/// Initial state before loading
class AlertInitial extends AlertState {
  const AlertInitial();
}

/// Loading alerts
class AlertLoading extends AlertState {
  const AlertLoading();
}

/// Alerts loaded successfully
class AlertLoaded extends AlertState {
  final List<PriceAlert> alerts;
  final List<PriceAlert> activeAlerts;
  final List<PriceAlert> triggeredAlerts;

  const AlertLoaded({
    required this.alerts,
    required this.activeAlerts,
    required this.triggeredAlerts,
  });

  AlertLoaded copyWith({
    List<PriceAlert>? alerts,
    List<PriceAlert>? activeAlerts,
    List<PriceAlert>? triggeredAlerts,
  }) {
    return AlertLoaded(
      alerts: alerts ?? this.alerts,
      activeAlerts: activeAlerts ?? this.activeAlerts,
      triggeredAlerts: triggeredAlerts ?? this.triggeredAlerts,
    );
  }

  @override
  List<Object?> get props => [alerts, activeAlerts, triggeredAlerts];
}

/// Error loading or managing alerts
class AlertError extends AlertState {
  final String message;

  const AlertError({required this.message});

  @override
  List<Object?> get props => [message];
}
