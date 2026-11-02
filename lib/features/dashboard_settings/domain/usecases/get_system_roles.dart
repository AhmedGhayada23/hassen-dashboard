import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/system_role.dart';
import '../repositories/settings_repository.dart';

class GetSystemRoles extends UseCase<List<SystemRole>, NoParams> {
  final SettingsRepository repository;

  GetSystemRoles(this.repository);

  @override
  Future<Either<Failure, List<SystemRole>>> call(NoParams params) =>
      repository.getSystemRoles();
}
