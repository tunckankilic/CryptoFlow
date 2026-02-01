import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../entities/notification_settings.dart';
import '../repositories/notification_repository.dart';

/// Use case to request notification permission
class RequestPermission implements UseCase<NotificationSettings, NoParams> {
  final NotificationRepository repository;

  RequestPermission(this.repository);

  @override
  Future<Either<Failure, NotificationSettings>> call(NoParams params) async {
    return await repository.requestPermission();
  }
}
