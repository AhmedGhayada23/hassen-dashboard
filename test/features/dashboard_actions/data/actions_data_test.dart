import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/features/dashboard_actions/data/models/corrective_action_model.dart';
import 'package:hassen_dashboard/features/dashboard_actions/data/repositories/corrective_actions_repository_impl.dart';
import 'package:hassen_dashboard/features/dashboard_actions/domain/entities/action_due_status.dart';
import 'package:hassen_dashboard/features/dashboard_actions/domain/entities/action_severity.dart';
import 'package:hassen_dashboard/features/dashboard_actions/domain/entities/action_status.dart';
import 'package:hassen_dashboard/features/dashboard_actions/domain/entities/corrective_action.dart';

import '../fixtures/actions_fixture.dart';
import '../helpers/fake_corrective_actions_remote_datasource.dart';

void main() {
  group('CorrectiveActionModel', () {
    test('maps a Firestore document into a typed entity', () {
      final model = CorrectiveActionModel.fromDocument('CA-0431', const {
        'title': 'إزالة الأسرّة من أمام مخرج الطوارئ 2',
        'facility': 'مستشفى الشفاء',
        'severity': 'critical',
        'owner': 'مسؤول السلامة',
        'due_text': '24 ساعة',
        'due_status': 'late',
        'status': 'open',
      })!;

      expect(model.toEntity(), expectedActions.first);
    });

    test('every status code round-trips', () {
      for (final status in ActionStatus.values) {
        expect(
          CorrectiveActionModel.fromDocument('x', {
            'title': 't',
            'status': CorrectiveActionModel.statusToJson(status),
          })!.status,
          status,
        );
      }
    });

    test('a sparse or hand-edited document reads safely', () {
      final model = CorrectiveActionModel.fromDocument('CA-1', const {
        'title': '  تركيب لافتة  ',
        'severity': 'extreme',
        'due_status': 'whenever',
        'status': 'archived',
      })!;

      expect(
        model.toEntity(),
        const CorrectiveAction(
          id: 'CA-1',
          title: 'تركيب لافتة',
          facility: '—',
          severity: ActionSeverity.medium,
          owner: '—',
          dueText: '—',
          dueStatus: ActionDueStatus.ok,
          status: ActionStatus.open,
        ),
      );
    });

    test('an action without a title is left out', () {
      expect(
        CorrectiveActionModel.fromDocument('x', const {'status': 'open'}),
        isNull,
      );
    });
  });

  group('repository over Firestore', () {
    late FakeCorrectiveActionsRemoteDataSource remote;
    late CorrectiveActionsRepositoryImpl repository;

    setUp(() {
      remote = FakeCorrectiveActionsRemoteDataSource();
      repository = CorrectiveActionsRepositoryImpl(remote);
    });

    test('loads the nine original actions exactly, in board order', () async {
      expect(
        (await repository.getActions()).getOrElse(() => []),
        expectedActions,
      );
    });

    test('an untitled document is skipped, not fatal', () async {
      remote.documents['CA-BAD'] = {'status': 'open'};

      expect(
        (await repository.getActions()).getOrElse(() => []),
        expectedActions,
      );
    });

    test('a status change is stored and returned', () async {
      final moved = (await repository.updateStatus(
        'CA-0412',
        ActionStatus.pendingClosure,
      )).getOrElse(() => throw StateError('not moved'));

      expect(moved.status, ActionStatus.pendingClosure);
      expect(remote.documents['CA-0412']!['status'], 'pending_closure');
      expect(
        (await repository.getActions())
            .getOrElse(() => [])
            .singleWhere((a) => a.id == 'CA-0412')
            .status,
        ActionStatus.pendingClosure,
      );
    });

    test('an unknown action is NotFoundFailure', () async {
      final missing = await repository.updateStatus(
        'CA-9999',
        ActionStatus.closed,
      );

      expect(missing.fold((f) => f, (_) => null), isA<NotFoundFailure>());
    });

    test('Firestore errors become failures the page can explain', () async {
      Future<Failure> failureFor(String code) async {
        remote.error = FirebaseException(plugin: 'cloud_firestore', code: code);
        return (await repository.getActions()).fold(
          (f) => f,
          (_) => throw StateError('no failure'),
        );
      }

      expect(await failureFor('permission-denied'), const ForbiddenFailure());
      expect(await failureFor('unavailable'), const NetworkFailure());
      expect(await failureFor('internal'), isA<UnknownFailure>());
    });
  });
}
