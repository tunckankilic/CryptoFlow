import 'dart:convert';
import 'dart:developer' show log;

import 'package:home_widget/home_widget.dart';

/// Keys used for sharing data between Flutter and iOS WidgetKit extension.
///
/// Both sides must agree on these keys. The iOS widget reads from
/// `UserDefaults(suiteName: appGroupId)` using the same keys.
class WidgetDataKeys {
  WidgetDataKeys._();

  // Ticker
  static const tickerData = 'ticker_data';

  // Portfolio
  static const portfolioTotalValue = 'portfolio_total_value';
  static const portfolioPnl = 'portfolio_pnl';
  static const portfolioPnlPercentage = 'portfolio_pnl_percentage';
  static const portfolioHoldings = 'portfolio_holdings';

  // Alerts
  static const alertsData = 'alerts_data';
  static const alertsActiveCount = 'alerts_active_count';
  static const alertsTriggeredCount = 'alerts_triggered_count';

  // Fear & Greed
  static const fearGreedValue = 'fear_greed_value';
  static const fearGreedLabel = 'fear_greed_label';
  static const fearGreedTimestamp = 'fear_greed_timestamp';

  // Meta
  static const lastUpdated = 'last_updated';
}

/// Widget kind identifiers matching the iOS WidgetKit `kind` strings.
class WidgetKind {
  WidgetKind._();

  static const cryptoTicker = 'CryptoTickerWidget';
  static const portfolio = 'PortfolioWidget';
  static const alert = 'AlertWidget';
  static const fearGreed = 'FearGreedWidget';
}

/// Bridge between Flutter and iOS WidgetKit.
///
/// Uses `home_widget` to write data into the shared App Group container
/// (`UserDefaults`) and request timeline reloads for the widget extension.
class WidgetDataService {
  static const String _appGroupId = 'group.site.tunckankilic.cryptoFlow';

  /// Must be called once at app startup.
  Future<void> initialize() async {
    await HomeWidget.setAppGroupId(_appGroupId);
  }

  // ---------------------------------------------------------------- Ticker

  /// Push a list of ticker snapshots to the widget.
  ///
  /// Each item: `{ symbol, price, change24h, changePercent24h }`
  Future<void> updateTickerData(List<Map<String, dynamic>> tickers) async {
    try {
      await HomeWidget.saveWidgetData<String>(
        WidgetDataKeys.tickerData,
        jsonEncode(tickers),
      );
      await HomeWidget.saveWidgetData<String>(
        WidgetDataKeys.lastUpdated,
        DateTime.now().toIso8601String(),
      );
      await HomeWidget.updateWidget(
        iOSName: WidgetKind.cryptoTicker,
        androidName: WidgetKind.cryptoTicker,
      );
    } catch (e) {
      log('WidgetDataService.updateTickerData error: $e');
    }
  }

  // -------------------------------------------------------------- Portfolio

  /// Push portfolio summary to the widget.
  Future<void> updatePortfolioData({
    required double totalValue,
    required double pnl,
    required double pnlPercentage,
    required List<Map<String, dynamic>> topHoldings,
  }) async {
    try {
      await Future.wait([
        HomeWidget.saveWidgetData<double>(
          WidgetDataKeys.portfolioTotalValue,
          totalValue,
        ),
        HomeWidget.saveWidgetData<double>(
          WidgetDataKeys.portfolioPnl,
          pnl,
        ),
        HomeWidget.saveWidgetData<double>(
          WidgetDataKeys.portfolioPnlPercentage,
          pnlPercentage,
        ),
        HomeWidget.saveWidgetData<String>(
          WidgetDataKeys.portfolioHoldings,
          jsonEncode(topHoldings),
        ),
        HomeWidget.saveWidgetData<String>(
          WidgetDataKeys.lastUpdated,
          DateTime.now().toIso8601String(),
        ),
      ]);
      await HomeWidget.updateWidget(
        iOSName: WidgetKind.portfolio,
        androidName: WidgetKind.portfolio,
      );
    } catch (e) {
      log('WidgetDataService.updatePortfolioData error: $e');
    }
  }

  // ---------------------------------------------------------------- Alerts

  /// Push alert summary to the widget.
  Future<void> updateAlertData({
    required int activeCount,
    required int triggeredCount,
    required List<Map<String, dynamic>> recentAlerts,
  }) async {
    try {
      await Future.wait([
        HomeWidget.saveWidgetData<int>(
          WidgetDataKeys.alertsActiveCount,
          activeCount,
        ),
        HomeWidget.saveWidgetData<int>(
          WidgetDataKeys.alertsTriggeredCount,
          triggeredCount,
        ),
        HomeWidget.saveWidgetData<String>(
          WidgetDataKeys.alertsData,
          jsonEncode(recentAlerts),
        ),
        HomeWidget.saveWidgetData<String>(
          WidgetDataKeys.lastUpdated,
          DateTime.now().toIso8601String(),
        ),
      ]);
      await HomeWidget.updateWidget(
        iOSName: WidgetKind.alert,
        androidName: WidgetKind.alert,
      );
    } catch (e) {
      log('WidgetDataService.updateAlertData error: $e');
    }
  }

  // ----------------------------------------------------------- Fear & Greed

  /// Push Fear & Greed Index value to the widget.
  Future<void> updateFearGreedData({
    required int value,
    required String label,
  }) async {
    try {
      await Future.wait([
        HomeWidget.saveWidgetData<int>(
          WidgetDataKeys.fearGreedValue,
          value,
        ),
        HomeWidget.saveWidgetData<String>(
          WidgetDataKeys.fearGreedLabel,
          label,
        ),
        HomeWidget.saveWidgetData<String>(
          WidgetDataKeys.fearGreedTimestamp,
          DateTime.now().toIso8601String(),
        ),
        HomeWidget.saveWidgetData<String>(
          WidgetDataKeys.lastUpdated,
          DateTime.now().toIso8601String(),
        ),
      ]);
      await HomeWidget.updateWidget(
        iOSName: WidgetKind.fearGreed,
        androidName: WidgetKind.fearGreed,
      );
    } catch (e) {
      log('WidgetDataService.updateFearGreedData error: $e');
    }
  }

  /// Reload all widget timelines.
  Future<void> updateAllWidgets() async {
    try {
      await Future.wait([
        HomeWidget.updateWidget(
          iOSName: WidgetKind.cryptoTicker,
          androidName: WidgetKind.cryptoTicker,
        ),
        HomeWidget.updateWidget(
          iOSName: WidgetKind.portfolio,
          androidName: WidgetKind.portfolio,
        ),
        HomeWidget.updateWidget(
          iOSName: WidgetKind.alert,
          androidName: WidgetKind.alert,
        ),
        HomeWidget.updateWidget(
          iOSName: WidgetKind.fearGreed,
          androidName: WidgetKind.fearGreed,
        ),
      ]);
    } catch (e) {
      log('WidgetDataService.updateAllWidgets error: $e');
    }
  }
}
