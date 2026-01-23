import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:design_system/design_system.dart';

/// Pie chart showing asset allocation
class AllocationPieChart extends StatelessWidget {
  final Map<String, double> allocation;

  const AllocationPieChart({
    super.key,
    required this.allocation,
  });

  @override
  Widget build(BuildContext context) {
    if (allocation.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: AppSpacing.paddingLG,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Asset Allocation',
              style: AppTypography.h4,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _buildSections(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    final colors = [
      const Color(0xFF2196F3),
      const Color(0xFF4CAF50),
      const Color(0xFFFF9800),
      const Color(0xFF9C27B0),
      const Color(0xFFE91E63),
      const Color(0xFF00BCD4),
      const Color(0xFFFFEB3B),
      const Color(0xFF795548),
    ];

    int colorIndex = 0;
    return allocation.entries.map((entry) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;

      return PieChartSectionData(
        value: entry.value,
        title: '${entry.value.toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        color: color,
      );
    }).toList();
  }

  Widget _buildLegend() {
    final colors = [
      const Color(0xFF2196F3),
      const Color(0xFF4CAF50),
      const Color(0xFFFF9800),
      const Color(0xFF9C27B0),
      const Color(0xFFE91E63),
      const Color(0xFF00BCD4),
      const Color(0xFFFFEB3B),
      const Color(0xFF795548),
    ];

    int colorIndex = 0;
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: allocation.entries.map((entry) {
        final color = colors[colorIndex % colors.length];
        colorIndex++;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              entry.key,
              style: AppTypography.caption,
            ),
            const SizedBox(width: 4),
            Text(
              '(${entry.value.toStringAsFixed(1)}%)',
              style: AppTypography.caption.copyWith(
                color: CryptoColors.textSecondary,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
