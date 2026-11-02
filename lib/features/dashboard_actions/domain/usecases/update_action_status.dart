import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/action_status.dart';
import '../entities/corrective_action.dart';
import '../repositories/corrective_actions_repository.dart';

class UpdateActionStatusParams {
  final String actionId;
  final ActionStatus status;

  const UpdateActionStatusParams({
    required this.actionId,
    required this.status,
  });
}

class UpdateActionStatus
    extends UseCase<CorrectiveAction, UpdateActionStatusParams> {
  final CorrectiveActionsRepository repository;

  UpdateActionStatus(this.repository);

  @override
  Future<Either<Failure, CorrectiveAction>> call(
    UpdateActionStatusParams params,
  ) => repository.updateStatus(params.actionId, params.status);
}
