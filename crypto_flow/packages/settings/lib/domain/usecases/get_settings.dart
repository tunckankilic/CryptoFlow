import 'package:dartz/dartz.dart';
import 'package:core/error/failures.dart';
import 'package:core/usecases/usecase.dart';
import '../entities/user_settings.dart';
import '../repositories/settings_repository.dart';

/// Use case to get user settings
class GetSettings implements UseCase<UserSettings, NoParams> {
  final SettingsRepository repository;

  GetSettings(this.repository);

  @override
  Future<Either<Failure, UserSettings>> call(NoParams params) {
    return repository.getSettings();
  }
}
