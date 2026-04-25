import '../../domain/entities/app_notification.dart';

/// Inbound push payload (APNs `aps` dictionary + custom data).
///
/// Keys recognised:
///   * `title`, `body` — under `aps.alert` or top-level fallback
///   * `messageId` — top-level (server-supplied)
///   * `type` — top-level (`priceAlert`, `portfolioChange`, ...)
///   * arbitrary additional keys forwarded as `AppNotification.data`
class PushMessageModel {
  PushMessageModel(this.payload);

  final Map<String, dynamic> payload;

  AppNotification toEntity() {
    final aps = _asMap(payload['aps']);
    final alert = _asMap(aps?['alert']);

    final title = (alert?['title'] ?? payload['title']) as String? ?? 'CryptoFlow';
    final body = (alert?['body'] ?? payload['body']) as String? ?? '';

    final typeString = payload['type'] as String? ?? 'system';
    final type = NotificationTypeX.fromJson(typeString);

    return AppNotification(
      id: (payload['messageId'] as String?) ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      title: title,
      body: body,
      data: Map<String, dynamic>.from(payload),
      receivedAt: DateTime.now(),
      isRead: false,
    );
  }

  Map<String, dynamic>? _asMap(Object? raw) {
    if (raw is Map) {
      return raw.map((k, v) => MapEntry(k.toString(), v));
    }
    return null;
  }
}
