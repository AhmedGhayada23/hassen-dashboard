import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/action_status.dart';
import '../entities/corrective_action.dart';

abstract interface class CorrectiveActionsRepository {
  Future<Either<Failure, List<CorrectiveAction>>> getActions();

  /// Moves action [id] to [status] and returns the updated action.
  Future<Either<Failure, CorrectiveAction>> updateStatus(
    String id,
    ActionStatus status,
  );
}
