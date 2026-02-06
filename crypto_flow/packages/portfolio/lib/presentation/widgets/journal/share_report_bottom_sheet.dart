import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../../../data/services/pdf_report_service.dart';

/// Bottom sheet for sharing or saving PDF reports
class ShareReportBottomSheet extends StatelessWidget {
  final Uint8List pdfBytes;
  final PdfReportService pdfReportService;

  const ShareReportBottomSheet({
    super.key,
    required this.pdfBytes,
    required this.pdfReportService,
  });

  /// Show the bottom sheet
  static Future<void> show({
    required BuildContext context,
    required Uint8List pdfBytes,
    required PdfReportService pdfReportService,
  }) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ShareReportBottomSheet(
        pdfBytes: pdfBytes,
        pdfReportService: pdfReportService,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingLG,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: CryptoColors.textTertiary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title
          Text(
            'Export Report',
            style: AppTypography.h5,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),

          // Share option
          _buildOption(
            context: context,
            icon: Icons.share,
            label: 'Share',
            subtitle: 'Share via apps',
            onTap: () async {
              Navigator.pop(context);
              await pdfReportService.sharePdfReport(pdfBytes);
            },
          ),
          const SizedBox(height: AppSpacing.sm),

          // Save option
          _buildOption(
            context: context,
            icon: Icons.download,
            label: 'Save to Device',
            subtitle: 'Save PDF to device',
            onTap: () async {
              Navigator.pop(context);
              await pdfReportService.savePdfReport(pdfBytes);
            },
          ),
          const SizedBox(height: AppSpacing.sm),

          // Cancel button
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),

          // Bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: AppSpacing.paddingMD,
        decoration: BoxDecoration(
          border: Border.all(color: CryptoColors.borderDark),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CryptoColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: CryptoColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.body1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(
                      color: CryptoColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: CryptoColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
