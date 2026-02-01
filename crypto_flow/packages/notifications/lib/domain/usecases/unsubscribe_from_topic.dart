import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:core/core.dart';
import '../repositories/notification_repository.dart';

/// Parameters for unsubscribing from a topic
class UnsubscribeFromTopicParams extends Equatable {
  final String topic;

  const UnsubscribeFromTopicParams({required this.topic});

  @override
  List<Object?> get props => [topic];
}

/// Use case to unsubscribe from a topic
class UnsubscribeFromTopic
    implements UseCase<void, UnsubscribeFromTopicParams> {
  final NotificationRepository repository;

  UnsubscribeFromTopic(this.repository);

  @override
  Future<Either<Failure, void>> call(UnsubscribeFromTopicParams params) async {
    return await repository.unsubscribeFromTopic(params.topic);
  }
}
