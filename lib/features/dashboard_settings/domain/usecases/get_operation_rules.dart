import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/operation_rule.dart';
import '../repositories/settings_repository.dart';

class GetOperationRules extends UseCase<List<OperationRule>, NoParams> {
  final SettingsRepository repository;

  GetOperationRules(this.repository);

  @override
  Future<Either<Failure, List<OperationRule>>> call(NoParams params) =>
      repository.getOperationRules();
}
