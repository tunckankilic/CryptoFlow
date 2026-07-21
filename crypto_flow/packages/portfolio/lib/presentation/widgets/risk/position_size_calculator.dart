import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../../../domain/entities/risk_metrics.dart';

class PositionSizeCalculator extends StatelessWidget {
  final PositionSizeResult? result;
  final ValueChanged<Map<String, String>> onCalculate;

  const PositionSizeCalculator({
    super.key,
    this.result,
    required this.onCalculate,
  });

  @override
  Widget build(BuildContext context) {
    final symbolController = TextEditingController();
    final accountController = TextEditingController();
    final riskController = TextEditingController(text: '1');
    final entryController = TextEditingController();
    final stopController = TextEditingController();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Position Size Calculator', style: AppTypography.h5),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: symbolController,
                    decoration: const InputDecoration(
                      labelText: 'Symbol',
                      hintText: 'BTCUSDT',
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: accountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Account Size (\$)',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: riskController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Risk %',
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: entryController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Entry Price',
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: stopController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Stop Loss',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  onCalculate({
                    'symbol': symbolController.text,
                    'accountSize': accountController.text,
                    'riskPercentage': riskController.text,
                    'entryPrice': entryController.text,
                    'stopLossPrice': stopController.text,
                  });
                },
                child: const Text('Calculate'),
              ),
            ),
            if (result != null) ...[
              const Divider(height: AppSpacing.xl),
              _ResultRow(
                  label: 'Position Size', value: '${result!.positionSize}'),
              _ResultRow(
                  label: 'Position Value',
                  value: '\$${result!.positionValue.toStringAsFixed(2)}'),
              _ResultRow(
                  label: 'Risk Amount',
                  value: '\$${result!.riskAmount.toStringAsFixed(2)}'),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  const _ResultRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: CryptoColors.textSecondary)),
          Text(value, style: AppTypography.label),
        ],
      ),
    );
  }
}
