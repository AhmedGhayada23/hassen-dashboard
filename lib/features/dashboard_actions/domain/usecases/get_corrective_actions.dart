import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/corrective_action.dart';
import '../repositories/corrective_actions_repository.dart';

class GetCorrectiveActions extends UseCase<List<CorrectiveAction>, NoParams> {
  final CorrectiveActionsRepository repository;

  GetCorrectiveActions(this.repository);

  @override
  Future<Either<Failure, List<CorrectiveAction>>> call(NoParams params) =>
      repository.getActions();
}
