import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/theme/app_colors.dart';
import 'package:hassen_dashboard/features/dashboard_risks/domain/entities/risk.dart';
import 'package:hassen_dashboard/features/dashboard_risks/domain/entities/risk_matrix.dart';
import 'package:hassen_dashboard/features/dashboard_risks/presentation/widgets/risk_matrix_card.dart';
import 'package:hassen_dashboard/features/dashboard_risks/presentation/widgets/risk_matrix_cell.dart';
import 'package:hassen_dashboard/features/dashboard_risks/presentation/widgets/risk_score_badge.dart';
import 'package:hassen_dashboard/features/dashboard_risks/presentation/widgets/risk_table_row.dart';
import 'package:hassen_dashboard/features/dashboard_risks/presentation/widgets/risks_table.dart';

import '../../../../helpers/test_view.dart';
import '../../fixtures/risks_fixture.dart';

void main() {
  final matrix = RiskMatrix.fromRisks(expectedRisks);

  BoxDecoration decorationOf(WidgetTester tester, Finder finder) =>
      tester
              .widget<Container>(
                find
                    .descendant(of: finder, matching: find.byType(Container))
                    .first,
              )
              .decoration!
          as BoxDecoration;

  group('table', () {
    testWidgets('shows the five headers in RTL order and all seven risks', (
      tester,
    ) async {
      Risk? tapped;
      await pumpDashboardWidget(
        tester,
        SizedBox(
          width: 780,
          child: RisksTable(
            risks: expectedRisks,
            selectedRiskId: 'RSK-001',
            onRiskTap: (r) => tapped = r,
          ),
        ),
      );

      const headers = ['الدرجة', 'الخطر', 'المنشأة', 'المسؤول', 'الحالة'];
      for (var i = 1; i < headers.length; i++) {
        expect(
          tester.getCenter(find.text(headers[i])).dx,
          lessThan(tester.getCenter(find.text(headers[i - 1])).dx),
        );
      }
      final rows = tester
          .widgetList<RiskTableRow>(find.byType(RiskTableRow))
          .toList();
      expect(rows.map((r) => r.risk.id), [for (final r in expectedRisks) r.id]);
      expect(
        [for (final r in rows) r.isSelected],
        [true, false, false, false, false, false, false],
      );
      expect(find.text('قيد المعالجة'), findsNWidgets(2));
      expect(find.text('مراقبة'), findsOneWidget);

      await tester.tap(find.text('تمديدات كهربائية مكشوفة'));
      expect(tapped!.id, 'RSK-003');
    });

    testWidgets('score badges use the level fill colors', (tester) async {
      final expected = {
        'RSK-001': (HaseenColors.redStrong, Colors.white), // 20
        'RSK-003': (HaseenColors.highStrong, Colors.white), // 12
        'RSK-005': (HaseenColors.mediumStrong, HaseenColors.navy), // 9
        'RSK-006': (HaseenColors.green, Colors.white), // 4
      };
      for (final MapEntry(key: id, value: colors) in expected.entries) {
        await pumpDashboardWidget(
          tester,
          RiskScoreBadge(risk: expectedRisks.firstWhere((r) => r.id == id)),
        );
        final fill = decorationOf(tester, find.byType(RiskScoreBadge)).color;
        final text = tester.widget<Text>(find.byType(Text)).style!.color;
        expect((fill, text), colors, reason: id);
      }
    });
  });

  group('matrix card', () {
    Future<void> pumpCard(WidgetTester tester, Risk? selected) =>
        pumpDashboardWidget(
          tester,
          Align(
            alignment: Alignment.topRight,
            child: SizedBox(
              width: 300,
              child: RiskMatrixCard(matrix: matrix, selected: selected),
            ),
          ),
        );

    RiskMatrixCellView cellAt(
      WidgetTester tester,
      int likelihood,
      int severity,
    ) => tester
        .widgetList<RiskMatrixCellView>(find.byType(RiskMatrixCellView))
        .firstWhere(
          (c) => c.cell.likelihood == likelihood && c.cell.severity == severity,
        );

    testWidgets(
      'renders a 5 × 5 grid laid out LTR: severity → right, likelihood ↓',
      (tester) async {
        await pumpCard(tester, expectedRisks.first);

        expect(find.byType(RiskMatrixCellView), findsNWidgets(25));
        Offset at(int l, int s) =>
            tester.getCenter(find.byWidget(cellAt(tester, l, s)));
        expect(
          at(5, 1).dx,
          lessThan(at(5, 5).dx),
          reason: 'severity grows left to right despite app RTL',
        );
        expect(
          at(5, 1).dy,
          lessThan(at(1, 1).dy),
          reason: 'likelihood 5 at the top',
        );
        expect(
          tester.getCenter(find.text('الاحتمال')).dx,
          lessThan(at(3, 1).dx),
          reason: 'axis title on the left',
        );
        expect(
          tester.getCenter(find.text('الشدة')).dy,
          greaterThan(at(1, 1).dy),
          reason: 'axis title below',
        );
      },
    );

    testWidgets(
      'cells show counts with filled/empty colors and outline the selected risk',
      (tester) async {
        await pumpCard(tester, expectedRisks.first); // 4 × 5

        final selected = cellAt(tester, 4, 5);
        expect(selected.isSelected, isTrue);
        expect(
          tester
              .widgetList<RiskMatrixCellView>(find.byType(RiskMatrixCellView))
              .where((c) => c.isSelected),
          hasLength(1),
        );
        final selectedBox = decorationOf(tester, find.byWidget(selected));
        expect(
          (selectedBox.color, (selectedBox.border! as Border).top.color),
          (HaseenColors.redStrong, HaseenColors.navy),
        );

        expect(
          decorationOf(tester, find.byWidget(cellAt(tester, 5, 5))).color,
          HaseenColors.criticalSoft,
          reason: 'empty critical',
        );
        expect(
          decorationOf(tester, find.byWidget(cellAt(tester, 2, 2))).color,
          HaseenColors.green,
          reason: 'occupied low',
        );
        expect(find.text('1'), findsNWidgets(7));
      },
    );

    testWidgets('shows the selected risk summary under the grid', (
      tester,
    ) async {
      await pumpCard(tester, expectedRisks[1]);

      expect(find.text('مصفوفة المخاطر — عدد المخاطر'), findsOneWidget);
      expect(find.text('آلة قص دون حاجز حماية'), findsOneWidget);
      expect(
        find.text('مصنع العودة · الاحتمال 3 × الشدة 5 = 15'),
        findsOneWidget,
      );
      expect(find.text('تركيب حاجز وتدريب المشغلين'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('تركيب حاجز وتدريب المشغلين')).dy,
        greaterThan(tester.getBottomLeft(find.text('الشدة')).dy),
      );
    });

    testWidgets('an empty selection shows the grid without a summary', (
      tester,
    ) async {
      await pumpCard(tester, null);

      expect(find.byType(RiskMatrixCellView), findsNWidgets(25));
      expect(find.byType(Divider), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
