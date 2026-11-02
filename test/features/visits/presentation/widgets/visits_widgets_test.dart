import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/theme/app_colors.dart';
import 'package:hassen_dashboard/core/widgets/status_badge.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/visit.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/visit_status.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/visit_task.dart';
import 'package:hassen_dashboard/features/visits/presentation/config/visit_status_style.dart';
import 'package:hassen_dashboard/features/visits/presentation/widgets/visit_chip.dart';
import 'package:hassen_dashboard/features/visits/presentation/widgets/visit_details_dialog.dart';
import 'package:hassen_dashboard/features/visits/presentation/widgets/visit_task_text.dart';
import 'package:hassen_dashboard/features/visits/presentation/widgets/visits_day_cell.dart';
import 'package:hassen_dashboard/features/visits/presentation/widgets/visits_day_header.dart';
import 'package:hassen_dashboard/features/visits/presentation/widgets/visits_inspector_cell.dart';
import 'package:hassen_dashboard/features/visits/presentation/widgets/visits_legend.dart';
import 'package:hassen_dashboard/features/visits/presentation/widgets/visits_page_header.dart';
import 'package:hassen_dashboard/features/visits/presentation/widgets/visits_schedule_grid.dart';

import '../../../../helpers/test_view.dart';
import '../../fixtures/visits_fixture.dart';

