import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/features/overview/domain/entities/compliance_record.dart';
import 'package:hassen_dashboard/features/overview/domain/entities/contract_alert.dart';
import 'package:hassen_dashboard/features/overview/domain/entities/critical_risk.dart';
import 'package:hassen_dashboard/features/overview/domain/entities/dashboard_kpi.dart';
import 'package:hassen_dashboard/features/overview/domain/entities/inspection_review.dart';
import 'package:hassen_dashboard/features/overview/domain/entities/visit.dart';

void main() {
  group('enums', () {
    test('keep their declared values', () {
      expect(KpiTone.values, [
        KpiTone.neutral,
        KpiTone.warning,
        KpiTone.danger,
      ]);
      expect(VisitStatus.values, [
        VisitStatus.done,
        VisitStatus.inProgress,
        VisitStatus.planned,
      ]);
      expect(ComplianceLevel.values, [
        ComplianceLevel.excellent,
        ComplianceLevel.good,
        ComplianceLevel.needsImprovement,
      ]);
    });
  });

  group('DashboardKpi', () {
    test('initializes fields and compares by value', () {
      const a = DashboardKpi(
        label: 'بانتظار الاعتماد',
        value: 4,
        subtitle: 'نتائج تفتيش',
        tone: KpiTone.warning,
      );
      const b = DashboardKpi(
        label: 'بانتظار الاعتماد',
        value: 4,
        subtitle: 'نتائج تفتيش',
        tone: KpiTone.warning,
      );

      expect(
        (a.label, a.value, a.subtitle, a.tone),
        ('بانتظار الاعتماد', 4, 'نتائج تفتيش', KpiTone.warning),
      );
      expect(a, b);
    });
  });

  group('InspectionReview', () {
    test('is not critical by default', () {
      const review = InspectionReview(
        id: 'INS-0417',
        facility: 'بلدية غزة',
        inspector: 'م. سارة',
        nonConformities: 2,
      );

      expect(review.isCritical, isFalse);
    });

    test('flags more than 2 non-conformities as high', () {
      InspectionReview withFails(int n) => InspectionReview(
        id: 'x',
        facility: 'f',
        inspector: 'i',
        nonConformities: n,
      );

      expect(withFails(1).hasHighNonConformities, isFalse);
      expect(withFails(2).hasHighNonConformities, isFalse);
      expect(withFails(3).hasHighNonConformities, isTrue);
    });
  });

  group('ComplianceRecord.level', () {
    ComplianceLevel levelOf(int p) =>
        ComplianceRecord(facility: 'f', percentage: p).level;

    test('uses the original 90 / 80 thresholds', () {
      expect(levelOf(94), ComplianceLevel.excellent);
      expect(levelOf(90), ComplianceLevel.excellent);
      expect(levelOf(89), ComplianceLevel.good);
      expect(levelOf(80), ComplianceLevel.good);
      expect(levelOf(79), ComplianceLevel.needsImprovement);
      expect(levelOf(76), ComplianceLevel.needsImprovement);
    });
  });

  test('Visit, CriticalRisk and ContractAlert hold their values', () {
    const visit = Visit(
      time: '11:30',
      facility: 'مستشفى الشفاء',
      inspector: 'م. أحمد',
      status: VisitStatus.inProgress,
    );
    const risk = CriticalRisk(
      score: 20,
      title: 'إعاقة مسار الإخلاء',
      facility: 'مستشفى الشفاء',
      owner: 'مسؤول السلامة — المستشفى',
    );
    final alert = ContractAlert(
      client: 'بلدية غزة',
      endDate: DateTime(2026, 12, 15),
      daysRemaining: 47,
    );

    expect((visit.time, visit.status), ('11:30', VisitStatus.inProgress));
    expect((risk.score, risk.title), (20, 'إعاقة مسار الإخلاء'));
    expect(
      (alert.client, alert.endDate, alert.daysRemaining),
      ('بلدية غزة', DateTime(2026, 12, 15), 47),
    );
  });
}
