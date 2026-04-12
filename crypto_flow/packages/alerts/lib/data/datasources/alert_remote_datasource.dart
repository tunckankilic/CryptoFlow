import 'package:core/core.dart';

import '../../domain/entities/price_alert.dart';

/// Remote data source for alert operations against the AWS backend.
abstract class AlertRemoteDataSource {
  Future<List<PriceAlert>> getAlerts();
  Future<PriceAlert> createAlert(PriceAlert alert);
  Future<PriceAlert> updateAlert(PriceAlert alert);
  Future<void> deleteAlert(String id);
}

/// Implementation backed by the CryptoFlow REST API.
class AlertRemoteDataSourceImpl implements AlertRemoteDataSource {
  final AwsApiClient _api;
  AlertRemoteDataSourceImpl({required AwsApiClient apiClient})
      : _api = apiClient;

  @override
  Future<List<PriceAlert>> getAlerts() async {
    final response = await _api.get(AwsEndpoints.alerts);
    final list = response.data as List<dynamic>;
    return list
        .map((json) => _alertFromApiJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PriceAlert> createAlert(PriceAlert alert) async {
    final body = _alertToApiJson(alert);
    final response = await _api.post(AwsEndpoints.alerts, data: body);
    return _alertFromApiJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<PriceAlert> updateAlert(PriceAlert alert) async {
    final body = _alertToApiJson(alert);
    final response =
        await _api.put(AwsEndpoints.alert(alert.id), data: body);
    return _alertFromApiJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteAlert(String id) async {
    await _api.delete(AwsEndpoints.alert(id));
  }

  // ---------------------------------------------------------------- Mapping

  /// Map backend JSON to [PriceAlert] domain entity.
  ///
  /// The backend uses `alertId` as the primary key and slightly different
  /// field names (e.g. `percentChange` vs `percentUp/Down`, `status` vs
  /// `isActive`).
  PriceAlert _alertFromApiJson(Map<String, dynamic> json) {
    final alertType = _parseAlertType(json['type'] as String?);
    final status = json['status'] as String? ?? 'active';

    return PriceAlert(
      id: (json['alertId'] ?? json['id'] ?? '') as String,
      symbol: json['symbol'] as String? ?? '',
      type: alertType,
      targetPrice: _toDouble(json['targetPrice'] ?? json['targetValue']),
      percentChange:
          json['percentChange'] != null ? _toDouble(json['percentChange']) : null,
      basePrice:
          json['basePrice'] != null ? _toDouble(json['basePrice']) : null,
      isActive: status == 'active',
      isTriggered: status == 'triggered' || (json['isTriggered'] as bool? ?? false),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      triggeredAt: json['triggerDate'] != null
          ? DateTime.parse(json['triggerDate'] as String)
          : null,
      repeatEnabled: json['repeatEnabled'] as bool? ?? false,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> _alertToApiJson(PriceAlert alert) {
    return {
      'symbol': alert.symbol,
      'type': _alertTypeToApiString(alert.type),
      if (alert.type == AlertType.above || alert.type == AlertType.below)
        'targetPrice': alert.targetPrice,
      if (alert.percentChange != null) 'percentChange': alert.percentChange,
      if (alert.basePrice != null) 'basePrice': alert.basePrice,
      'repeatEnabled': alert.repeatEnabled,
      if (alert.note != null) 'note': alert.note,
      'status': alert.isActive ? 'active' : 'disabled',
    };
  }

  // ---------------------------------------------------------------- Helpers

  static double _toDouble(dynamic v) =>
      v == null ? 0.0 : (v as num).toDouble();

  /// Backend uses `percentUp` / `percentDown` (no underscore), whereas the
  /// local Hive model uses `percent_up` / `percent_down`. Map accordingly.
  static AlertType _parseAlertType(String? s) {
    switch (s) {
      case 'above':
        return AlertType.above;
      case 'below':
        return AlertType.below;
      case 'percentUp':
      case 'percent_up':
        return AlertType.percentUp;
      case 'percentDown':
      case 'percent_down':
        return AlertType.percentDown;
      default:
        return AlertType.above;
    }
  }

  static String _alertTypeToApiString(AlertType type) {
    switch (type) {
      case AlertType.above:
        return 'above';
      case AlertType.below:
        return 'below';
      case AlertType.percentUp:
        return 'percentUp';
      case AlertType.percentDown:
        return 'percentDown';
    }
  }
}
