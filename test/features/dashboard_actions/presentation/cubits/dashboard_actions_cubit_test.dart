import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/features/dashboard_actions/domain/entities/action_status.dart';
import 'package:hassen_dashboard/features/dashboard_actions/domain/usecases/get_corrective_actions.dart';
import 'package:hassen_dashboard/features/dashboard_actions/domain/usecases/update_action_status.dart';
import 'package:hassen_dashboard/features/dashboard_actions/presentation/cubits/dashboard_actions_cubit.dart';
import 'package:hassen_dashboard/features/dashboard_actions/presentation/cubits/dashboard_actions_state.dart';

import '../../fixtures/actions_fixture.dart';
import '../../helpers/fake_corrective_actions_repository.dart';

void main() {
  late FakeCorrectiveActionsRepository repository;
  late DashboardActionsCubit cubit;

  setUp(() {
    repository = FakeCorrectiveActionsRepository();
    cubit = DashboardActionsCubit(
      getActions: GetCorrectiveActions(repository),
      updateStatus: UpdateActionStatus(repository),
    );
  });
  tearDown(() => cubit.close());

  DashboardActionsLoaded loaded() => cubit.state as DashboardActionsLoaded;
  List<List<String>> columnIds() => [
    for (final c in loaded().columns.values) c.map((a) => a.id).toList(),
  ];

  test('loads through loading into the four original columns', () async {
    repository.gate = Completer<void>();
    final pending = cubit.load();
    expect(cubit.state, const DashboardActionsLoading());
    repository.gate!.complete();
    await pending;

    expect(loaded().columns.keys, ActionStatus.values);
    expect(columnIds(), expectedColumnIds);
    expect(loaded().summary.attentionCount, 3);
  });

  test('emits a failure when loading fails', () async {
    repository.loadFailure = const CacheFailure();

    await cubit.load();

    expect(cubit.state, const DashboardActionsFailure(CacheFailure()));
  });

  test('an empty list gives four empty columns and zero counts', () async {
    repository.actions = [];

    await cubit.load();

    expect(loaded().columns.values, everyElement(isEmpty));
    expect((loaded().summary.total, loaded().summary.attentionCount), (0, 0));
  });

  group('moveAction', () {
    setUp(() => cubit.load());

    test(
      'moves the action into the target column and updates counts',
      () async {
        await cubit.moveAction('CA-0412', ActionStatus.pendingClosure);

        expect(columnIds(), [
          ['CA-0431', 'CA-0428'],
          ['CA-0405', 'CA-0399'],
          ['CA-0412', 'CA-0398', 'CA-0390'],
          ['CA-0377', 'CA-0371'],
        ]);
        expect(loaded().summary.countsByStatus[ActionStatus.pendingClosure], 3);
      },
    );

    test('keeps every other field of the moved action', () async {
      await cubit.moveAction('CA-0431', ActionStatus.closed);

      final moved = loaded().actions.firstWhere((a) => a.id == 'CA-0431');
      expect(moved, expectedActions.first.withStatus(ActionStatus.closed));
      expect(loaded().actions, hasLength(9));
    });

    test(
      'a failed save leaves the board unchanged and reports the failure once',
      () async {
        repository.updateFailure = const NotFoundFailure();

        await cubit.moveAction('CA-0431', ActionStatus.closed);
        expect(loaded().actionFailure, const NotFoundFailure());
        expect(columnIds(), expectedColumnIds);

        repository.updateFailure = null;
        await cubit.moveAction('CA-0428', ActionStatus.inProgress);
        expect(loaded().actionFailure, isNull);
      },
    );
  });
}
