import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../repositories/notification_repository.dart';

/// Use case to get the device's push notification token (APNs on iOS).
class GetPushToken implements UseCase<String, NoParams> {
  final NotificationRepository repository;

  GetPushToken(this.repository);

  @override
  Future<Either<Failure, String>> call(NoParams params) async {
    return await repository.getToken();
  }
}
