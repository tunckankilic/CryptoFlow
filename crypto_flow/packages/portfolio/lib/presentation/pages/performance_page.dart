import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:design_system/design_system.dart';
import '../../domain/entities/performance_metrics.dart';
import '../bloc/performance/performance_bloc.dart';
import '../bloc/performance/performance_event.dart';
import '../bloc/performance/performance_state.dart';
import '../widgets/performance/sharpe_ratio_card.dart';
import '../widgets/performance/drawdown_chart.dart';
import '../widgets/performance/monthly_returns_heatmap.dart';
import '../widgets/performance/benchmark_comparison_chart.dart';

/// Performance analytics dashboard page
class PerformancePage extends StatefulWidget {
  const PerformancePage({super.key});

  @override
  State<PerformancePage> createState() => _PerformancePageState();
}

class _PerformancePageState extends State<PerformancePage> {
  String _selectedPeriod = 'monthly';

  final Map<String, String> _periodOptions = {
    'weekly': '1W',
    'monthly': '1M',
    'quarterly': '3M',
    'yearly': '1Y',
  };

  @override
  void initState() {
    super.initState();
    context.read<PerformanceBloc>().add(PerformanceRequested(_selectedPeriod));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: _buildPeriodSelector(),
        ),
      ),
      body: BlocBuilder<PerformanceBloc, PerformanceState>(
        builder: (context, state) {
          if (state is PerformanceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PerformanceError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 64, color: CryptoColors.error),
                  const SizedBox(height: AppSpacing.md),
                  Text(state.message,
                      style: AppTypography.body1, textAlign: TextAlign.center),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: () => context
                        .read<PerformanceBloc>()
                        .add(PerformanceRequested(_selectedPeriod)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is PerformanceLoaded) {
            final m = state.metrics;
            return ListView(
              padding: AppSpacing.paddingMD,
              children: [
                // Key metrics row
                _buildKeyMetrics(m),
                const SizedBox(height: AppSpacing.lg),

                // Sharpe & Sortino gauges
                Row(
                  children: [
                    Expanded(
                      child: SharpeRatioCard(
                        title: 'Sharpe Ratio',
                        value: m.sharpeRatio,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: SharpeRatioCard(
                        title: 'Sortino Ratio',
                        value: m.sortinoRatio,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Drawdown chart
                DrawdownChart(
                  monthlyReturns: m.monthlyReturns,
                  maxDrawdownPct: m.maxDrawdownPct,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Monthly returns heatmap
                MonthlyReturnsHeatmap(
                  monthlyReturns: m.monthlyReturns,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Benchmark comparison
                BenchmarkComparisonChart(
                  benchmarks: m.benchmarks,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            );
          }

          return const Center(child: Text('Select a period to view analytics'));
        },
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: _periodOptions.entries.map((entry) {
          final isSelected = _selectedPeriod == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ChoiceChip(
              label: Text(entry.value),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedPeriod = entry.key);
                context
                    .read<PerformanceBloc>()
                    .add(PerformanceRequested(entry.key));
              },
              selectedColor: CryptoColors.primary.withValues(alpha: 0.2),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKeyMetrics(PerformanceMetrics metrics) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            label: 'Total Return',
            value:
                '${metrics.totalReturnPct >= 0 ? "+" : ""}${metrics.totalReturnPct.toStringAsFixed(1)}%',
            color: metrics.totalReturnPct >= 0
                ? CryptoColors.success
                : CryptoColors.error,
            icon: Icons.trending_up,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _MetricCard(
            label: 'Win Rate',
            value: '${metrics.winRate.toStringAsFixed(1)}%',
            color: metrics.winRate >= 50
                ? CryptoColors.success
                : CryptoColors.error,
            icon: Icons.emoji_events,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _MetricCard(
            label: 'Profit Factor',
            value: metrics.profitFactor.toStringAsFixed(2),
            color: metrics.profitFactor >= 1
                ? CryptoColors.success
                : CryptoColors.error,
            icon: Icons.account_balance,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.paddingSM,
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: AppSpacing.xs),
            Text(value,
                style: AppTypography.h5.copyWith(color: color),
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Text(label,
                style: AppTypography.caption
                    .copyWith(color: CryptoColors.textTertiary),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
