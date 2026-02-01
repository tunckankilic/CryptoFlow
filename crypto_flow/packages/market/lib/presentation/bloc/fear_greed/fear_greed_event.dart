import 'package:equatable/equatable.dart';

/// Events for Fear & Greed Index
abstract class FearGreedEvent extends Equatable {
  const FearGreedEvent();

  @override
  List<Object?> get props => [];
}

/// Load Fear & Greed Index
class LoadFearGreedIndex extends FearGreedEvent {
  const LoadFearGreedIndex();
}
