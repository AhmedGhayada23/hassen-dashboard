import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/theme/app_colors.dart';
import 'package:hassen_dashboard/core/widgets/status_badge.dart';
import 'package:hassen_dashboard/features/overview/presentation/widgets/compliance/compliance_card.dart';
import 'package:hassen_dashboard/features/overview/presentation/widgets/contracts/contract_alert_card.dart';
import 'package:hassen_dashboard/features/overview/presentation/widgets/inspections/inspection_review_card.dart';
import 'package:hassen_dashboard/features/overview/presentation/widgets/inspections/inspection_review_row.dart';
import 'package:hassen_dashboard/features/overview/presentation/widgets/kpi/dashboard_kpi_grid.dart';
import 'package:hassen_dashboard/features/overview/presentation/widgets/kpi/kpi_card.dart';
import 'package:hassen_dashboard/features/overview/presentation/widgets/risks/critical_risk_card.dart';
import 'package:hassen_dashboard/features/overview/presentation/widgets/visits/today_visits_card.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/presentation/widgets/header/dashboard_header.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/presentation/widgets/header/notifications_button.dart';

import '../../../../helpers/test_view.dart';
import '../../fixtures/overview_fixture.dart';

void main() {
  final overview = expectedOverview;

  Color? textColor(WidgetTester tester, Finder finder) =>
      tester.widget<Text>(finder).style?.color;

  group('KPI grid', () {
    testWidgets(
      'renders every KPI with label, value, subtitle and tone color',
      (tester) async {
        await pumpDashboardWidget(
          tester,
          DashboardKpiGrid(kpis: overview.kpis, onKpiTap: (_) {}),
        );

        expect(find.byType(KpiCard), findsNWidgets(6));
        for (final kpi in overview.kpis) {
          final card = find.widgetWithText(KpiCard, kpi.label);
          expect(card, findsOneWidget);
          expect(
            find.descendant(of: card, matching: find.text(kpi.subtitle)),
            findsOneWidget,
          );
          final value = find.descendant(
            of: card,
            matching: find.text('${kpi.value}'),
          );
          expect(textColor(tester, value), KpiCard.colorFor(kpi.tone));
        }
        expect(KpiCard.colorFor(overview.kpis[0].tone), HaseenColors.navy);
        expect(
          KpiCard.colorFor(overview.kpis[2].tone),
          HaseenColors.warningText,
        );
        expect(KpiCard.colorFor(overview.kpis[3].tone), HaseenColors.red);
      },
    );

    testWidgets('uses 6 columns on wide content and 3 on narrow content', (
      tester,
    ) async {
      Future<int> cardsInFirstRow(Size size) async {
        await pumpDashboardWidget(
          tester,
          DashboardKpiGrid(kpis: overview.kpis, onKpiTap: (_) {}),
          size: size,
        );
        final top = tester.getTopLeft(find.byType(KpiCard).first).dy;
        return find
            .byType(KpiCard)
            .evaluate()
            .where((e) => tester.getTopLeft(find.byWidget(e.widget)).dy == top)
            .length;
      }

      // The grid fills the window here, so window width = content width.
      expect(await cardsInFirstRow(const Size(1440, 900)), 6);
      expect(await cardsInFirstRow(const Size(1101, 900)), 6);
      expect(await cardsInFirstRow(const Size(1100, 900)), 3);
      expect(await cardsInFirstRow(const Size(1000, 900)), 3);
    });

    testWidgets('reports the tapped KPI', (tester) async {
      String? tapped;
      await pumpDashboardWidget(
        tester,
        DashboardKpiGrid(
          kpis: overview.kpis,
          onKpiTap: (k) => tapped = k.label,
        ),
      );

      await tester.tap(find.text('بانتظار الاعتماد'));

      expect(tapped, 'بانتظار الاعتماد');
    });
  });

  group('inspection review card', () {
    testWidgets('renders the header, all rows and critical/high markers', (
      tester,
    ) async {
      var opened = false;
      await pumpDashboardWidget(
        tester,
        InspectionReviewCard(
          reviews: overview.pendingReviews,
          onOpenReview: () => opened = true,
        ),
      );

      expect(find.text('نتائج تفتيش بانتظار الاعتماد'), findsOneWidget);
      for (final header in [
        'رقم',
        'المنشأة',
        'المفتش',
        'غير مطابق',
        'الحالة',
      ]) {
        expect(find.text(header), findsOneWidget);
      }
      expect(find.byType(InspectionReviewRow), findsNWidgets(4));
      for (final r in overview.pendingReviews) {
        final row = find.widgetWithText(InspectionReviewRow, r.id);
        expect(
          find.descendant(of: row, matching: find.text(r.facility)),
          findsOneWidget,
        );
        expect(
          find.descendant(of: row, matching: find.text(r.inspector)),
          findsOneWidget,
        );
        final fails = find.descendant(
          of: row,
          matching: find.text('${r.nonConformities}'),
        );
        expect(
          textColor(tester, fails),
          r.nonConformities > 2 ? HaseenColors.red : HaseenColors.navy,
        );
      }
      expect(find.text('حرج'), findsOneWidget);
      expect(
        find.descendant(
          of: find.widgetWithText(InspectionReviewRow, 'INS-0418'),
          matching: find.text('حرج'),
        ),
        findsOneWidget,
      );
      expect(find.text('بانتظار'), findsNWidgets(4));

      await tester.tap(find.text('فتح المراجعة ←'));
      expect(opened, isTrue);
    });
  });

  group('compliance card', () {
    testWidgets('shows every percentage with the level color', (tester) async {
      await pumpDashboardWidget(
        tester,
        ComplianceCard(records: overview.compliance),
      );

      expect(find.text('نسبة المطابقة حسب المنشأة'), findsOneWidget);
      final bars = tester
          .widgetList<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator),
          )
          .toList();
      expect(bars.map((b) => b.value), [0.82, 0.76, 0.91, 0.85, 0.94]);
      expect(bars.map((b) => b.color), [
        HaseenColors.teal,
        HaseenColors.gold,
        HaseenColors.green,
        HaseenColors.teal,
        HaseenColors.green,
      ]);
      for (final r in overview.compliance) {
        expect(find.text(r.facility), findsOneWidget);
        expect(find.text('${r.percentage}%'), findsOneWidget);
      }
    });
  });

  group('today visits card', () {
    testWidgets('shows each visit with its status badge', (tester) async {
      await pumpDashboardWidget(
        tester,
        TodayVisitsCard(visits: overview.todayVisits),
      );

      expect(find.text('زيارات اليوم'), findsOneWidget);
      for (final time in ['09:00', '11:30', '13:30', '15:00']) {
        expect(find.text(time), findsOneWidget);
      }
      expect(
        find.text('مستشفى الشفاء · م. أحمد', findRichText: true),
        findsNWidgets(2),
      );

      StatusBadge badge(String text) => tester.widget<StatusBadge>(
        find.widgetWithText(StatusBadge, text).first,
      );
      expect(find.text('منجزة'), findsOneWidget);
      expect(find.text('جارية'), findsOneWidget);
      expect(find.text('مجدولة'), findsNWidgets(2));
      expect(
        (badge('منجزة').background, badge('منجزة').foreground),
        (HaseenColors.successSoft, HaseenColors.successText),
      );
      expect(
        (badge('جارية').background, badge('جارية').foreground),
        (HaseenColors.warningSoft, HaseenColors.warningTextDark),
      );
      expect(
        (badge('مجدولة').background, badge('مجدولة').foreground),
        (HaseenColors.bg, HaseenColors.neutralText),
      );
    });
  });

  group('critical risk card', () {
    testWidgets('shows score, title and location', (tester) async {
      await pumpDashboardWidget(
        tester,
        CriticalRiskCard(risks: overview.criticalRisks),
      );

      expect(find.text('مخاطر حرجة مفتوحة'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
      expect(find.text('إعاقة مسار الإخلاء'), findsOneWidget);
      expect(
        find.text('مستشفى الشفاء · مسؤول السلامة — المستشفى'),
        findsOneWidget,
      );
    });
  });

  group('contract alert card', () {
    testWidgets('shows the original alert sentence and the manage button', (
      tester,
    ) async {
      var managed = false;
      await pumpDashboardWidget(
        tester,
        ContractAlertCard(
          alerts: overview.contractAlerts,
          onManageContracts: () => managed = true,
        ),
      );

      expect(find.text('تنبيهات العقود'), findsOneWidget);
      expect(
        find.text(
          'عقد بلدية غزة ينتهي في 2026-12-15 (بعد 47 يوماً). أعدّ عرض التجديد.',
          findRichText: true,
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('إدارة العقود'));
      expect(managed, isTrue);
    });
  });

  group('dashboard header', () {
    testWidgets('shows title, demo badge, search hint and actions', (
      tester,
    ) async {
      String? query;
      await pumpDashboardWidget(
        tester,
        DashboardHeader(
          title: 'نظرة عامة',
          searchHint: 'ابحث عن عميل، زيارة، أو إجراء…',
          onSearchChanged: (q) => query = q,
          actions: [NotificationsButton(hasUnread: true, onPressed: () {})],
        ),
      );

      expect(find.text('نظرة عامة'), findsOneWidget);
      expect(find.text('بيانات تجريبية'), findsOneWidget);
      expect(find.text('ابحث عن عميل، زيارة، أو إجراء…'), findsOneWidget);
      expect(tester.getSize(find.byType(DashboardHeader)).height, 64);
      expect(tester.widget<Badge>(find.byType(Badge)).isLabelVisible, isTrue);

      await tester.enterText(find.byType(TextField), 'غزة');
      expect(query, 'غزة');
    });

    testWidgets('hides the unread dot when there is nothing new', (
      tester,
    ) async {
      await pumpDashboardWidget(
        tester,
        NotificationsButton(hasUnread: false, onPressed: () {}),
      );

      expect(tester.widget<Badge>(find.byType(Badge)).isLabelVisible, isFalse);
    });
  });
}
