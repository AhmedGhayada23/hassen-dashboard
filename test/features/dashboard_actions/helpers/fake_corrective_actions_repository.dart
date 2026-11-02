import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/features/dashboard_actions/domain/entities/action_status.dart';
import 'package:hassen_dashboard/features/dashboard_actions/domain/entities/corrective_action.dart';
import 'package:hassen_dashboard/features/dashboard_actions/domain/repositories/corrective_actions_repository.dart';

import '../fixtures/actions_fixture.dart';

/// In-memory repository with switchable failures and an optional load gate.
class FakeCorrectiveActionsRepository implements CorrectiveActionsRepository {
  List<CorrectiveAction> actions = [...expectedActions];
  Failure? loadFailure;
  Failure? updateFailure;
  Completer<void>? gate;

  @override
  Future<Either<Failure, List<CorrectiveAction>>> getActions() async {
    await gate?.future;
    return loadFailure != null ? Left(loadFailure!) : Right(actions);
  }

  @override
  Future<Either<Failure, CorrectiveAction>> updateStatus(
    String id,
    ActionStatus status,
  ) async {
    if (updateFailure != null) return Left(updateFailure!);
    final updated = actions.firstWhere((a) => a.id == id).withStatus(status);
    actions = [for (final a in actions) a.id == id ? updated : a];
    return Right(updated);
  }
}
