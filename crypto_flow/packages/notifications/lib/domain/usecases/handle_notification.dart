import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:core/core.dart';
import '../entities/app_notification.dart';
import '../repositories/notification_repository.dart';

/// Parameters for handling a notification
class HandleNotificationParams extends Equatable {
  final AppNotification notification;

  const HandleNotificationParams({required this.notification});

  @override
  List<Object?> get props => [notification];
}

/// Use case to handle a notification
class HandleNotification implements UseCase<void, HandleNotificationParams> {
  final NotificationRepository repository;

  HandleNotification(this.repository);

  @override
  Future<Either<Failure, void>> call(HandleNotificationParams params) async {
    return await repository.showNotification(params.notification);
  }
}
