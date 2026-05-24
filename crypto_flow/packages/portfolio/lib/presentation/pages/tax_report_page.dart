import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:design_system/design_system.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/tax/tax_report_bloc.dart';
import '../bloc/tax/tax_report_event.dart';
import '../bloc/tax/tax_report_state.dart';

/// Tax report generation and download page
class TaxReportPage extends StatefulWidget {
  const TaxReportPage({super.key});

  @override
  State<TaxReportPage> createState() => _TaxReportPageState();
}

class _TaxReportPageState extends State<TaxReportPage> {
  int _selectedYear = DateTime.now().year - 1;
  String _selectedMethod = 'FIFO';
  String _selectedJurisdiction = 'US';

  final _methods = ['FIFO', 'LIFO', 'HIFO'];
  final _jurisdictions = ['US', 'EU', 'UK', 'TR', 'Other'];

  @override
  void initState() {
    super.initState();
    context.read<TaxReportBloc>().add(const TaxReportListRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tax Reports')),
      body: BlocConsumer<TaxReportBloc, TaxReportState>(
        listener: (context, state) {
          if (state is TaxReportGenerated && state.report.downloadUrl != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tax report generated successfully!'),
                backgroundColor: CryptoColors.success,
              ),
            );
          }
          if (state is TaxReportError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: CryptoColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return ListView(
            padding: AppSpacing.paddingMD,
            children: [
              _buildGenerateSection(),
              const SizedBox(height: AppSpacing.lg),
              if (state is TaxReportGenerating) ...[
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: AppSpacing.md),
                      Text('Generating tax report...'),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              if (state is TaxReportGenerated) ...[
                _buildDownloadCard(state),
                const SizedBox(height: AppSpacing.lg),
              ],
              _buildPastReportsSection(state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGenerateSection() {
    return Card(
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Generate Tax Report', style: AppTypography.h5),
            const SizedBox(height: AppSpacing.md),

            // Year selector
            Text('Tax Year', style: AppTypography.caption),
            const SizedBox(height: AppSpacing.xs),
            DropdownButtonFormField<int>(
              initialValue: _selectedYear,
              items: List.generate(5, (i) => DateTime.now().year - i)
                  .map((y) =>
                      DropdownMenuItem(value: y, child: Text(y.toString())))
                  .toList(),
              onChanged: (v) => setState(() => _selectedYear = v!),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Cost basis method
            Text('Cost Basis Method', style: AppTypography.caption),
            const SizedBox(height: AppSpacing.xs),
            SegmentedButton<String>(
              segments: _methods
                  .map((m) => ButtonSegment(value: m, label: Text(m)))
                  .toList(),
              selected: {_selectedMethod},
              onSelectionChanged: (v) =>
                  setState(() => _selectedMethod = v.first),
            ),
            const SizedBox(height: AppSpacing.md),

            // Jurisdiction
            Text('Jurisdiction', style: AppTypography.caption),
            const SizedBox(height: AppSpacing.xs),
            DropdownButtonFormField<String>(
              initialValue: _selectedJurisdiction,
              items: _jurisdictions
                  .map((j) => DropdownMenuItem(value: j, child: Text(j)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedJurisdiction = v!),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Generate button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<TaxReportBloc>().add(
                        TaxReportGenerateRequested(
                          year: _selectedYear,
                          costBasisMethod: _selectedMethod,
                          jurisdiction: _selectedJurisdiction,
                        ),
                      );
                },
                icon: const Icon(Icons.description),
                label: const Text('Generate Report'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadCard(TaxReportGenerated state) {
    return Card(
      color: CryptoColors.success.withValues(alpha: 0.1),
      child: ListTile(
        leading: const Icon(Icons.download, color: CryptoColors.success),
        title: const Text('Report Ready'),
        subtitle: Text('Generated: ${state.report.createdAt.substring(0, 10)}'),
        trailing: ElevatedButton(
          onPressed: () {
            final url = state.report.downloadUrl;
            if (url != null) {
              launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
            }
          },
          child: const Text('Download PDF'),
        ),
      ),
    );
  }

  Widget _buildPastReportsSection(TaxReportState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Past Reports', style: AppTypography.h5),
        const SizedBox(height: AppSpacing.md),
        if (state is TaxReportListLoaded) ...[
          if (state.reports.isEmpty)
            const Center(
              child: Text('No past reports',
                  style: TextStyle(color: CryptoColors.textTertiary)),
            )
          else
            ...state.reports.map(
              (report) => Card(
                child: ListTile(
                  leading: const Icon(Icons.picture_as_pdf),
                  title: Text('Tax Report — ${report.type.toUpperCase()}'),
                  subtitle: Text(report.createdAt.substring(0, 10)),
                  trailing: report.downloadUrl != null
                      ? IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () => launchUrl(
                            Uri.parse(report.downloadUrl!),
                            mode: LaunchMode.externalApplication,
                          ),
                        )
                      : null,
                ),
              ),
            ),
        ],
      ],
    );
  }
}
