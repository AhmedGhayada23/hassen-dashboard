import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/theme/app_colors.dart';
import 'package:hassen_dashboard/core/widgets/status_badge.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/domain/entities/inspection.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/domain/entities/inspection_decision.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/presentation/widgets/finding_severity_badge.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/presentation/widgets/inspection_decision_actions.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/presentation/widgets/inspection_decision_status.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/presentation/widgets/inspection_finding_card.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/presentation/widgets/inspection_review_details.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/presentation/widgets/inspection_review_list.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/presentation/widgets/inspection_review_list_item.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/presentation/widgets/inspection_summary_stats.dart';

import '../../../../helpers/test_view.dart';
import '../../fixtures/inspections_fixture.dart';

void main() {
  final first = expectedInspections.first;

  Future<void> pumpDetails(
    WidgetTester tester,
    Inspection inspection, {
    VoidCallback? onApprove,
    VoidCallback? onReturn,
    VoidCallback? onUndo,
  }) => pumpDashboardWidget(
    tester,
    SingleChildScrollView(
      child: InspectionReviewDetails(
        inspection: inspection,
        onApprove: onApprove ?? () {},
        onReturn: onReturn ?? () {},
        onUndo: onUndo ?? () {},
      ),
    ),
  );

  group('review list', () {
    testWidgets(
      'shows the title and every report with its subtitle and status',
      (tester) async {
        await pumpDashboardWidget(
          tester,
          SizedBox(
            width: 320,
            child: InspectionReviewList(
              inspections: expectedInspections,
              selectedIndex: 0,
              onSelect: (_) {},
            ),
          ),
        );

        expect(find.text('قائمة المراجعة'), findsOneWidget);
        expect(find.byType(InspectionReviewListItem), findsNWidgets(4));
        expect(find.text('INS-0418 · م. أحمد · 2026-10-28'), findsOneWidget);
        expect(find.text('INS-0415 · م. ليلى · 2026-10-26'), findsOneWidget);
        expect(find.text('بانتظار'), findsNWidgets(4));
      },
    );

    testWidgets('highlights only the selected report and reports taps', (
      tester,
    ) async {
      int? tapped;
      await pumpDashboardWidget(
        tester,
        SizedBox(
          width: 320,
          child: InspectionReviewList(
            inspections: expectedInspections,
            selectedIndex: 1,
            onSelect: (i) => tapped = i,
          ),
        ),
      );

      final items = tester
          .widgetList<InspectionReviewListItem>(
            find.byType(InspectionReviewListItem),
          )
          .toList();
      expect(
        [for (final i in items) i.isSelected],
        [false, true, false, false],
      );
      Material materialOf(int i) => tester.widget<Material>(
        find
            .descendant(
              of: find.byType(InspectionReviewListItem).at(i),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(materialOf(1).color, HaseenColors.selectedRow);
      expect(materialOf(0).color, Colors.white);

      await tester.tap(find.text('مصنع العودة'));
      expect(tapped, 2);
    });
  });

  group('details', () {
    testWidgets('header shows facility, meta line and the three stats', (
      tester,
    ) async {
      await pumpDetails(tester, first);

      expect(find.text('مستشفى الشفاء'), findsOneWidget);
      expect(
        find.text('INS-0418 · تفتيش المنشآت الصحية v2 · م. أحمد · 2026-10-28'),
        findsOneWidget,
      );
      for (final (value, label) in [
        ('20', 'مطابق'),
        ('3', 'غير مطابق'),
        ('87%', 'المطابقة'),
      ]) {
        expect(find.text(value), findsOneWidget);
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('lists every finding with severity badge, note and deadline', (
      tester,
    ) async {
      await pumpDetails(tester, first);

      expect(find.text('البنود غير المطابقة'), findsOneWidget);
      expect(find.byType(InspectionFindingCard), findsNWidgets(3));
      for (final f in first.findings) {
        expect(find.text(f.title), findsOneWidget);
        expect(find.text(f.note), findsOneWidget);
        expect(find.text('المهلة: ${f.due}'), findsOneWidget);
      }
      final badges = tester.widgetList<StatusBadge>(
        find.descendant(
          of: find.byType(FindingSeverityBadge),
          matching: find.byType(StatusBadge),
        ),
      );
      expect([for (final b in badges) b.text], ['حرج', 'عالٍ', 'متوسط']);
    });

    testWidgets('pending report shows approve/return and wires the callbacks', (
      tester,
    ) async {
      var approved = false, returned = false;
      await pumpDetails(
        tester,
        first,
        onApprove: () => approved = true,
        onReturn: () => returned = true,
      );

      expect(find.byType(InspectionDecisionActions), findsOneWidget);
      expect(find.byType(InspectionDecisionStatus), findsNothing);
      expect(
        find.text(
          'لا تظهر النتائج للمنشأة قبل الاعتماد، باستثناء الخطر الحرج.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('اعتماد ونشر للمنشأة'));
      await tester.tap(find.text('إعادة للمفتش'));
      expect((approved, returned), (true, true));
    });

    testWidgets(
      'approved report shows the published banner and undo instead of the buttons',
      (tester) async {
        var undone = false;
        await pumpDetails(
          tester,
          first.withDecision(InspectionDecision.approved),
          onUndo: () => undone = true,
        );

        expect(find.text('اعتماد ونشر للمنشأة'), findsNothing);
        expect(
          find.text('تم الاعتماد — النتائج ظاهرة الآن لدى المنشأة'),
          findsOneWidget,
        );
        await tester.tap(find.text('تراجع'));
        expect(undone, isTrue);
      },
    );

    testWidgets('returned report shows the returned banner', (tester) async {
      await pumpDetails(
        tester,
        first.withDecision(InspectionDecision.returned),
      );

      expect(find.text('أُعيد للمفتش مع ملاحظات'), findsOneWidget);
      expect(find.text('إعادة للمفتش'), findsNothing);
    });
  });

  testWidgets('summary shows — instead of crashing when pass + fail = 0', (
    tester,
  ) async {
    final empty = Inspection(
      id: 'x',
      facility: 'f',
      inspector: 'i',
      date: DateTime(2026),
      template: 't',
      passCount: 0,
      failCount: 0,
      findings: const [],
    );
    await pumpDashboardWidget(
      tester,
      InspectionSummaryStats(inspection: empty),
    );

    expect(find.text('—'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
