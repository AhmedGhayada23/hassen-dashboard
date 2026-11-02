import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/theme/app_colors.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/visit.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/visit_status.dart';
import 'package:hassen_dashboard/features/visits/presentation/widgets/schedule_visit_conflict_notice.dart';
import 'package:hassen_dashboard/features/visits/presentation/widgets/schedule_visit_dialog.dart';
import 'package:hassen_dashboard/features/visits/presentation/widgets/schedule_visit_inspector_card.dart';

import '../../../../helpers/test_view.dart';
import '../../fixtures/visits_fixture.dart';

void main() {
  late Visit? result;
  late bool closed;

  Future<void> openDialog(WidgetTester tester) async {
    result = null;
    closed = false;
    await pumpDashboardWidget(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            result = await showScheduleVisitDialog(
              context,
              schedule: expectedSchedule,
              options: expectedOptions,
            );
            closed = true;
          },
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Finder card(String name) =>
      find.widgetWithText(ScheduleVisitInspectorCard, name);
  ScheduleVisitInspectorCard cardOf(WidgetTester tester, String name) =>
      tester.widget<ScheduleVisitInspectorCard>(card(name));
  FilledButton submitButton(WidgetTester tester) => tester.widget<FilledButton>(
    find.widgetWithText(FilledButton, 'جدولة وإسناد'),
  );

  Future<void> choose(
    WidgetTester tester,
    String current,
    String option,
  ) async {
    await tester.tap(find.text(current));
    await tester.pumpAndSettle();
    await tester.tap(find.text(option).last);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'opens with the original defaults and the suggested inspector selected',
    (tester) async {
      await openDialog(tester);

      for (final text in [
        'جدولة زيارة',
        'العميل / المنشأة',
        'مستشفى الشفاء',
        'نوع الزيارة',
        'تفتيش دوري',
        'اليوم',
        'الأربعاء 28 (اليوم)',
        'الوقت',
        '10:00',
        'المفتش',
        'توزيع تلقائي حسب عبء العمل',
        'ملاحظات للمفتش',
        'اختياري',
        'إلغاء',
        'تصل الزيارة للمفتش في التطبيق الميداني',
      ]) {
        expect(find.text(text), findsOneWidget, reason: text);
      }
      expect(
        [
          for (final name in ['م. أحمد', 'م. سارة', 'م. خالد', 'م. ليلى'])
            cardOf(tester, name).weeklyVisits,
        ],
        [4, 4, 3, 2],
      );
      final layla = cardOf(tester, 'م. ليلى');
      expect(
        (layla.selected, layla.suggested, layla.busy),
        (true, true, false),
      );
      expect(
        find.descendant(of: card('م. ليلى'), matching: find.text('مقترح')),
        findsOneWidget,
      );
      expect(
        tester
            .widget<Material>(
              find
                  .descendant(
                    of: card('م. ليلى'),
                    matching: find.byType(Material),
                  )
                  .first,
            )
            .color,
        HaseenColors.navy,
      );
      expect(find.byType(ScheduleVisitConflictNotice), findsNothing);
      expect(submitButton(tester).onPressed, isNotNull);
    },
  );

  testWidgets(
    'uncontracted facilities are labelled and switch the type to a pre-contract check',
    (tester) async {
      await openDialog(tester);

      await choose(tester, 'مستشفى الشفاء', 'مدرسة خاصة — غزة — غير متعاقد');

      expect(find.text('فحص أولي'), findsOneWidget);
      expect(find.text('تفتيش دوري'), findsNothing);
    },
  );

  testWidgets(
    'a busy inspector shows the clash notice and disables booking until auto-assign',
    (tester) async {
      await openDialog(tester);
      await choose(tester, 'الأربعاء 28 (اليوم)', 'الإثنين 26');

      await tester.tap(card('م. أحمد'));
      await tester.pumpAndSettle();

      expect(find.text(ScheduleVisitConflictNotice.message), findsOneWidget);
      expect(
        find.descendant(of: card('م. أحمد'), matching: find.text('مشغول')),
        findsOneWidget,
      );
      expect(submitButton(tester).onPressed, isNull);

      await tester.tap(find.text('توزيع تلقائي حسب عبء العمل'));
      await tester.pumpAndSettle();

      expect(cardOf(tester, 'م. ليلى').selected, isTrue);
      expect(find.byType(ScheduleVisitConflictNotice), findsNothing);
      expect(submitButton(tester).onPressed, isNotNull);
    },
  );

  testWidgets('"جدولة وإسناد" closes the dialog with the new visit', (
    tester,
  ) async {
    await openDialog(tester);
    await choose(tester, 'تفتيش دوري', 'متابعة ملاحظات');

    await tester.tap(find.text('جدولة وإسناد'));
    await tester.pumpAndSettle();

    expect(find.byType(ScheduleVisitInspectorCard), findsNothing);
    expect(closed, isTrue);
    expect(
      result,
      Visit(
        inspector: layla,
        day: wed,
        time: '10:00',
        facility: 'مستشفى الشفاء',
        type: 'متابعة ملاحظات',
        status: VisitStatus.planned,
        tasks: expectedOptions.autoTasksFor(
          expectedOptions.facilities.first,
          'متابعة ملاحظات',
        ),
      ),
    );
  });

  group('tasks section', () {
    Future<void> tapVisible(WidgetTester tester, Finder finder) async {
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }

    testWidgets('lists the facility\'s tasks, ticked, with their count', (
      tester,
    ) async {
      await openDialog(tester);

      expect(find.text('مهام الزيارة'), findsOneWidget);
      expect(find.text('3 مهام'), findsOneWidget);
      expect(
        find.text('تنفيذ نموذج الفحص: تفتيش المنشآت الصحية v2'),
        findsOneWidget,
      );
      expect(
        find.text('التحقق من CA-0431: إزالة الأسرّة من أمام مخرج الطوارئ 2'),
        findsOneWidget,
      );
      expect(find.text('إجراء مفتوح (حرج) — يتابع حالته'), findsOneWidget);
      final boxes = tester.widgetList<Checkbox>(find.byType(Checkbox));
      expect([for (final b in boxes) b.value], [true, true, true]);
    });

    testWidgets('unticking a task leaves it out of the visit', (tester) async {
      await openDialog(tester);

      await tapVisible(tester, find.byType(Checkbox).at(1));
      expect(find.text('2 مهام'), findsOneWidget);

      await tester.tap(find.text('جدولة وإسناد'));
      await tester.pumpAndSettle();
      expect(result!.tasks.map((t) => t.id), ['tpl', 'CA-0399']);
    });

    testWidgets('a typed task is added, can be deleted, and is booked', (
      tester,
    ) async {
      await openDialog(tester);
      final field = find.widgetWithText(
        TextField,
        'مهمة إضافية، مثل: فحص غرفة المولد',
      );

      await tester.ensureVisible(field);
      await tester.enterText(field, 'فحص غرفة المولد');
      await tapVisible(tester, find.text('+ إضافة مهمة'));
      await tester.enterText(field, 'مهمة ثانية');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('5 مهام'), findsOneWidget);
      expect(find.text('أضافها مدير العمليات'), findsNWidgets(2));

      await tapVisible(tester, find.text('حذف').last);
      expect(find.text('مهمة ثانية'), findsNothing);

      await tester.tap(find.text('جدولة وإسناد'));
      await tester.pumpAndSettle();
      expect(result!.tasks.last.title, 'فحص غرفة المولد');
      expect(result!.tasks, hasLength(4));
    });

    testWidgets('the note is booked with the visit', (tester) async {
      await openDialog(tester);
      final note = find.byType(TextField).last;

      await tester.ensureVisible(note);
      await tester.enterText(note, 'الدخول من البوابة الخلفية');
      await tester.tap(find.text('جدولة وإسناد'));
      await tester.pumpAndSettle();

      expect(result!.note, 'الدخول من البوابة الخلفية');
    });
  });

  testWidgets('cancel and the close button book nothing', (tester) async {
    await openDialog(tester);
    await tester.tap(find.text('إلغاء'));
    await tester.pumpAndSettle();
    expect((closed, result), (true, null));

    await openDialog(tester);
    await tester.tap(find.byTooltip('إغلاق'));
    await tester.pumpAndSettle();
    expect((closed, result), (true, null));
  });

  testWidgets('the time button opens a time picker at the current time', (
    tester,
  ) async {
    await openDialog(tester);

    await tester.tap(find.text('10:00'));
    await tester.pumpAndSettle();

    expect(find.byType(TimePickerDialog), findsOneWidget);
    expect(
      tester
          .widget<TimePickerDialog>(find.byType(TimePickerDialog))
          .initialTime,
      const TimeOfDay(hour: 10, minute: 0),
    );
  });
}
