import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/di/open_actions_bridge.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/features/dashboard_actions/data/repositories/corrective_actions_repository_impl.dart';
import 'package:hassen_dashboard/features/dashboard_actions/domain/entities/action_status.dart';
import 'package:hassen_dashboard/features/dashboard_actions/domain/entities/corrective_action.dart';
import 'package:hassen_dashboard/features/dashboard_actions/domain/repositories/corrective_actions_repository.dart';

import '../../features/dashboard_actions/helpers/fake_corrective_actions_remote_datasource.dart';
import '../../features/visits/fixtures/visits_fixture.dart';

class _FailingActions implements CorrectiveActionsRepository {
  const _FailingActions();

  @override
  Future<Either<Failure, List<CorrectiveAction>>> getActions() async =>
      const Left(CacheFailure());

  @override
  Future<Either<Failure, CorrectiveAction>> updateStatus(
    String id,
    ActionStatus status,
  ) => throw UnimplementedError();
}

void main() {
  test('the board\'s actions that are not closed, worded for visits', () async {
    final bridge = CorrectiveActionsOpenActions(
      CorrectiveActionsRepositoryImpl(FakeCorrectiveActionsRemoteDataSource()),
    );

    expect(await bridge.getOpenActions(), expectedOpenActions);
  });

  test('an action closed on the board is no longer followed up', () async {
    final actions = CorrectiveActionsRepositoryImpl(
      FakeCorrectiveActionsRemoteDataSource(),
    );
    await actions.updateStatus('CA-0431', ActionStatus.closed);

    final open = await CorrectiveActionsOpenActions(actions).getOpenActions();

    expect(open.map((a) => a.id), isNot(contains('CA-0431')));
    expect(open, hasLength(6));
  });

  test('an unreadable board leaves visits without follow-ups', () async {
    expect(
      await const CorrectiveActionsOpenActions(
        _FailingActions(),
      ).getOpenActions(),
      isEmpty,
    );
  });
}
