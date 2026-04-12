import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/tax_remote_datasource.dart';
import '../../../data/models/tax_report_model.dart';
import 'tax_report_event.dart';
import 'tax_report_state.dart';

class TaxReportBloc extends Bloc<TaxReportEvent, TaxReportState> {
  final TaxRemoteDataSource _taxDataSource;

  TaxReportBloc({required TaxRemoteDataSource taxDataSource})
      : _taxDataSource = taxDataSource,
        super(const TaxReportInitial()) {
    on<TaxReportGenerateRequested>(_onGenerate);
    on<TaxReportListRequested>(_onList);
  }

  Future<void> _onGenerate(
    TaxReportGenerateRequested event,
    Emitter<TaxReportState> emit,
  ) async {
    emit(const TaxReportGenerating());
    try {
      final data = await _taxDataSource.generateTaxReport(
        year: event.year,
        costBasisMethod: event.costBasisMethod,
        jurisdiction: event.jurisdiction,
      );
      final model = TaxReportModel.fromJson(data);
      emit(TaxReportGenerated(model.toEntity()));
    } catch (e) {
      emit(TaxReportError(e.toString()));
    }
  }

  Future<void> _onList(
    TaxReportListRequested event,
    Emitter<TaxReportState> emit,
  ) async {
    emit(const TaxReportLoading());
    try {
      final data = await _taxDataSource.listTaxReports();
      final reports =
          data.map((d) => TaxReportModel.fromJson(d).toEntity()).toList();
      emit(TaxReportListLoaded(reports));
    } catch (e) {
      emit(TaxReportError(e.toString()));
    }
  }
}
