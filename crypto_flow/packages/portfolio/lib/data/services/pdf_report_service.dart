import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:portfolio/domain/entities/trade_side.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/entities/stats_period.dart';
import '../../domain/entities/trading_stats.dart';
import '../../domain/entities/trade_emotion.dart';

/// Service for generating and sharing PDF trading reports
class PdfReportService {
  /// Generates a comprehensive trading report PDF
  Future<Uint8List> generateTradingReport({
    required StatsPeriod period,
    required List<JournalEntry> entries,
    required TradingStats stats,
    required Map<TradeEmotion, double> emotionPnl,
    required Map<String, double> symbolPnl,
    required List<double> equityCurve,
    required double maxDrawdown,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');

    // Calculate emotion and symbol stats
    final emotionStats = _calculateEmotionStats(entries);
    final symbolStats = _calculateSymbolStats(entries);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          _buildHeader(period, dateFormat),
          pw.SizedBox(height: 20),

          // Summary Section
          _buildSummarySection(stats, maxDrawdown),
          pw.SizedBox(height: 20),

          // Equity Curve Chart
          if (equityCurve.isNotEmpty) ...[
            _buildSectionTitle('Equity Curve'),
            pw.SizedBox(height: 10),
            _buildEquityCurveChart(equityCurve),
            pw.SizedBox(height: 20),
          ],

          // Trade Log Table
          if (entries.isNotEmpty) ...[
            _buildSectionTitle('Trade Log'),
            pw.SizedBox(height: 10),
            _buildTradeLogTable(entries, dateFormat),
            pw.SizedBox(height: 20),
          ],

          // Emotion Breakdown
          if (emotionStats.isNotEmpty) ...[
            _buildSectionTitle('Emotion Breakdown'),
            pw.SizedBox(height: 10),
            _buildEmotionBreakdownTable(emotionStats),
            pw.SizedBox(height: 20),
          ],

          // Symbol Breakdown
          if (symbolStats.isNotEmpty) ...[
            _buildSectionTitle('Symbol Breakdown'),
            pw.SizedBox(height: 10),
            _buildSymbolBreakdownTable(symbolStats),
          ],
        ],
        footer: (context) => _buildFooter(context),
      ),
    );

    return pdf.save();
  }

  /// Shares or saves the PDF report
  Future<void> sharePdfReport(Uint8List pdfBytes) async {
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename:
          'cryptowave_trading_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  /// Saves the PDF report to device
  Future<void> savePdfReport(Uint8List pdfBytes) async {
    await Printing.layoutPdf(
      onLayout: (format) async => pdfBytes,
    );
  }

  //  Private Helper Methods

  pw.Widget _buildHeader(StatsPeriod period, DateFormat dateFormat) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'CryptoWave Trading Report',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Period: ${period.displayName}',
          style: const pw.TextStyle(fontSize: 14),
        ),
        pw.Text(
          'Generated: ${dateFormat.format(DateTime.now())}',
          style: pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey700,
          ),
        ),
        pw.Divider(thickness: 2),
      ],
    );
  }

  pw.Widget _buildSummarySection(TradingStats stats, double maxDrawdown) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Summary',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryColumn([
                _SummaryItem('Total Trades', '${stats.totalTrades}'),
                _SummaryItem(
                    'Win Rate', '${stats.winRate.toStringAsFixed(1)}%'),
                _SummaryItem(
                    'Profit Factor', stats.profitFactor.toStringAsFixed(2)),
              ]),
              _buildSummaryColumn([
                _SummaryItem(
                    'Total P&L', '\$${stats.totalPnl.toStringAsFixed(2)}'),
                _SummaryItem('Average R:R', stats.averageRR.toStringAsFixed(2)),
                _SummaryItem(
                    'Max Drawdown', '${maxDrawdown.toStringAsFixed(1)}%'),
              ]),
              _buildSummaryColumn([
                _SummaryItem(
                    'Best Trade', '\$${stats.largestWin.toStringAsFixed(2)}'),
                _SummaryItem(
                    'Worst Trade', '\$${stats.largestLoss.toStringAsFixed(2)}'),
                _SummaryItem(
                    'Wins/Losses', '${stats.winCount}/${stats.lossCount}'),
              ]),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryColumn(List<_SummaryItem> items) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: items
          .map((item) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      item.label,
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      item.value,
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  pw.Widget _buildEquityCurveChart(List<double> equityCurve) {
    return pw.Container(
      height: 200,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Chart(
        grid: pw.CartesianGrid(
          xAxis: pw.FixedAxis.fromStrings(
            List.generate(
              equityCurve.length > 10 ? 10 : equityCurve.length,
              (i) => (i * (equityCurve.length / 10)).round().toString(),
            ),
          ),
          yAxis: pw.FixedAxis(
            [
              equityCurve.reduce((a, b) => a < b ? a : b),
              (equityCurve.reduce((a, b) => a < b ? a : b) +
                      equityCurve.reduce((a, b) => a > b ? a : b)) /
                  2,
              equityCurve.reduce((a, b) => a > b ? a : b),
            ],
            format: (value) => '\$${value.toInt()}',
          ),
        ),
        datasets: [
          pw.LineDataSet(
            legend: 'Equity',
            drawSurface: true,
            isCurved: true,
            color: PdfColors.blue,
            data: List.generate(
              equityCurve.length,
              (i) => pw.LineChartValue(i.toDouble(), equityCurve[i]),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTradeLogTable(
    List<JournalEntry> entries,
    DateFormat dateFormat,
  ) {
    // Take most recent 50 trades to avoid overwhelming the PDF
    final recentEntries = entries.take(50).toList();

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.2),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(0.8),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(1),
        5: const pw.FlexColumnWidth(1),
        6: const pw.FlexColumnWidth(0.8),
        7: const pw.FlexColumnWidth(0.8),
        8: const pw.FlexColumnWidth(1),
      },
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildTableHeader('Date'),
            _buildTableHeader('Symbol'),
            _buildTableHeader('Side'),
            _buildTableHeader('Entry'),
            _buildTableHeader('Exit'),
            _buildTableHeader('P&L'),
            _buildTableHeader('P&L%'),
            _buildTableHeader('R:R'),
            _buildTableHeader('Emotion'),
          ],
        ),
        // Data rows
        ...recentEntries.asMap().entries.map((entry) {
          final index = entry.key;
          final trade = entry.value;
          final isWin = (trade.pnl ?? 0) >= 0;

          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: index % 2 == 0 ? PdfColors.grey100 : PdfColors.white,
            ),
            children: [
              _buildTableCell(dateFormat.format(trade.entryDate)),
              _buildTableCell(trade.symbol),
              _buildTableCell(trade.side.displayName),
              _buildTableCell('\$${trade.entryPrice.toStringAsFixed(2)}'),
              _buildTableCell(
                trade.exitPrice != null
                    ? '\$${trade.exitPrice!.toStringAsFixed(2)}'
                    : '-',
              ),
              _buildTableCell(
                trade.pnl != null ? '\$${trade.pnl!.toStringAsFixed(2)}' : '-',
                color: isWin ? PdfColors.green : PdfColors.red,
              ),
              _buildTableCell(
                trade.pnlPercentage != null
                    ? '${trade.pnlPercentage!.toStringAsFixed(1)}%'
                    : '-',
                color: isWin ? PdfColors.green : PdfColors.red,
              ),
              _buildTableCell(
                trade.riskRewardRatio != null
                    ? trade.riskRewardRatio!.toStringAsFixed(2)
                    : '-',
              ),
              _buildTableCell(trade.emotion.displayName),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _buildEmotionBreakdownTable(
      Map<TradeEmotion, _EmotionStats> stats) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildTableHeader('Emotion'),
            _buildTableHeader('Count'),
            _buildTableHeader('Total P&L'),
            _buildTableHeader('Avg P&L'),
          ],
        ),
        // Data rows
        ...stats.entries.map((entry) {
          final emotion = entry.key;
          final stat = entry.value;
          final avgPnl = stat.count > 0 ? stat.totalPnl / stat.count : 0.0;

          return pw.TableRow(
            children: [
              _buildTableCell(emotion.displayName),
              _buildTableCell('${stat.count}'),
              _buildTableCell(
                '\$${stat.totalPnl.toStringAsFixed(2)}',
                color: stat.totalPnl >= 0 ? PdfColors.green : PdfColors.red,
              ),
              _buildTableCell(
                '\$${avgPnl.toStringAsFixed(2)}',
                color: avgPnl >= 0 ? PdfColors.green : PdfColors.red,
              ),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _buildSymbolBreakdownTable(Map<String, _SymbolStats> stats) {
    // Sort by total P&L descending
    final sortedSymbols = stats.entries.toList()
      ..sort((a, b) => b.value.totalPnl.compareTo(a.value.totalPnl));

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildTableHeader('Symbol'),
            _buildTableHeader('Trades'),
            _buildTableHeader('Win Rate'),
            _buildTableHeader('Total P&L'),
          ],
        ),
        // Data rows
        ...sortedSymbols.take(20).map((entry) {
          final symbol = entry.key;
          final stat = entry.value;
          final winRate =
              stat.totalTrades > 0 ? (stat.wins / stat.totalTrades) * 100 : 0.0;

          return pw.TableRow(
            children: [
              _buildTableCell(symbol),
              _buildTableCell('${stat.totalTrades}'),
              _buildTableCell('${winRate.toStringAsFixed(1)}%'),
              _buildTableCell(
                '\$${stat.totalPnl.toStringAsFixed(2)}',
                color: stat.totalPnl >= 0 ? PdfColors.green : PdfColors.red,
              ),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _buildSectionTitle(String title) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 16,
        fontWeight: pw.FontWeight.bold,
      ),
    );
  }

  pw.Widget _buildTableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildTableCell(String text, {PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          color: color,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 16),
      child: pw.Text(
        'Generated by CryptoWave - Page ${context.pageNumber} of ${context.pagesCount}',
        style: pw.TextStyle(
          fontSize: 10,
          color: PdfColors.grey700,
        ),
      ),
    );
  }

  Map<TradeEmotion, _EmotionStats> _calculateEmotionStats(
    List<JournalEntry> entries,
  ) {
    final stats = <TradeEmotion, _EmotionStats>{};

    for (final entry in entries) {
      if (entry.pnl == null) continue;

      stats.putIfAbsent(
        entry.emotion,
        () => _EmotionStats(count: 0, totalPnl: 0),
      );

      stats[entry.emotion] = _EmotionStats(
        count: stats[entry.emotion]!.count + 1,
        totalPnl: stats[entry.emotion]!.totalPnl + entry.pnl!,
      );
    }

    return stats;
  }

  Map<String, _SymbolStats> _calculateSymbolStats(
    List<JournalEntry> entries,
  ) {
    final stats = <String, _SymbolStats>{};

    for (final entry in entries) {
      if (entry.pnl == null) continue;

      stats.putIfAbsent(
        entry.symbol,
        () => _SymbolStats(totalTrades: 0, wins: 0, totalPnl: 0),
      );

      final isWin = entry.pnl! >= 0;
      stats[entry.symbol] = _SymbolStats(
        totalTrades: stats[entry.symbol]!.totalTrades + 1,
        wins: stats[entry.symbol]!.wins + (isWin ? 1 : 0),
        totalPnl: stats[entry.symbol]!.totalPnl + entry.pnl!,
      );
    }

    return stats;
  }
}

// Helper classes for data aggregation

class _SummaryItem {
  final String label;
  final String value;

  _SummaryItem(this.label, this.value);
}

class _EmotionStats {
  final int count;
  final double totalPnl;

  _EmotionStats({required this.count, required this.totalPnl});
}

class _SymbolStats {
  final int totalTrades;
  final int wins;
  final double totalPnl;

  _SymbolStats({
    required this.totalTrades,
    required this.wins,
    required this.totalPnl,
  });
}
