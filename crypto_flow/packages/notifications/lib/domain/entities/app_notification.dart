import 'package:equatable/equatable.dart';

/// Types of notifications
enum NotificationType {
  priceAlert,
  portfolioChange,
  news,
  marketUpdate,
  system,
}

/// Extension for NotificationType
extension NotificationTypeX on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.priceAlert:
        return 'Price Alert';
      case NotificationType.portfolioChange:
        return 'Portfolio Change';
      case NotificationType.news:
        return 'News';
      case NotificationType.marketUpdate:
        return 'Market Update';
      case NotificationType.system:
        return 'System';
    }
  }

  String toJson() {
    return name;
  }

  static NotificationType fromJson(String json) {
    return NotificationType.values.firstWhere(
      (type) => type.name == json,
      orElse: () => NotificationType.system,
    );
  }
}

/// Represents a notification in the app
class AppNotification extends Equatable {
  /// Unique notification identifier
  final String id;

  /// Type of notification
  final NotificationType type;

  /// Notification title
  final String title;

  /// Notification body text
  final String body;

  /// Additional data payload
  final Map<String, dynamic>? data;

  /// When the notification was received
  final DateTime receivedAt;

  /// Whether the notification has been read
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    required this.receivedAt,
    required this.isRead,
  });

  /// Creates a copy with the given fields replaced
  AppNotification copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    DateTime? receivedAt,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      receivedAt: receivedAt ?? this.receivedAt,
      isRead: isRead ?? this.isRead,
    );
  }

  /// Mark as read
  AppNotification markAsRead() {
    return copyWith(isRead: true);
  }

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        body,
        data,
        receivedAt,
        isRead,
      ];
}
