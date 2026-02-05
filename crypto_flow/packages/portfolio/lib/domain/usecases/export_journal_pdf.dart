import 'package:core/error/failures.dart';
import 'package:core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../repositories/journal_repository.dart';
import '../entities/stats_period.dart';

/// Configuration for PDF export
class ExportConfig {
  final DateTimeRange? dateRange;
  final bool includeStats;
  final bool includeTags;
  final String? symbol;

  ExportConfig({
    this.dateRange,
    this.includeStats = true,
    this.includeTags = true,
    this.symbol,
  });
}

/// Parameters for ExportJournalPdf use case
class ExportJournalPdfParams {
  final ExportConfig config;

  ExportJournalPdfParams({required this.config});
}

/// Use case to export journal entries to PDF
/// Generates a PDF document with journal entries and optional statistics
class ExportJournalPdf implements UseCase<String, ExportJournalPdfParams> {
  final JournalRepository repository;

  ExportJournalPdf(this.repository);

  @override
  Future<Either<Failure, String>> call(ExportJournalPdfParams params) async {
    try {
      // Get journal entries
      final entriesResult = await repository.getEntries(
        symbol: params.config.symbol,
        range: params.config.dateRange,
      );

      return await entriesResult.fold(
        (failure) => Left(failure),
        (entries) async {
          // Create PDF document
          final pdf = pw.Document();

          // Add cover page
          pdf.addPage(
            pw.Page(
              pageFormat: PdfPageFormat.a4,
              build: (pw.Context context) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Trading Journal Export',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 20),
                    pw.Text('Generated: ${DateTime.now().toString()}'),
                    pw.Text('Total Entries: ${entries.length}'),
                    if (params.config.symbol != null)
                      pw.Text('Symbol: ${params.config.symbol}'),
                  ],
                );
              },
            ),
          );

          // Add statistics page if requested
          if (params.config.includeStats) {
            final statsResult = await repository.calculateStats(
              StatsPeriod.allTime,
            );

            statsResult.fold(
              (failure) {
                // If stats fail, continue without them
              },
              (stats) {
                pdf.addPage(
                  pw.Page(
                    pageFormat: PdfPageFormat.a4,
                    build: (pw.Context context) {
                      return pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Trading Statistics',
                            style: pw.TextStyle(
                              fontSize: 20,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 20),
                          pw.Text('Total Trades: ${stats.totalTrades}'),
                          pw.Text('Win Count: ${stats.winCount}'),
                          pw.Text('Loss Count: ${stats.lossCount}'),
                          pw.Text(
                              'Win Rate: ${stats.winRate.toStringAsFixed(2)}%'),
                          pw.Text(
                              'Total P&L: \$${stats.totalPnl.toStringAsFixed(2)}'),
                          pw.Text(
                              'Profit Factor: ${stats.profitFactor.toStringAsFixed(2)}'),
                          pw.Text(
                              'Average R:R: ${stats.averageRR.toStringAsFixed(2)}'),
                          pw.Text(
                              'Largest Win: \$${stats.largestWin.toStringAsFixed(2)}'),
                          pw.Text(
                              'Largest Loss: \$${stats.largestLoss.toStringAsFixed(2)}'),
                        ],
                      );
                    },
                  ),
                );
              },
            );
          }

          // Add entries pages
          if (entries.isNotEmpty) {
            for (final entry in entries) {
              pdf.addPage(
                pw.Page(
                  pageFormat: PdfPageFormat.a4,
                  build: (pw.Context context) {
                    return pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '${entry.symbol} - ${entry.side.toString().split('.').last.toUpperCase()}',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text('Entry: \$${entry.entryPrice}'),
                        if (entry.exitPrice != null)
                          pw.Text('Exit: \$${entry.exitPrice}'),
                        pw.Text('Quantity: ${entry.quantity}'),
                        if (entry.pnl != null)
                          pw.Text('P&L: \$${entry.pnl!.toStringAsFixed(2)}'),
                        if (entry.pnlPercentage != null)
                          pw.Text(
                              'P&L %: ${entry.pnlPercentage!.toStringAsFixed(2)}%'),
                        if (entry.strategy != null)
                          pw.Text('Strategy: ${entry.strategy}'),
                        pw.Text(
                            'Emotion: ${entry.emotion.toString().split('.').last}'),
                        if (entry.notes != null && entry.notes!.isNotEmpty)
                          pw.Text('Notes: ${entry.notes}'),
                        if (params.config.includeTags && entry.tags.isNotEmpty)
                          pw.Text('Tags: ${entry.tags.join(', ')}'),
                        pw.Text('Entry Date: ${entry.entryDate}'),
                        if (entry.exitDate != null)
                          pw.Text('Exit Date: ${entry.exitDate}'),
                      ],
                    );
                  },
                ),
              );
            }
          }

          // Save PDF to file
          final output = await getApplicationDocumentsDirectory();
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final file = File('${output.path}/journal_export_$timestamp.pdf');
          await file.writeAsBytes(await pdf.save());

          return Right(file.path);
        },
      );
    } catch (e) {
      return Left(
        CacheFailure(message: 'Failed to export journal to PDF: $e'),
      );
    }
  }
}
