import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_settings.dart';
import '../../domain/entities/app_notification.dart';

/// Base class for notification states
abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

/// Loading state
class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

/// Ready state with settings
class NotificationReady extends NotificationState {
  final NotificationSettings settings;
  final List<AppNotification> recentNotifications;

  const NotificationReady({
    required this.settings,
    this.recentNotifications = const [],
  });

  /// Create copy with updated fields
  NotificationReady copyWith({
    NotificationSettings? settings,
    List<AppNotification>? recentNotifications,
  }) {
    return NotificationReady(
      settings: settings ?? this.settings,
      recentNotifications: recentNotifications ?? this.recentNotifications,
    );
  }

  @override
  List<Object?> get props => [settings, recentNotifications];
}

/// Permission denied state
class NotificationPermissionDenied extends NotificationState {
  const NotificationPermissionDenied();
}

/// Error state
class NotificationError extends NotificationState {
  final String message;

  const NotificationError({required this.message});

  @override
  List<Object?> get props => [message];
}
