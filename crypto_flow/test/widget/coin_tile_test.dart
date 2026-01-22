import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:design_system/design_system.dart';

void main() {
  group('CoinTile', () {
    // Helper to wrap CoinTile with proper constraints to avoid overflow
    Widget buildTestWidget({
      required String symbol,
      required String name,
      required double price,
      required double percentChange24h,
      String? iconUrl,
      List<double>? sparklineData,
      VoidCallback? onTap,
      VoidCallback? onLongPress,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 80, // Provide enough height for the CoinTile
            child: CoinTile(
              symbol: symbol,
              name: name,
              price: price,
              percentChange24h: percentChange24h,
              iconUrl: iconUrl,
              sparklineData: sparklineData,
              onTap: onTap,
              onLongPress: onLongPress,
            ),
          ),
        ),
      );
    }

    testWidgets('displays symbol correctly', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        symbol: 'BTC',
        name: 'Bitcoin',
        price: 69000.0,
        percentChange24h: 2.5,
      ));

      expect(find.text('BTC'), findsOneWidget);
    });

    testWidgets('displays name correctly', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        symbol: 'ETH',
        name: 'Ethereum',
        price: 2500.0,
        percentChange24h: 4.0,
      ));

      expect(find.text('Ethereum'), findsOneWidget);
    });

    testWidgets('displays price', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        symbol: 'BTC',
        name: 'Bitcoin',
        price: 69000.0,
        percentChange24h: 1.5,
      ));

      // PriceText widget should be present
      expect(find.byType(PriceText), findsOneWidget);
    });

    testWidgets('displays percent change', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        symbol: 'BTC',
        name: 'Bitcoin',
        price: 69000.0,
        percentChange24h: 2.5,
      ));

      // PercentChange widget should be present
      expect(find.byType(PercentChange), findsOneWidget);
    });

    testWidgets('triggers onTap callback when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(buildTestWidget(
        symbol: 'BTC',
        name: 'Bitcoin',
        price: 69000.0,
        percentChange24h: 2.5,
        onTap: () => tapped = true,
      ));

      await tester.tap(find.byType(CoinTile));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('triggers onLongPress callback when long pressed',
        (tester) async {
      bool longPressed = false;

      await tester.pumpWidget(buildTestWidget(
        symbol: 'BTC',
        name: 'Bitcoin',
        price: 69000.0,
        percentChange24h: 2.5,
        onLongPress: () => longPressed = true,
      ));

      await tester.longPress(find.byType(CoinTile));
      await tester.pump();

      expect(longPressed, isTrue);
    });

    testWidgets('displays sparkline when data is provided', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        symbol: 'BTC',
        name: 'Bitcoin',
        price: 69000.0,
        percentChange24h: 2.5,
        sparklineData: [65000, 66000, 67000, 68000, 69000],
      ));

      expect(find.byType(Sparkline), findsOneWidget);
    });

    testWidgets('does not display sparkline when data is null', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        symbol: 'BTC',
        name: 'Bitcoin',
        price: 69000.0,
        percentChange24h: 2.5,
        sparklineData: null,
      ));

      expect(find.byType(Sparkline), findsNothing);
    });

    testWidgets('shows placeholder icon when iconUrl is null', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        symbol: 'BTC',
        name: 'Bitcoin',
        price: 69000.0,
        percentChange24h: 2.5,
        iconUrl: null,
      ));

      // Should show first letter of symbol as placeholder
      expect(find.text('B'), findsOneWidget);
    });
  });
}
