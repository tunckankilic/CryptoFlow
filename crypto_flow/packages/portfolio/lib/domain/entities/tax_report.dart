import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Represents a generated tax report
@immutable
class TaxReport extends Equatable {
  final String reportId;
  final String type;
  final String key;
  final int size;
  final String createdAt;
  final String? downloadUrl;

  const TaxReport({
    required this.reportId,
    required this.type,
    required this.key,
    required this.size,
    required this.createdAt,
    this.downloadUrl,
  });

  @override
  List<Object?> get props =>
      [reportId, type, key, size, createdAt, downloadUrl];
}
