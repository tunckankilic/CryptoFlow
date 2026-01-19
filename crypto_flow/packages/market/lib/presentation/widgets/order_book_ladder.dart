import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../../domain/entities/order_book.dart';

/// Order book ladder visualization
class OrderBookLadder extends StatelessWidget {
  final OrderBook orderBook;
  final int maxRows;

  const OrderBookLadder({
    super.key,
    required this.orderBook,
    this.maxRows = 15,
  });

  @override
  Widget build(BuildContext context) {
    final bids = orderBook.bids.take(maxRows).toList();
    final asks = orderBook.asks.take(maxRows).toList();

    // Calculate max quantity for scaling
    final maxBidQty = bids.isEmpty
        ? 1.0
        : bids.map((e) => e.quantity).reduce((a, b) => a > b ? a : b);
    final maxAskQty = asks.isEmpty
        ? 1.0
        : asks.map((e) => e.quantity).reduce((a, b) => a > b ? a : b);
    final maxQty = maxBidQty > maxAskQty ? maxBidQty : maxAskQty;

    return Column(
      children: [
        // Header
        _Header(
            spread: orderBook.spread, spreadPercent: orderBook.spreadPercent),

        // Column headers
        const _ColumnHeaders(),

        // Order book rows
        Expanded(
          child: Row(
            children: [
              // Bids (left side)
              Expanded(
                child: ListView.builder(
                  itemCount: bids.length,
                  itemBuilder: (context, index) {
                    final bid = bids[index];
                    return _OrderRow(
                      price: bid.price,
                      quantity: bid.quantity,
                      total: bid.total,
                      fillRatio: bid.quantity / maxQty,
                      isBid: true,
                    );
                  },
                ),
              ),

              // Divider
              Container(
                width: 1,
                color: Theme.of(context).dividerColor,
              ),

              // Asks (right side)
              Expanded(
                child: ListView.builder(
                  itemCount: asks.length,
                  itemBuilder: (context, index) {
                    final ask = asks[index];
                    return _OrderRow(
                      price: ask.price,
                      quantity: ask.quantity,
                      total: ask.total,
                      fillRatio: ask.quantity / maxQty,
                      isBid: false,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final double spread;
  final double spreadPercent;

  const _Header({required this.spread, required this.spreadPercent});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Spread: ${spread.toStringAsFixed(2)} (${spreadPercent.toStringAsFixed(3)}%)',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _ColumnHeaders extends StatelessWidget {
  const _ColumnHeaders();

  @override
  Widget build(BuildContext context) {
    final headerStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.bold,
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        children: [
          // Bid side
          Expanded(
            child: Row(
              children: [
                Expanded(
                    child: Text('Total',
                        style: headerStyle, textAlign: TextAlign.left)),
                Expanded(
                    child: Text('Size',
                        style: headerStyle, textAlign: TextAlign.center)),
                Expanded(
                    child: Text('Bid',
                        style: headerStyle, textAlign: TextAlign.right)),
              ],
            ),
          ),
          const SizedBox(width: 4),
          // Ask side
          Expanded(
            child: Row(
              children: [
                Expanded(
                    child: Text('Ask',
                        style: headerStyle, textAlign: TextAlign.left)),
                Expanded(
                    child: Text('Size',
                        style: headerStyle, textAlign: TextAlign.center)),
                Expanded(
                    child: Text('Total',
                        style: headerStyle, textAlign: TextAlign.right)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  final double price;
  final double quantity;
  final double total;
  final double fillRatio;
  final bool isBid;

  const _OrderRow({
    required this.price,
    required this.quantity,
    required this.total,
    required this.fillRatio,
    required this.isBid,
  });

  @override
  Widget build(BuildContext context) {
    final color = isBid ? CryptoColors.priceUp : CryptoColors.priceDown;
    final fillColor = color.withAlpha(51); // 0.2 opacity

    return Container(
      height: 28,
      child: Stack(
        children: [
          // Fill bar
          Positioned.fill(
            child: Row(
              children: [
                if (isBid)
                  Spacer(flex: (100 * (1 - fillRatio)).round().clamp(1, 100)),
                Expanded(
                  flex: (100 * fillRatio).round().clamp(1, 100),
                  child: Container(color: fillColor),
                ),
                if (!isBid)
                  Spacer(flex: (100 * (1 - fillRatio)).round().clamp(1, 100)),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: isBid
                  ? [
                      Expanded(
                        child: Text(
                          _formatNumber(total),
                          style: const TextStyle(fontSize: 11),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _formatNumber(quantity),
                          style: const TextStyle(fontSize: 11),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _formatPrice(price),
                          style: TextStyle(
                              fontSize: 11,
                              color: color,
                              fontWeight: FontWeight.w500),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ]
                  : [
                      Expanded(
                        child: Text(
                          _formatPrice(price),
                          style: TextStyle(
                              fontSize: 11,
                              color: color,
                              fontWeight: FontWeight.w500),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _formatNumber(quantity),
                          style: const TextStyle(fontSize: 11),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _formatNumber(total),
                          style: const TextStyle(fontSize: 11),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double value) {
    if (value >= 1000) return value.toStringAsFixed(2);
    if (value >= 1) return value.toStringAsFixed(4);
    return value.toStringAsFixed(6);
  }

  String _formatNumber(double value) {
    if (value >= 1e6) return '${(value / 1e6).toStringAsFixed(2)}M';
    if (value >= 1e3) return '${(value / 1e3).toStringAsFixed(2)}K';
    if (value >= 1) return value.toStringAsFixed(2);
    return value.toStringAsFixed(4);
  }
}
