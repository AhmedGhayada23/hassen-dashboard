import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/visit.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/visit_schedule.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/visit_status.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/visit_task.dart';
import 'package:hassen_dashboard/features/visits/presentation/cubits/schedule_visit_form_cubit.dart';

import '../../fixtures/visits_fixture.dart';

void main() {
  late ScheduleVisitFormCubit cubit;

  setUp(
    () => cubit = ScheduleVisitFormCubit(
      schedule: expectedSchedule,
      options: expectedOptions,
    ),
  );
  tearDown(() => cubit.close());

  test(
    'opens on the first facility and type, today at 10:00, with the suggested inspector',
    () {
      final s = cubit.state;
      expect(
        (s.facility, s.type, s.day, s.time, s.inspector),
        (expectedOptions.facilities.first, 'تفتيش دوري', wed, '10:00', layla),
      );
      expect((s.suggestedInspector, s.hasConflict), (layla, false));
    },
  );

  test('on a Friday (no today) it opens on the week\'s first day', () {
    final friday = ScheduleVisitFormCubit(
      schedule: VisitSchedule(
        weekLabel: expectedSchedule.weekLabel,
        inspectors: expectedSchedule.inspectors,
        days: expectedSchedule.days,
        visits: expectedSchedule.visits,
      ),
      options: expectedOptions,
    );
    addTearDown(friday.close);

    expect(friday.state.day, sat);
  });

  test('picking a facility switches the type to match its contract status', () {
    cubit.selectFacility(
      expectedOptions.facilities[5],
    ); // مجمع تجاري — not contracted
    expect(cubit.state.type, 'فحص أولي');

    cubit.selectType('متابعة ملاحظات');
    expect(cubit.state.type, 'متابعة ملاحظات');

    cubit.selectFacility(
      expectedOptions.facilities[1],
    ); // بلدية غزة — contracted
    expect(cubit.state.type, 'تفتيش دوري');
  });

  test('time is kept as zero-padded HH:mm', () {
    cubit.selectTime(9, 5);
    expect(cubit.state.time, '09:05');
    cubit.selectTime(14, 30);
    expect(cubit.state.time, '14:30');
  });

  test('a busy inspector is flagged and blocks submitting', () {
    cubit
      ..selectDay(mon)
      ..selectInspector(ahmad); // Ahmad already has Monday 10:00

    expect(cubit.state.hasConflict, isTrue);
    expect(
      [for (final i in expectedSchedule.inspectors) cubit.state.isBusy(i)],
      [true, false, false, false],
    );
    expect(cubit.submit(), isNull);
  });

  test(
    'auto-assign picks the least-loaded free inspector for the chosen slot',
    () {
      cubit
        ..selectDay(thu)
        ..selectTime(9, 0)
        ..selectInspector(layla); // Layla has Thursday 09:00
      expect(cubit.state.hasConflict, isTrue);

      cubit.assignSuggestedInspector();

      expect((cubit.state.inspector, cubit.state.hasConflict), (khaled, false));
    },
  );

  test(
    'submit builds the visit, planned unless it is a pre-contract check',
    () {
      expect(
        cubit.submit(),
        Visit(
          inspector: layla,
          day: wed,
          time: '10:00',
          facility: 'مستشفى الشفاء',
          type: 'تفتيش دوري',
          status: VisitStatus.planned,
          tasks: cubit.state.autoTasks,
        ),
      );

      cubit.selectFacility(expectedOptions.facilities.last);
      expect(cubit.submit()?.status, VisitStatus.preContract);
      expect(cubit.submit()?.facility, 'شركة نقل وخدمات لوجستية');
    },
  );

  test('opened for a facility, it starts there with the type it calls for', () {
    final fixed = ScheduleVisitFormCubit(
      schedule: expectedSchedule,
      options: expectedOptions,
      facility: expectedOptions.facilities[5], // not contracted
    );
    addTearDown(fixed.close);

    expect(fixed.state.facility, expectedOptions.facilities[5]);
    expect(fixed.state.type, 'فحص أولي');
    expect(
      fixed.state.autoTasks.single.title,
      'تنفيذ نموذج الفحص: الفحص الأولي قبل التعاقد v2',
    );
  });

  group('tasks', () {
    test('open on what the facility and type call for, all ticked', () {
      expect(cubit.state.autoTasks.map((t) => t.id), [
        'tpl',
        'CA-0431',
        'CA-0399',
      ]);
      expect(cubit.state.tasks, cubit.state.autoTasks);
    });

    test('an unticked task is left out, and ticking brings it back', () {
      final action = cubit.state.autoTasks[1];

      cubit.toggleTask(action, included: false);
      expect(cubit.state.isIncluded(action), isFalse);
      expect(cubit.state.tasks.map((t) => t.id), ['tpl', 'CA-0399']);

      cubit.toggleTask(action, included: true);
      expect(cubit.state.tasks, cubit.state.autoTasks);
    });

    test('hand-added tasks come last; blanks are ignored', () {
      cubit
        ..addTask('  فحص غرفة المولد ')
        ..addTask('   ')
        ..addTask('مراجعة سجل التدريب');

      expect(cubit.state.manualTasks, const [
        VisitTask(
          id: 'manual-1',
          title: 'فحص غرفة المولد',
          source: VisitTaskSource.manual,
        ),
        VisitTask(
          id: 'manual-2',
          title: 'مراجعة سجل التدريب',
          source: VisitTaskSource.manual,
        ),
      ]);
      expect(cubit.state.tasks, hasLength(5));

      cubit.removeTask(0);
      expect(cubit.state.extraTasks, ['مراجعة سجل التدريب']);
    });

    test('another facility starts its tasks afresh, all ticked', () {
      cubit
        ..toggleTask(cubit.state.autoTasks.first, included: false)
        ..addTask('مهمة يدوية')
        ..selectFacility(expectedOptions.facilities[4]); // بنك فلسطين

      expect(cubit.state.autoTasks.map((t) => t.id), ['tpl', 'CA-0390']);
      expect(cubit.state.excludedTaskIds, isEmpty);
      // Hand-added tasks are kept.
      expect(cubit.state.extraTasks, ['مهمة يدوية']);
    });

    test('a pre-contract type drops the action checks', () {
      cubit.selectType('فحص أولي');

      expect(
        cubit.state.autoTasks.single.title,
        'تنفيذ نموذج الفحص: الفحص الأولي قبل التعاقد v2',
      );
    });

    test('submit books the chosen tasks and the note', () {
      cubit
        ..toggleTask(cubit.state.autoTasks.last, included: false)
        ..addTask('فحص غرفة المولد');

      final visit = cubit.submit(note: ' الدخول من البوابة الخلفية ')!;

      expect(visit.tasks.map((t) => t.id), ['tpl', 'CA-0431', 'manual-1']);
      expect(visit.note, 'الدخول من البوابة الخلفية');
    });
  });
}
