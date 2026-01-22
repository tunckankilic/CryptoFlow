import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:core/error/failures.dart';
import 'package:core/usecases/usecase.dart';
import '../repositories/settings_repository.dart';

/// Parameters for update theme use case
class UpdateThemeParams extends Equatable {
  final ThemeMode themeMode;

  const UpdateThemeParams({required this.themeMode});

  @override
  List<Object?> get props => [themeMode];
}

/// Use case to update theme
class UpdateTheme implements UseCase<void, UpdateThemeParams> {
  final SettingsRepository repository;

  UpdateTheme(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateThemeParams params) {
    return repository.updateTheme(params.themeMode);
  }
}
