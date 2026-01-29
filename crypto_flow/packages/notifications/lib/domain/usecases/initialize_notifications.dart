import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../repositories/notification_repository.dart';

/// Use case to initialize notifications
class InitializeNotifications implements UseCase<void, NoParams> {
  final NotificationRepository repository;

  InitializeNotifications(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.initialize();
  }
}
