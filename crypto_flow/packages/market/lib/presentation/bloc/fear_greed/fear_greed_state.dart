import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

/// States for Fear & Greed Index
abstract class FearGreedState extends Equatable {
  const FearGreedState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class FearGreedInitial extends FearGreedState {
  const FearGreedInitial();
}

/// Loading state
class FearGreedLoading extends FearGreedState {
  const FearGreedLoading();
}

/// Loaded state
class FearGreedLoaded extends FearGreedState {
  final FearGreedIndex index;

  const FearGreedLoaded(this.index);

  @override
  List<Object?> get props => [index];
}

/// Error state
class FearGreedError extends FearGreedState {
  final String message;

  const FearGreedError(this.message);

  @override
  List<Object?> get props => [message];
}
