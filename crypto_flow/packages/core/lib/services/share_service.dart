import 'dart:ui';
import 'package:share_plus/share_plus.dart';

/// Service for sharing content from the app
class ShareService {
  /// Share a ticker with its current price
  ///
  /// Creates a formatted message with ticker symbol, price, and deep link
  Future<void> shareTicker(String symbol, double price) async {
    final message = '''
🚀 $symbol fiyatı: \$${price.toStringAsFixed(2)}

Details in CryptoWave:
cryptowave://ticker/$symbol

#CryptoWave #Crypto #$symbol
''';

    await Share.share(
      message,
      subject: '$symbol - CryptoWave',
      sharePositionOrigin: const Rect.fromLTWH(100, 100, 100, 100),
    );
  }

  /// Share portfolio summary
  Future<void> sharePortfolio({
    required double totalValue,
    required double profitLoss,
    required double profitLossPercentage,
  }) async {
    final emoji = profitLoss >= 0 ? '📈' : '📉';
    final sign = profitLoss >= 0 ? '+' : '';

    final message = '''
$emoji Portfolyo Özeti

Toplam Değer: \$${totalValue.toStringAsFixed(2)}
Kar/Zarar: $sign\$${profitLoss.toStringAsFixed(2)} ($sign${profitLossPercentage.toStringAsFixed(2)}%)

CryptoWave ile kripto varlıklarımı takip ediyorum!
cryptowave://portfolio

#CryptoWave #Crypto #Portfolio
''';

    await Share.share(
      message,
      subject: 'Portfolyo - CryptoWave',
      sharePositionOrigin: const Rect.fromLTWH(100, 100, 100, 100),
    );
  }

  /// Share a price alert
  Future<void> shareAlert({
    required String symbol,
    required double targetPrice,
    required String condition,
  }) async {
    final conditionText =
        condition == 'above' ? 'üzerine çıktığında' : 'altına düştüğünde';

    final message = '''
🔔 Fiyat Alarmı

$symbol \$${targetPrice.toStringAsFixed(2)} $conditionText bildirim al!

CryptoWave'da alarm kur:
cryptowave://alerts

#CryptoWave #PriceAlert #$symbol
''';

    await Share.share(
      message,
      subject: 'Fiyat Alarmı - CryptoWave',
      sharePositionOrigin: const Rect.fromLTWH(100, 100, 100, 100),
    );
  }
}
