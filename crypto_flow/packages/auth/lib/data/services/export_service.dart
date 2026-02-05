import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Service for exporting user data to JSON files
class ExportService {
  /// Export data to a JSON file and share it
  static Future<bool> exportToJson({
    required String fileName,
    required Map<String, dynamic> data,
    required String title,
  }) async {
    try {
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);

      if (kIsWeb) {
        // Web platform: use Share API or download
        await Share.share(jsonString, subject: title);
        return true;
      }

      // Get the documents directory
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/${fileName}_$timestamp.json');

      // Write the JSON to file
      await file.writeAsString(jsonString);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: title,
      );

      return true;
    } catch (e) {
      debugPrint('Export error: $e');
      return false;
    }
  }

  /// Export portfolio data
  static Future<bool> exportPortfolio({
    required List<Map<String, dynamic>> holdings,
    required List<Map<String, dynamic>> transactions,
  }) async {
    final data = {
      'exportedAt': DateTime.now().toIso8601String(),
      'type': 'portfolio',
      'holdings': holdings,
      'transactions': transactions,
    };

    return exportToJson(
      fileName: 'cryptowave_portfolio',
      data: data,
      title: 'CryptoWave Portfolio Export',
    );
  }

  /// Export alerts data
  static Future<bool> exportAlerts({
    required List<Map<String, dynamic>> alerts,
  }) async {
    final data = {
      'exportedAt': DateTime.now().toIso8601String(),
      'type': 'alerts',
      'alerts': alerts,
    };

    return exportToJson(
      fileName: 'cryptowave_alerts',
      data: data,
      title: 'CryptoWave Alerts Export',
    );
  }

  /// Export watchlist data
  static Future<bool> exportWatchlist({
    required List<Map<String, dynamic>> items,
  }) async {
    final data = {
      'exportedAt': DateTime.now().toIso8601String(),
      'type': 'watchlist',
      'items': items,
    };

    return exportToJson(
      fileName: 'cryptowave_watchlist',
      data: data,
      title: 'CryptoWave Watchlist Export',
    );
  }

  /// Export all user data
  static Future<bool> exportAll({
    required List<Map<String, dynamic>> holdings,
    required List<Map<String, dynamic>> transactions,
    required List<Map<String, dynamic>> alerts,
    required List<Map<String, dynamic>> watchlistItems,
  }) async {
    final data = {
      'exportedAt': DateTime.now().toIso8601String(),
      'type': 'full_backup',
      'portfolio': {
        'holdings': holdings,
        'transactions': transactions,
      },
      'alerts': alerts,
      'watchlist': watchlistItems,
    };

    return exportToJson(
      fileName: 'cryptowave_backup',
      data: data,
      title: 'CryptoWave Full Backup',
    );
  }
}
