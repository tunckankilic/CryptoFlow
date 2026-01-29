import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../repositories/notification_repository.dart';

/// Use case to get FCM token
class GetFCMToken implements UseCase<String, NoParams> {
  final NotificationRepository repository;

  GetFCMToken(this.repository);

  @override
  Future<Either<Failure, String>> call(NoParams params) async {
    return await repository.getToken();
  }
}
