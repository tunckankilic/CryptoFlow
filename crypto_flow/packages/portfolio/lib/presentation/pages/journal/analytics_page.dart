import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:design_system/design_system.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../bloc/journal_stats/journal_stats_bloc.dart';
import '../../bloc/journal_stats/journal_stats_event.dart';
import '../../bloc/journal_stats/journal_stats_state.dart';
import '../../widgets/journal/share_report_bottom_sheet.dart';
import '../../../domain/entities/trade_emotion.dart';
import '../../../domain/entities/stats_period.dart';
import '../../../data/services/pdf_report_service.dart';

/// Analytics dashboard for trading journal
class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  static const String _title = 'Analytics';
  static const String _winRateLabel = 'Win Rate';
  static const String _profitFactorLabel = 'Profit Factor';
  static const String _avgRRLabel = 'Avg R:R';
  static const String _maxDrawdownLabel = 'Max Drawdown';
  static const String _equityCurveTitle = 'Equity Curve';
  static const String _pnlBySymbolTitle = 'P&L by Symbol';
  static const String _emotionAnalysisTitle = 'Emotion Analysis';
  static const String _bestTradeLabel = 'Best Trade';
  static const String _worstTradeLabel = 'Worst Trade';
  static const String _noDataLabel = 'No data available';

  int? _selectedPeriodDays;

  final Map<String, int?> _periodOptions = {
    '1W': 7,
    '1M': 30,
    '3M': 90,
    '6M': 180,
    'All': null,
  };

  /// Map days to StatsPeriod enum
  StatsPeriod _mapDaysToPeriod(int? days) {
    if (days == null) {
      return StatsPeriod.allTime;
    } else if (days <= 7) {
      return StatsPeriod.weekly;
    } else {
      return StatsPeriod.monthly;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JournalStatsBloc, JournalStatsState>(
      listener: (context, state) {
        if (state is JournalReportGenerated) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Report generated successfully!'),
              backgroundColor: CryptoColors.success,
            ),
          );
          // Show share bottom sheet
          ShareReportBottomSheet.show(
            context: context,
            pdfBytes: state.pdfBytes,
            pdfReportService: PdfReportService(),
          );
        } else if (state is JournalReportError) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: CryptoColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(_title),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: _buildPeriodSelector(),
          ),
        ),
        body: BlocBuilder<JournalStatsBloc, JournalStatsState>(
          builder: (context, state) {
            // Show loading during report generation
            if (state is JournalReportGenerating) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: AppSpacing.md),
                    Text('Generating PDF report...'),
                  ],
                ),
              );
            }

            if (state is JournalStatsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is JournalStatsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: CryptoColors.error,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      state.message,
                      style: AppTypography.body1,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            if (state is JournalStatsLoaded) {
              return ListView(
                padding: AppSpacing.paddingMD,
                children: [
                  // Stats Cards Row
                  _buildStatsCards(state),
                  const SizedBox(height: AppSpacing.lg),

                  // Equity Curve
                  if (state.equityCurve.isNotEmpty) ...[
                    _buildSectionTitle(_equityCurveTitle),
                    const SizedBox(height: AppSpacing.md),
                    _buildEquityCurve(state.equityCurve),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // P&L by Symbol
                  if (state.symbolPnl.isNotEmpty) ...[
                    _buildSectionTitle(_pnlBySymbolTitle),
                    const SizedBox(height: AppSpacing.md),
                    _buildPnlBySymbol(state.symbolPnl),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // Emotion Analysis
                  if (state.emotionPnl.isNotEmpty) ...[
                    _buildSectionTitle(_emotionAnalysisTitle),
                    const SizedBox(height: AppSpacing.md),
                    _buildEmotionPieChart(state.emotionPnl),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ],
              );
            }

            return const Center(child: Text(_noDataLabel));
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            // Trigger PDF generation with current period
            final period = _mapDaysToPeriod(_selectedPeriodDays);
            context
                .read<JournalStatsBloc>()
                .add(JournalReportRequested(period));
          },
          icon: const Icon(Icons.file_download),
          label: const Text('Export Report'),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: _periodOptions.entries.map((entry) {
          final isSelected = _selectedPeriodDays == entry.value;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ChoiceChip(
              label: Text(entry.key),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedPeriodDays = entry.value;
                });
                // Trigger stats reload for new period
                context.read<JournalStatsBloc>().add(
                      JournalStatsRequested(_mapDaysToPeriod(entry.value)),
                    );
              },
              selectedColor: CryptoColors.primary.withOpacity(0.2),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatsCards(JournalStatsLoaded state) {
    final stats = state.stats;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: _winRateLabel,
            value: '${stats.winRate.toStringAsFixed(1)}%',
            color:
                stats.winRate >= 50 ? CryptoColors.success : CryptoColors.error,
            icon: Icons.trending_up,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            label: _profitFactorLabel,
            value: stats.profitFactor.toStringAsFixed(2),
            color: stats.profitFactor >= 1
                ? CryptoColors.success
                : CryptoColors.error,
            icon: Icons.account_balance,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            label: _avgRRLabel,
            value: stats.averageRR.toStringAsFixed(2),
            color: CryptoColors.primary,
            icon: Icons.analytics,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            label: _maxDrawdownLabel,
            value: '${state.maxDrawdown.toStringAsFixed(1)}%',
            color: CryptoColors.error,
            icon: Icons.trending_down,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.h5,
    );
  }

  Widget _buildEquityCurve(List<double> equityCurve) {
    if (equityCurve.isEmpty) {
      return const SizedBox();
    }

    final spots = equityCurve
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
        .toList();

    return Card(
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: SizedBox(
          height: 250,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: 100,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: CryptoColors.borderDark,
                    strokeWidth: 1,
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: CryptoColors.borderDark,
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: (spots.length / 5).ceilToDouble(),
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: AppTypography.caption,
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 100,
                    reservedSize: 50,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '\$${value.toInt()}',
                        style: AppTypography.caption,
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: CryptoColors.borderDark),
              ),
              minX: 0,
              maxX: (spots.length - 1).toDouble(),
              minY: spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 50,
              maxY: spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 50,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: CryptoColors.primary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: CryptoColors.primary.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPnlBySymbol(Map<String, double> symbolPnl) {
    if (symbolPnl.isEmpty) {
      return const SizedBox();
    }

    // Take top 10 symbols by absolute P&L
    final sortedSymbols = symbolPnl.entries.toList()
      ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));
    final top10 = sortedSymbols.take(10).toList();

    return Card(
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: SizedBox(
          height: 300,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: top10.map((e) => e.value).reduce((a, b) => a > b ? a : b) *
                  1.2,
              minY: top10.map((e) => e.value).reduce((a, b) => a < b ? a : b) *
                  1.2,
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= top10.length) {
                        return const SizedBox();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          top10[index].key,
                          style: AppTypography.caption,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '\$${value.toInt()}',
                        style: AppTypography.caption,
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: CryptoColors.borderDark),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 100,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: CryptoColors.borderDark,
                    strokeWidth: 1,
                  );
                },
              ),
              barGroups: top10.asMap().entries.map((entry) {
                final index = entry.key;
                final symbolEntry = entry.value;
                final isProfit = symbolEntry.value >= 0;

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: symbolEntry.value,
                      color: isProfit
                          ? CryptoColors.priceUp
                          : CryptoColors.priceDown,
                      width: 20,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmotionPieChart(Map<TradeEmotion, double> emotionPnl) {
    if (emotionPnl.isEmpty) {
      return const SizedBox();
    }

    final total = emotionPnl.values.reduce((a, b) => a + b);
    final sections = emotionPnl.entries.map((entry) {
      final percentage = (entry.value / total * 100).abs();
      return PieChartSectionData(
        color: _getEmotionColor(entry.key),
        value: percentage,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Card(
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Column(
          children: [
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              children: emotionPnl.entries.map((entry) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _getEmotionColor(entry.key),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      entry.key.displayName,
                      style: AppTypography.caption,
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Color _getEmotionColor(TradeEmotion emotion) {
    switch (emotion) {
      case TradeEmotion.confident:
        return CryptoColors.success;
      case TradeEmotion.neutral:
        return CryptoColors.priceNeutral;
      case TradeEmotion.fearful:
        return CryptoColors.warning;
      case TradeEmotion.greedy:
        return CryptoColors.chartOrange;
      case TradeEmotion.fomo:
        return CryptoColors.error;
      case TradeEmotion.revenge:
        return CryptoColors.chartPurple;
    }
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: AppTypography.h5.copyWith(color: color),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: CryptoColors.textTertiary,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
