import 'package:equatable/equatable.dart';
import '../../../domain/entities/tax_report.dart';

abstract class TaxReportState extends Equatable {
  const TaxReportState();

  @override
  List<Object?> get props => [];
}

class TaxReportInitial extends TaxReportState {
  const TaxReportInitial();
}

class TaxReportLoading extends TaxReportState {
  const TaxReportLoading();
}

class TaxReportGenerating extends TaxReportState {
  const TaxReportGenerating();
}

class TaxReportGenerated extends TaxReportState {
  final TaxReport report;

  const TaxReportGenerated(this.report);

  @override
  List<Object?> get props => [report];
}

class TaxReportListLoaded extends TaxReportState {
  final List<TaxReport> reports;

  const TaxReportListLoaded(this.reports);

  @override
  List<Object?> get props => [reports];
}

class TaxReportError extends TaxReportState {
  final String message;

  const TaxReportError(this.message);

  @override
  List<Object?> get props => [message];
}
