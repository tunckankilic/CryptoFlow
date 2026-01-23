import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../error/failures.dart';

/// Base class for all use cases in the application
/// Uses the Either pattern from dartz to return either a Failure or Success
///
/// Type: The type of data returned on success
/// Params: The parameters required to execute the use case
abstract class UseCase<T, Params> {
  /// Execute the use case
  Future<Either<Failure, T>> call(Params params);
}

/// Use case that doesn't require parameters
abstract class NoParamsUseCase<T> {
  Future<Either<Failure, T>> call();
}

/// Use case that returns a stream instead of a future
abstract class StreamUseCase<T, Params> {
  Stream<Either<Failure, T>> call(Params params);
}

/// Use case that returns a stream without parameters
abstract class NoParamsStreamUseCase<T> {
  Stream<Either<Failure, T>> call();
}

/// Represents no parameters for a use case
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
