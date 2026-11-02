import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/inspection_template.dart';
import '../../domain/entities/operation_rule.dart';
import '../../domain/entities/system_role.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  const SettingsRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<InspectionTemplate>>> getInspectionTemplates() =>
      _guard(
        () async => [
          for (final m in await localDataSource.getInspectionTemplates())
            m.toEntity(),
        ],
      );

  @override
  Future<Either<Failure, List<SystemRole>>> getSystemRoles() => _guard(
    () async => [
      for (final m in await localDataSource.getSystemRoles()) m.toEntity(),
    ],
  );

  @override
  Future<Either<Failure, List<OperationRule>>> getOperationRules() => _guard(
    () async => [
      for (final m in await localDataSource.getOperationRules()) m.toEntity(),
    ],
  );

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Right(await run());
    } on AppException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }
}
