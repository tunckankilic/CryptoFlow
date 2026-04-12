import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../../../domain/entities/risk_metrics.dart';

class CorrelationHeatmap extends StatelessWidget {
  final CorrelationMatrix matrix;

  const CorrelationHeatmap({super.key, required this.matrix});

  Color _correlationColor(double value) {
    if (value >= 0.7) return CryptoColors.success;
    if (value >= 0.3) return CryptoColors.success.withValues(alpha: 0.5);
    if (value >= -0.3) return Colors.grey;
    if (value >= -0.7) return CryptoColors.error.withValues(alpha: 0.5);
    return CryptoColors.error;
  }

  @override
  Widget build(BuildContext context) {
    if (matrix.symbols.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: Text(
              'Add USDT pairs to portfolio to see correlation',
              style: TextStyle(color: CryptoColors.textTertiary),
            ),
          ),
        ),
      );
    }

    final size = matrix.symbols.length;
    final cellSize = 48.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Correlation Matrix', style: AppTypography.h5),
            const SizedBox(height: AppSpacing.sm),
            Text('Period: ${matrix.period}',
                style: const TextStyle(color: CryptoColors.textTertiary, fontSize: 12)),
            const SizedBox(height: AppSpacing.md),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    children: [
                      SizedBox(width: cellSize),
                      ...matrix.symbols.map((s) => SizedBox(
                            width: cellSize,
                            child: Center(
                              child: Text(s, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          )),
                    ],
                  ),
                  // Matrix rows
                  ...List.generate(size, (i) {
                    return Row(
                      children: [
                        SizedBox(
                          width: cellSize,
                          child: Text(matrix.symbols[i],
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        ...List.generate(size, (j) {
                          final val = matrix.matrix[i][j];
                          return Container(
                            width: cellSize,
                            height: cellSize,
                            margin: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: _correlationColor(val),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(
                                val.toStringAsFixed(2),
                                style: const TextStyle(fontSize: 10, color: Colors.white),
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendItem(color: CryptoColors.error, label: '-1.0'),
                _LegendItem(color: Colors.grey, label: '0.0'),
                _LegendItem(color: CryptoColors.success, label: '+1.0'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(width: 12, height: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}
