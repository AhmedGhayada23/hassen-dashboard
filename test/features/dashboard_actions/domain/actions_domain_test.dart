import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/features/dashboard_actions/domain/entities/action_due_status.dart';
import 'package:hassen_dashboard/features/dashboard_actions/domain/entities/action_status.dart';
import 'package:hassen_dashboard/features/dashboard_actions/domain/entities/actions_summary.dart';
import 'package:hassen_dashboard/features/dashboard_actions/domain/usecases/get_corrective_actions.dart';
import 'package:hassen_dashboard/features/dashboard_actions/domain/usecases/update_action_status.dart';
import 'package:hassen_dashboard/core/usecases/usecase.dart';

import '../fixtures/actions_fixture.dart';
import '../helpers/fake_corrective_actions_repository.dart';

void main() {
  test('workflow status and due status are separate, ordered enums', () {
    expect(ActionStatus.values, [
      ActionStatus.open,
      ActionStatus.inProgress,
      ActionStatus.pendingClosure,
      ActionStatus.closed,
    ]);
    expect(ActionDueStatus.values, [
      ActionDueStatus.late,
      ActionDueStatus.soon,
      ActionDueStatus.ok,
      ActionDueStatus.done,
    ]);
    expect(
      [for (final d in ActionDueStatus.values) d.needsAttention],
      [true, true, false, false],
    );
  });

  group('ActionsSummary', () {
    test(
      'counts the original board: 2 / 3 / 2 / 2, 2 late, 3 needing attention',
      () {
        final summary = ActionsSummary.fromActions(expectedActions);

        expect(summary.countsByStatus, {
          ActionStatus.open: 2,
          ActionStatus.inProgress: 3,
          ActionStatus.pendingClosure: 2,
          ActionStatus.closed: 2,
        });
        expect(summary.total, 9);
        expect(summary.lateCount, 2);
        expect(summary.attentionCount, 3);
      },
    );

    test('an empty list yields zeros for every status', () {
      final summary = ActionsSummary.fromActions(const []);

      expect(summary.countsByStatus.values, everyElement(0));
      expect(summary.countsByStatus.keys, ActionStatus.values);
      expect(
        (summary.total, summary.lateCount, summary.attentionCount),
        (0, 0, 0),
      );
    });

    test('moving an action changes column counts but not due-based counts', () {
      final moved = [
        for (final a in expectedActions)
          a.id == 'CA-0431' ? a.withStatus(ActionStatus.closed) : a,
      ];
      final summary = ActionsSummary.fromActions(moved);

      expect(summary.countsByStatus[ActionStatus.open], 1);
      expect(summary.countsByStatus[ActionStatus.closed], 3);
      expect(summary.lateCount, 2);
    });
  });

  test('withStatus keeps every other field', () {
    final original = expectedActions[2];
    final moved = original.withStatus(ActionStatus.pendingClosure);

    expect(moved.status, ActionStatus.pendingClosure);
    expect(moved.withStatus(ActionStatus.inProgress), original);
  });

  test('use cases delegate to the repository', () async {
    final repository = FakeCorrectiveActionsRepository();

    final all = await GetCorrectiveActions(repository)(const NoParams());
    expect(all.getOrElse(() => []), expectedActions);

    final moved = await UpdateActionStatus(repository)(
      const UpdateActionStatusParams(
        actionId: 'CA-0398',
        status: ActionStatus.closed,
      ),
    );
    moved.fold(
      (_) => fail('expected success'),
      (a) => expect((a.id, a.status), ('CA-0398', ActionStatus.closed)),
    );
  });
}
