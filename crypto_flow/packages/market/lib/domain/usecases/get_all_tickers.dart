import 'package:dartz/dartz.dart';
import 'package:core/error/failures.dart';
import 'package:core/usecases/usecase.dart';
import '../entities/ticker.dart';
import '../repositories/market_repository.dart';

/// Use case to fetch all available tickers from REST API
class GetAllTickersUseCase implements NoParamsUseCase<List<Ticker>> {
  final MarketRepository repository;

  GetAllTickersUseCase(this.repository);

  @override
  Future<Either<Failure, List<Ticker>>> call() {
    return repository.getAllTickers();
  }
}
