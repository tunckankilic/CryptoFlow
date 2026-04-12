import 'package:equatable/equatable.dart';

abstract class TaxReportEvent extends Equatable {
  const TaxReportEvent();

  @override
  List<Object?> get props => [];
}

class TaxReportGenerateRequested extends TaxReportEvent {
  final int year;
  final String costBasisMethod; // FIFO, LIFO, HIFO
  final String? jurisdiction;

  const TaxReportGenerateRequested({
    required this.year,
    required this.costBasisMethod,
    this.jurisdiction,
  });

  @override
  List<Object?> get props => [year, costBasisMethod, jurisdiction];
}

class TaxReportListRequested extends TaxReportEvent {
  const TaxReportListRequested();
}
