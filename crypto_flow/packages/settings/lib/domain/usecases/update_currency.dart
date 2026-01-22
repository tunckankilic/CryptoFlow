import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:core/error/failures.dart';
import 'package:core/usecases/usecase.dart';
import '../repositories/settings_repository.dart';

/// Parameters for update currency use case
class UpdateCurrencyParams extends Equatable {
  final String currency;

  const UpdateCurrencyParams({required this.currency});

  @override
  List<Object?> get props => [currency];
}

/// Use case to update currency
class UpdateCurrency implements UseCase<void, UpdateCurrencyParams> {
  final SettingsRepository repository;

  UpdateCurrency(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateCurrencyParams params) {
    return repository.updateCurrency(params.currency);
  }
}
