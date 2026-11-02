import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/domain/entities/finding_severity.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/domain/entities/inspection.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/domain/entities/inspection_decision.dart';

import '../../fixtures/inspections_fixture.dart';

Inspection _withCounts(int pass, int fail) => Inspection(
  id: 'x',
  facility: 'f',
  inspector: 'i',
  date: DateTime(2026),
  template: 't',
  passCount: pass,
  failCount: fail,
  findings: const [],
);

void main() {
  test('enums keep their declared values', () {
    expect(InspectionDecision.values, [
      InspectionDecision.pending,
      InspectionDecision.approved,
      InspectionDecision.returned,
    ]);
    expect(FindingSeverity.values, [
      FindingSeverity.critical,
      FindingSeverity.high,
      FindingSeverity.medium,
      FindingSeverity.low,
    ]);
  });

  test('a new inspection is pending by default', () {
    expect(_withCounts(1, 1).decision, InspectionDecision.pending);
    expect(_withCounts(1, 1).isPending, isTrue);
  });

  group('compliancePercent', () {
    test(
      'uses (pass / (pass + fail) * 100).round() — original results unchanged',
      () {
        expect(
          [for (final i in expectedInspections) i.compliancePercent],
          [87, 93, 89, 96],
        );
      },
    );

    test('rounds half up like the original', () {
      expect(_withCounts(1, 1).compliancePercent, 50);
      expect(_withCounts(2, 1).compliancePercent, 67);
    });

    test('is null instead of crashing when nothing was checked', () {
      expect(_withCounts(0, 0).compliancePercent, isNull);
      expect(_withCounts(0, 3).compliancePercent, 0);
      expect(_withCounts(5, 0).compliancePercent, 100);
    });
  });

  test('withDecision changes only the decision', () {
    final original = expectedInspections.first;
    final approved = original.withDecision(InspectionDecision.approved);

    expect(approved.decision, InspectionDecision.approved);
    expect(approved.isPending, isFalse);
    expect(approved.withDecision(InspectionDecision.pending), original);
  });
}
