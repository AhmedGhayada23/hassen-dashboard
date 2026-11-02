import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/usecases/usecase.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/domain/entities/inspection_decision.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/domain/usecases/approve_inspection.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/domain/usecases/get_inspections.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/domain/usecases/reset_inspection_decision.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/domain/usecases/return_inspection.dart';

import '../../fixtures/inspections_fixture.dart';
import '../../helpers/fake_inspection_review_repository.dart';

void main() {
  late FakeInspectionReviewRepository repository;

  setUp(() => repository = FakeInspectionReviewRepository());

  test('GetInspections returns all four reports', () async {
    final result = await GetInspections(repository)(const NoParams());

    expect(result.getOrElse(() => []), expectedInspections);
  });

  test('each decision use case records its own decision', () async {
    await ApproveInspection(repository)('INS-0418');
    await ReturnInspection(repository)('INS-0417');
    await ResetInspectionDecision(repository)('INS-0418');

    expect(repository.updates, [
      ('INS-0418', InspectionDecision.approved),
      ('INS-0417', InspectionDecision.returned),
      ('INS-0418', InspectionDecision.pending),
    ]);
  });

  test('decision use cases return the updated report', () async {
    final result = await ApproveInspection(repository)('INS-0416');

    expect(
      result
          .map((i) => (i.id, i.decision))
          .getOrElse(() => ('', InspectionDecision.pending)),
      ('INS-0416', InspectionDecision.approved),
    );
  });
}
