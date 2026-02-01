import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:core/core.dart';
import '../repositories/notification_repository.dart';

/// Parameters for subscribing to a topic
class SubscribeToTopicParams extends Equatable {
  final String topic;

  const SubscribeToTopicParams({required this.topic});

  @override
  List<Object?> get props => [topic];
}

/// Use case to subscribe to a topic
class SubscribeToTopic implements UseCase<void, SubscribeToTopicParams> {
  final NotificationRepository repository;

  SubscribeToTopic(this.repository);

  @override
  Future<Either<Failure, void>> call(SubscribeToTopicParams params) async {
    return await repository.subscribeToTopic(params.topic);
  }
}