void main() {
  final schedule = expectedSchedule;

  BoxDecoration decorationOf(WidgetTester tester, Finder finder) =>
      tester
              .widget<Container>(
                find
                    .descendant(of: finder, matching: find.byType(Container))
                    .first,
              )
              .decoration!
          as BoxDecoration;

  group('schedule grid', () {
    testWidgets('renders the header row with today highlighted in navy', (
      tester,
    ) async {
      await pumpDashboardWidget(
        tester,
        VisitsScheduleGrid(schedule: schedule, onVisitTap: (_) {}),
      );

      expect(find.text('المفتش'), findsOneWidget);
      for (final day in schedule.days) {
        final cell = find.widgetWithText(VisitsHeadCell, day.label);
        expect(cell, findsOneWidget);
        expect(
          decorationOf(tester, cell).color,
          day == wed ? HaseenColors.navy : HaseenColors.tableHeader,
        );
        expect(
          tester.widget<Text>(find.text(day.label)).style!.color,
          day == wed ? Colors.white : HaseenColors.muted,
        );
      }
    });

    testWidgets('renders every inspector with their visit count', (
      tester,
    ) async {
      await pumpDashboardWidget(
        tester,
        VisitsScheduleGrid(schedule: schedule, onVisitTap: (_) {}),
      );

      final counts = {
        for (final cell in tester.widgetList<VisitsInspectorCell>(
          find.byType(VisitsInspectorCell),
        ))
          cell.inspector.name: cell.visitCount,
      };
      expect(counts, {'م. أحمد': 4, 'م. سارة': 4, 'م. خالد': 3, 'م. ليلى': 2});
      expect(find.text('4 زيارات'), findsNWidgets(2));
      expect(find.text('3 زيارات'), findsOneWidget);
      expect(find.text('2 زيارات'), findsOneWidget);
    });

    testWidgets('places all 13 visits in their inspector × day cells', (
      tester,
    ) async {
      await pumpDashboardWidget(
        tester,
        VisitsScheduleGrid(schedule: schedule, onVisitTap: (_) {}),
      );

      expect(find.byType(VisitsDayCell), findsNWidgets(4 * 6));
      expect(find.byType(VisitChip), findsNWidgets(13));
      final cells = tester
          .widgetList<VisitsDayCell>(find.byType(VisitsDayCell))
          .toList();
      // Row-major: inspector 0 (أحمد), day 4 (الأربعاء) → two visits, in order.
      expect(cells[0 * 6 + 4].visits.map((v) => v.time), ['09:00', '11:30']);
      expect(cells[3 * 6 + 5].visits.single.facility, 'مدرسة خاصة');
      expect([for (final c in cells) c.isToday].where((t) => t), hasLength(4));
      expect(find.text('09:00 · مستشفى الشفاء'), findsNWidgets(2));
      expect(find.text('11:30 · مستشفى الشفاء'), findsOneWidget);
    });

    testWidgets('reports the tapped visit', (tester) async {
      Visit? tapped;
      await pumpDashboardWidget(
        tester,
        VisitsScheduleGrid(schedule: schedule, onVisitTap: (v) => tapped = v),
      );

      await tester.tap(find.text('11:00 · مجمع تجاري'));

      expect(tapped, schedule.visitsFor(sara, thu).single);
    });
  });

  group('cells and chips', () {
    testWidgets('today cells use the today tint, other days white', (
      tester,
    ) async {
      await pumpDashboardWidget(
        tester,
        Row(
          children: [
            VisitsDayCell(visits: const [], isToday: true, onVisitTap: (_) {}),
            VisitsDayCell(visits: const [], isToday: false, onVisitTap: (_) {}),
          ],
        ),
      );

      final cells = find.byType(VisitsDayCell);
      expect(decorationOf(tester, cells.at(0)).color, HaseenColors.todayTint);
      expect(decorationOf(tester, cells.at(1)).color, Colors.white);
    });

    testWidgets('chip shows time · facility and type, tinted by status', (
      tester,
    ) async {
      final visit = schedule.visitsFor(ahmad, wed).last; // جارية
      await pumpDashboardWidget(
        tester,
        SizedBox(
          width: 150,
          child: VisitChip(visit: visit, onTap: () {}),
        ),
      );

      expect(find.text('11:30 · مستشفى الشفاء'), findsOneWidget);
      expect(find.text('متابعة ملاحظات'), findsOneWidget);
      final material = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(VisitChip),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(material.color, VisitStatus.inProgress.style.background);
      final border =
          decorationOf(tester, find.byType(InkWell)).border!
              as BorderDirectional;
      expect((border.start.color, border.start.width), (HaseenColors.gold, 3));
      expect(find.byIcon(Icons.checklist), findsOneWidget);
      expect(find.text('0 مهام'), findsOneWidget);
    });

    testWidgets('chip counts the visit tasks', (tester) async {
      const visit = Visit(
        inspector: layla,
        day: wed,
        time: '10:00',
        facility: 'بنك فلسطين',
        type: 'تفتيش دوري',
        status: VisitStatus.planned,
        tasks: [
          VisitTask(id: 'a', title: 'أ', source: VisitTaskSource.template),
          VisitTask(id: 'b', title: 'ب', source: VisitTaskSource.manual),
          VisitTask(id: 'c', title: 'ج', source: VisitTaskSource.manual),
        ],
      );
      await pumpDashboardWidget(
        tester,
        SizedBox(
          width: 150,
          child: VisitChip(visit: visit, onTap: () {}),
        ),
      );

      expect(find.text('3 مهام'), findsOneWidget);
    });
  });

  group('details panel', () {
    const withTasks = Visit(
      inspector: sara,
      day: thu,
      time: '11:00',
      facility: 'مجمع تجاري',
      type: 'فحص أولي',
      status: VisitStatus.preContract,
      tasks: [
        VisitTask(
          id: 'tpl',
          title: 'تنفيذ نموذج الفحص: الفحص الأولي قبل التعاقد v2',
          detail: '30 بنداً',
          source: VisitTaskSource.template,
        ),
        VisitTask(
          id: 'manual-1',
          title: 'فحص غرفة المولد',
          source: VisitTaskSource.manual,
        ),
      ],
      note: 'التنسيق مع مدير المجمع قبل الوصول',
    );

    Future<void> open(WidgetTester tester, Visit visit) async {
      await pumpDashboardWidget(
        tester,
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showVisitDetailsDialog(context, visit),
            child: const Text('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('slides in on the right with the visit, its status and close', (
      tester,
    ) async {
      await open(tester, withTasks);

      final panel = find.byType(VisitDetailsPanel);
      expect(tester.getTopRight(panel).dx, 1440);
      expect(tester.getSize(panel).width, 440);
      expect(find.text('مجمع تجاري'), findsOneWidget);
      expect(
        find.text('فحص أولي · الخميس 29 · 11:00 · م. سارة'),
        findsOneWidget,
      );
      final pill = tester.widget<StatusBadge>(find.byType(StatusBadge));
      expect(
        (pill.text, pill.background, pill.foreground),
        ('فحص أولي قبل التعاقد', HaseenColors.dangerTint, HaseenColors.red),
      );

      await tester.tap(find.byTooltip('إغلاق'));
      await tester.pumpAndSettle();
      expect(panel, findsNothing);
    });

    testWidgets('lists the tasks numbered, with their source, and the note', (
      tester,
    ) async {
      await open(tester, withTasks);

      expect(find.text('2 مهام'), findsOneWidget);
      expect(
        find.text('هذا ما يراه م. سارة في التطبيق عند فتح الزيارة.'),
        findsOneWidget,
      );
      final tiles = tester.widgetList<VisitTaskTile>(
        find.byType(VisitTaskTile),
      );
      expect(
        [for (final t in tiles) (t.number, t.task)],
        [(1, withTasks.tasks[0]), (2, withTasks.tasks[1])],
      );
      expect(find.text('30 بنداً'), findsOneWidget);
      expect(find.text('تلقائي — حسب قطاع المنشأة'), findsOneWidget);
      expect(find.text('أضافها مدير العمليات'), findsOneWidget);
      expect(find.text('ملاحظات للمفتش'), findsOneWidget);
      expect(find.text('التنسيق مع مدير المجمع قبل الوصول'), findsOneWidget);
    });

    testWidgets('a visit without a note shows no notes heading', (
      tester,
    ) async {
      await open(tester, schedule.visitsFor(sara, thu).single);

      expect(find.text('0 مهام'), findsOneWidget);
      expect(find.byType(VisitTaskTile), findsNothing);
      expect(find.text('ملاحظات للمفتش'), findsNothing);
    });
  });

  testWidgets('legend lists every status in order with its bar color', (
    tester,
  ) async {
    await pumpDashboardWidget(tester, const VisitsLegend());

    final labels = ['منجزة', 'جارية', 'مجدولة', 'فحص أولي قبل التعاقد'];
    double x(String t) => tester.getCenter(find.text(t)).dx;
    for (var i = 1; i < labels.length; i++) {
      expect(x(labels[i]), lessThan(x(labels[i - 1])), reason: 'RTL order');
    }
    final swatches = tester
        .widgetList<Container>(
          find.descendant(
            of: find.byType(VisitsLegend),
            matching: find.byType(Container),
          ),
        )
        .map((c) => (c.decoration! as BoxDecoration).color);
    expect(swatches, [
      HaseenColors.green,
      HaseenColors.gold,
      HaseenColors.neutralBar,
      HaseenColors.redStrong,
    ]);
  });

  testWidgets('page header shows the week and the schedule action', (
    tester,
  ) async {
    var scheduled = false;
    await pumpDashboardWidget(
      tester,
      VisitsPageHeader(
        weekLabel: schedule.weekLabel,
        onScheduleVisit: () => scheduled = true,
        onPreviousWeek: () {},
        onNextWeek: () {},
      ),
    );

    expect(find.text('الأسبوع 24 – 29 أكتوبر 2026'), findsOneWidget);
    await tester.tap(find.text('+ جدولة زيارة'));
    expect(scheduled, isTrue);
  });

  testWidgets('page header arrows and the current-week button call back', (
    tester,
  ) async {
    final calls = <String>[];
    await pumpDashboardWidget(
      tester,
      VisitsPageHeader(
        weekLabel: schedule.weekLabel,
        onScheduleVisit: () {},
        onPreviousWeek: () => calls.add('previous'),
        onNextWeek: () => calls.add('next'),
        onCurrentWeek: () => calls.add('current'),
      ),
    );

    await tester.tap(find.byTooltip(VisitsPageHeader.previousWeekTooltip));
    await tester.tap(find.byTooltip(VisitsPageHeader.nextWeekTooltip));
    await tester.tap(find.text(VisitsPageHeader.currentWeekLabel));

    expect(calls, ['previous', 'next', 'current']);
  });
}
