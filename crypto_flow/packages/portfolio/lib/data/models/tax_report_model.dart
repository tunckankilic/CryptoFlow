import '../../domain/entities/tax_report.dart';

class TaxReportModel {
  final String reportId;
  final String type;
  final String key;
  final int size;
  final String createdAt;
  final String? downloadUrl;

  const TaxReportModel({
    required this.reportId,
    required this.type,
    required this.key,
    required this.size,
    required this.createdAt,
    this.downloadUrl,
  });

  factory TaxReportModel.fromJson(Map<String, dynamic> json) {
    return TaxReportModel(
      reportId: json['reportId'] as String? ?? '',
      type: json['type'] as String? ?? 'tax',
      key: json['key'] as String? ?? '',
      size: (json['size'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] as String? ?? '',
      downloadUrl: json['downloadUrl'] as String?,
    );
  }

  TaxReport toEntity() => TaxReport(
        reportId: reportId,
        type: type,
        key: key,
        size: size,
        createdAt: createdAt,
        downloadUrl: downloadUrl,
      );
}
