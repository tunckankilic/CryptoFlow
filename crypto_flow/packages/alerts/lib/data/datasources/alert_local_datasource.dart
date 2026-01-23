import 'dart:async';
import 'package:core/error/exceptions.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/price_alert.dart';
import '../models/price_alert_model.dart';

/// Local data source for alerts using Hive
class AlertLocalDataSource {
  static const String _boxName = 'alerts';
  Box<PriceAlertModel>? _alertsBox;

  /// Initialize Hive and open box
  Future<void> init() async {
    if (_alertsBox == null || !_alertsBox!.isOpen) {
      _alertsBox = await Hive.openBox<PriceAlertModel>(_boxName);
    }
  }

  /// Get all alerts
  Future<List<PriceAlert>> getAlerts() async {
    try {
      await init();
      return _alertsBox!.values.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw CacheException(message: 'Failed to get alerts: $e');
    }
  }

  /// Create a new alert
  Future<PriceAlert> createAlert(PriceAlert alert) async {
    try {
      await init();
      final model = PriceAlertModel.fromEntity(alert);
      await _alertsBox!.put(alert.id, model);
      return model.toEntity();
    } catch (e) {
      throw CacheException(message: 'Failed to create alert: $e');
    }
  }

  /// Delete an alert by ID
  Future<void> deleteAlert(String id) async {
    try {
      await init();
      if (!_alertsBox!.containsKey(id)) {
        throw CacheException(message: 'Alert not found: $id');
      }
      await _alertsBox!.delete(id);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Failed to delete alert: $e');
    }
  }

  /// Toggle alert active status
  Future<void> toggleAlert(String id, bool isActive) async {
    try {
      await init();
      final model = _alertsBox!.get(id);
      if (model == null) {
        throw CacheException(message: 'Alert not found: $id');
      }

      final updated = PriceAlertModel.fromEntity(
        model.toEntity().copyWith(isActive: isActive),
      );
      await _alertsBox!.put(id, updated);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Failed to toggle alert: $e');
    }
  }

  /// Update an alert
  Future<PriceAlert> updateAlert(PriceAlert alert) async {
    try {
      await init();
      if (!_alertsBox!.containsKey(alert.id)) {
        throw CacheException(message: 'Alert not found: ${alert.id}');
      }

      final model = PriceAlertModel.fromEntity(alert);
      await _alertsBox!.put(alert.id, model);
      return model.toEntity();
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Failed to update alert: $e');
    }
  }

  /// Check alerts against current prices and trigger if needed
  Future<List<PriceAlert>> checkAlerts(
      Map<String, double> currentPrices) async {
    try {
      await init();
      final triggeredAlerts = <PriceAlert>[];

      for (final model in _alertsBox!.values) {
        final alert = model.toEntity();
        final currentPrice = currentPrices[alert.symbol];

        if (currentPrice != null && alert.shouldTrigger(currentPrice)) {
          // Trigger the alert
          final triggered = alert.trigger();
          final triggeredModel = PriceAlertModel.fromEntity(triggered);
          await _alertsBox!.put(alert.id, triggeredModel);
          triggeredAlerts.add(triggered);
        }
      }

      return triggeredAlerts;
    } catch (e) {
      throw CacheException(message: 'Failed to check alerts: $e');
    }
  }

  /// Watch alerts for real-time updates
  Stream<List<PriceAlert>> watchAlerts() {
    try {
      return _alertsBox!.watch().map((_) {
        return _alertsBox!.values.map((model) => model.toEntity()).toList();
      });
    } catch (e) {
      throw CacheException(message: 'Failed to watch alerts: $e');
    }
  }

  /// Close the box
  Future<void> close() async {
    await _alertsBox?.close();
  }
}
