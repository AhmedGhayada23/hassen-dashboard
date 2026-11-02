import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/domain/entities/inspection_decision.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/domain/usecases/approve_inspection.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/domain/usecases/get_inspections.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/domain/usecases/reset_inspection_decision.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/domain/usecases/return_inspection.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/presentation/cubits/inspection_review_cubit.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/presentation/cubits/inspection_review_state.dart';

import '../../../../helpers/cubit_emissions.dart';
import '../../fixtures/inspections_fixture.dart';
import '../../helpers/fake_inspection_review_repository.dart';

void main() {
  late FakeInspectionReviewRepository repository;
  late InspectionReviewCubit cubit;

  setUp(() {
    repository = FakeInspectionReviewRepository();
    cubit = InspectionReviewCubit(
      getInspections: GetInspections(repository),
      approveInspection: ApproveInspection(repository),
      returnInspection: ReturnInspection(repository),
      resetDecision: ResetInspectionDecision(repository),
    );
  });
  tearDown(() => cubit.close());

  InspectionReviewLoaded loaded() => cubit.state as InspectionReviewLoaded;

  test('starts in the initial state', () {
    expect(cubit.state, const InspectionReviewInitial());
  });

  test(
    'loads the four reports, selects the first, and counts 4 pending',
    () async {
      repository.gate = Completer<void>();
      final pending = cubit.load();
      expect(cubit.state, const InspectionReviewLoading());
      repository.gate!.complete();
      await pending;

      expect(loaded().inspections, expectedInspections);
      expect(loaded().selectedIndex, 0);
      expect(loaded().selected!.id, 'INS-0418');
      expect(loaded().pendingCount, 4);
    },
  );

  test('emits a failure when loading fails', () async {
    repository.loadFailure = const CacheFailure();

    await cubit.load();

    expect(cubit.state, const InspectionReviewFailure(CacheFailure()));
  });

  group('selection', () {
    setUp(() => cubit.load());

    test('select changes the shown report', () {
      cubit.select(2);

      expect(loaded().selected!.facility, 'مصنع العودة');
    });

    test('re-selecting or an out-of-range index emits nothing', () async {
      final states = await emissionsOf(cubit, () {
        cubit
          ..select(0)
          ..select(-1)
          ..select(4);
      });

      expect(states, isEmpty);
    });
  });

  group('decisions', () {
    setUp(() => cubit.load());

    test('approve sets approved and drops the pending count to 3', () async {
      await cubit.approve('INS-0418');

      expect(loaded().selected!.decision, InspectionDecision.approved);
      expect(loaded().pendingCount, 3);
    });

    test('return sets returned and drops the pending count to 3', () async {
      await cubit.returnToInspector('INS-0418');

      expect(loaded().selected!.decision, InspectionDecision.returned);
      expect(loaded().pendingCount, 3);
    });

    test(
      'undo puts the report back to pending and restores the count',
      () async {
        await cubit.approve('INS-0418');
        await cubit.undoDecision('INS-0418');

        expect(loaded().selected!.decision, InspectionDecision.pending);
        expect(loaded().pendingCount, 4);
      },
    );

    test(
      'decisions apply to the right report even after the selection moved',
      () async {
        cubit.select(3);
        await cubit.returnToInspector('INS-0416');

        expect(loaded().selectedIndex, 3);
        expect(loaded().inspections[2].decision, InspectionDecision.returned);
        expect(loaded().inspections[3].decision, InspectionDecision.pending);
      },
    );

    test('deciding every report brings the count to 0', () async {
      for (final i in expectedInspections) {
        await cubit.approve(i.id);
      }

      expect(loaded().pendingCount, 0);
    });

    test(
      'a failed save keeps the list unchanged and reports the failure once',
      () async {
        repository.updateFailure = const NotFoundFailure();

        await cubit.approve('INS-0418');

        expect(loaded().actionFailure, const NotFoundFailure());
        expect(loaded().pendingCount, 4);

        cubit.select(1);
        expect(loaded().actionFailure, isNull);
      },
    );
  });
}
