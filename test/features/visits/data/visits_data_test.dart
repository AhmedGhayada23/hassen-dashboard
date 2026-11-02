import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/errors/exceptions.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/features/visits/data/datasources/visits_local_datasource.dart';
import 'package:hassen_dashboard/features/visits/data/models/inspector_model.dart';
import 'package:hassen_dashboard/features/visits/data/models/visit_model.dart';
import 'package:hassen_dashboard/features/visits/data/models/visit_schedule_model.dart';
import 'package:hassen_dashboard/features/visits/data/repositories/visits_repository_impl.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/visit.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/visit_facility.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/visit_schedule.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/visit_status.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/visit_task.dart';

import '../fixtures/visits_fixture.dart';
import '../helpers/fake_open_actions_datasource.dart';
import '../helpers/fake_visits_remote_datasource.dart';

const _layla10 = Visit(
  inspector: layla,
  day: wed,
  time: '10:00',
  facility: 'مدرسة خاصة — غزة',
  type: 'فحص أولي',
  status: VisitStatus.preContract,
);

void main() {
  final local = VisitsLocalDataSource(clock: () => fixtureNow);

  group('week', () {
    Map<String, Object?> weekOn(int year, int month, int day) =>
        VisitsLocalDataSource.weekOf(DateTime(year, month, day, 14));
    List<Object?> labels(Map<String, Object?> week) => [
      for (final d in week['days']! as List) (d as Map)['label'],
    ];

    test('is the working week of the clock, today marked', () {
      final week = weekOn(2026, 11, 1);

      expect(week['week_label'], 'الأسبوع 31 أكتوبر – 5 نوفمبر 2026');
      expect(labels(week), [
        'السبت 31',
        'الأحد 1',
        'الإثنين 2',
        'الثلاثاء 3',
        'الأربعاء 4',
        'الخميس 5',
      ]);
      expect(week['today'], 1);
      expect((week['days']! as List).first, {
        'order': 0,
        'label': 'السبت 31',
        'date': '2026-10-31',
      });
    });

    test('Saturday and Thursday are its ends', () {
      expect(weekOn(2026, 10, 24)['today'], 0);
      expect(weekOn(2026, 10, 29)['today'], 5);
      expect(weekOn(2026, 10, 29)['week_label'], 'الأسبوع 24 – 29 أكتوبر 2026');
    });

    test('on Friday it is the coming week, with no day marked', () {
      final week = weekOn(2026, 10, 30);

      expect(week['week_label'], 'الأسبوع 31 أكتوبر – 5 نوفمبر 2026');
      expect(week['today'], isNull);
    });

    test(
      'an offset moves whole weeks, marking no day outside this one',
      () async {
        final next = await local.getWeek(offset: 1);
        final previous = await local.getWeek(offset: -1);

        expect(next['week_label'], 'الأسبوع 31 أكتوبر – 5 نوفمبر 2026');
        expect(previous['week_label'], 'الأسبوع 17 – 22 أكتوبر 2026');
        expect((next['today'], previous['today']), (null, null));
        expect((await local.getWeek())['today'], 4);
      },
    );

    test('on Friday the next week is the one after the coming week', () {
      final week = VisitsLocalDataSource.weekOf(
        DateTime(2026, 10, 30),
        offset: 1,
      );

      expect(week['week_label'], 'الأسبوع 7 – 12 نوفمبر 2026');
    });

    test('a week across the new year names both years', () {
      final week = weekOn(2029, 1, 1);

      expect(week['week_label'], 'الأسبوع 30 ديسمبر 2028 – 4 يناير 2029');
      expect(week['today'], 2);
    });
  });

  group('models', () {
    test('a visit round-trips through its document with the status codes', () {
      expect(VisitModel.fromEntity(_layla10).toJson(), {
        'inspector_id': 'uid-layla',
        'inspector_name': 'م. ليلى',
        'date': '2026-10-28',
        'time': '10:00',
        'facility': 'مدرسة خاصة — غزة',
        'type': 'فحص أولي',
        'status': 'pre',
        'tasks': <Object?>[],
        'note': '',
      });
      for (final status in VisitStatus.values) {
        expect(
          VisitModel.fromDocument({
            'status': VisitModel.statusToJson(status),
          }).status,
          status,
        );
      }
    });

    test('a sparse or hand-edited visit document reads safely', () {
      final model = VisitModel.fromDocument(const {'status': 'cancelled'});

      expect(
        (model.inspectorId, model.date, model.time, model.status),
        ('', '', '', VisitStatus.planned),
      );
    });

    test('tasks and the note are stored with the visit and read back', () {
      const visit = Visit(
        inspector: layla,
        day: wed,
        time: '10:00',
        facility: 'بنك فلسطين',
        type: 'تفتيش دوري',
        status: VisitStatus.planned,
        tasks: [
          VisitTask(
            id: 'tpl',
            title: 'تنفيذ نموذج الفحص: تفتيش المكاتب والفروع v1',
            detail: '23 بنداً',
            source: VisitTaskSource.template,
          ),
          VisitTask(
            id: 'CA-0390',
            title: 'التحقق من CA-0390: استبدال طفايات منتهية',
            detail: 'المنشأة رفعت دليل المعالجة — يتحقق منه ميدانياً',
            source: VisitTaskSource.correctiveAction,
          ),
          VisitTask(
            id: 'manual-1',
            title: 'فحص غرفة المولد',
            source: VisitTaskSource.manual,
          ),
        ],
        note: 'الدخول من البوابة الخلفية',
      );

      final json = VisitModel.fromEntity(visit).toJson();

      expect(json['note'], 'الدخول من البوابة الخلفية');
      expect(json['tasks'], [
        {
          'id': 'tpl',
          'title': 'تنفيذ نموذج الفحص: تفتيش المكاتب والفروع v1',
          'detail': '23 بنداً',
          'source': 'template',
        },
        {
          'id': 'CA-0390',
          'title': 'التحقق من CA-0390: استبدال طفايات منتهية',
          'detail': 'المنشأة رفعت دليل المعالجة — يتحقق منه ميدانياً',
          'source': 'corrective_action',
        },
        {
          'id': 'manual-1',
          'title': 'فحص غرفة المولد',
          'detail': '',
          'source': 'manual',
        },
      ]);
      expect(
        VisitModel.fromDocument(json).toEntity(inspector: layla, day: wed),
        visit,
      );
    });

    test('each task becomes a tasks document with its visit\'s details', () {
      final visit = expectedOptions.buildVisit(
        inspector: layla,
        day: wed,
        time: '10:00',
        facility: expectedOptions.facilities[4], // بنك فلسطين
        type: 'تفتيش دوري',
        tasks: [
          ...expectedOptions.autoTasksFor(
            expectedOptions.facilities[4],
            'تفتيش دوري',
          ),
          const VisitTask(
            id: 'manual-1',
            title: 'فحص غرفة المولد',
            source: VisitTaskSource.manual,
          ),
        ],
      );

      final docs = VisitModel.fromEntity(visit).taskDocuments('visit-1');

      expect(docs.first, {
        'visit_id': 'visit-1',
        'task_id': 'tpl',
        'order': 1,
        'title': 'تنفيذ نموذج الفحص: تفتيش المكاتب والفروع v1',
        'detail': '23 بنداً',
        'source': 'template',
        'status': 'pending',
        'inspector_id': 'uid-layla',
        'inspector_name': 'م. ليلى',
        'facility': 'بنك فلسطين',
        'visit_type': 'تفتيش دوري',
        'visit_status': 'planned',
        'date': '2026-10-28',
        'time': '10:00',
      });
      expect(
        [for (final d in docs) (d['order'], d['task_id'], d['source'])],
        [
          (1, 'tpl', 'template'),
          (2, 'CA-0390', 'corrective_action'),
          (3, 'manual-1', 'manual'),
        ],
      );
      expect(VisitModel.fromEntity(_layla10).taskDocuments('visit-2'), isEmpty);
    });

    test('malformed or untitled tasks in a document are skipped', () {
      final model = VisitModel.fromDocument(const {
        'tasks': [
          'not a map',
          {'id': 'x', 'title': '  '},
          {'id': 'y', 'title': 'مهمة', 'source': 'unknown'},
        ],
      });

      expect(
        model.tasks.single.toEntity(),
        const VisitTask(id: 'y', title: 'مهمة', source: VisitTaskSource.manual),
      );
      expect(model.note, '');
    });

    test('the local templates are the original ones', () async {
      final catalog = (await local.getInspectionTemplates()).withOpenActions(
        expectedOpenActions,
      );

      expect(catalog, expectedTaskCatalog);
    });

    test('malformed templates throw ParseException', () {
      expect(
        const VisitsLocalDataSource(
          templatesJson: {
            'by_sector': <String, Object?>{},
            'default': {'name': '', 'items': 0},
            'pre_contract': {'name': 'x', 'items': 1},
          },
        ).getInspectionTemplates(),
        throwsA(isA<ParseException>()),
      );
    });

    test('an inspector is read from its users document', () {
      final model = InspectorModel.fromUserDocument('uid-9', const {
        'name': ' م. رامي ',
        'role': 'inspector',
      });

      expect((model.id, model.name), ('uid-9', 'م. رامي'));
    });
  });

  group('schedule assembly', () {
    test('the fixed week holds the Firebase inspectors and visits', () async {
      final schedule = VisitScheduleModel.fromParts(
        weekJson: await local.getWeek(),
        inspectors: [
          for (final i in expectedSchedule.inspectors)
            InspectorModel(id: i.id, name: i.name),
        ],
        visits: [
          for (final v in expectedSchedule.visits) VisitModel.fromEntity(v),
        ],
      ).toEntity();

      expect(schedule, expectedSchedule);
    });

    test(
      'visits of a removed inspector or of another week are left out',
      () async {
        final schedule = VisitScheduleModel.fromParts(
          weekJson: await local.getWeek(),
          inspectors: const [InspectorModel(id: 'uid-layla', name: 'م. ليلى')],
          visits: [
            VisitModel.fromEntity(_layla10),
            VisitModel.fromDocument(const {
              'inspector_id': 'uid-gone',
              'date': '2026-10-25',
            }),
            VisitModel.fromDocument(const {
              'inspector_id': 'uid-layla',
              'date': '2026-11-02',
            }),
          ],
        ).toEntity();

        expect(schedule.visits, [_layla10]);
      },
    );

    test('a week whose "today" is not one of its days is refused', () {
      expect(
        () => VisitScheduleModel.fromParts(
          weekJson: const {
            'week_label': 'w',
            'days': [
              {'order': 0, 'label': 'السبت', 'date': '2026-10-24'},
            ],
            'today': 3,
          },
          inspectors: const [],
          visits: const [],
        ),
        throwsFormatException,
      );
    });

    test('malformed visit types throw ParseException', () {
      expect(
        const VisitsLocalDataSource(
          typesJson: {
            'visit_types': <String>[],
            'routine_type': 'x',
            'pre_contract_type': 'y',
          },
        ).getVisitTypes(),
        throwsA(isA<ParseException>()),
      );
    });
  });

  group('repository', () {
    late FakeVisitsRemoteDataSource remote;
    late FakeOpenActionsDataSource openActions;
    late VisitsRepositoryImpl repository;

    setUp(() {
      remote = FakeVisitsRemoteDataSource();
      openActions = FakeOpenActionsDataSource();
      repository = VisitsRepositoryImpl(local, remote, openActions);
    });

    test('the schedule is the fixed week with the Firebase data', () async {
      expect(
        await repository.getSchedule(),
        Right<Failure, VisitSchedule>(expectedSchedule),
      );
    });

    test('another week holds only its own visits', () async {
      final next = (await repository.getSchedule(
        weekOffset: 1,
      )).getOrElse(() => throw StateError('no schedule'));
      expect(next.weekLabel, 'الأسبوع 31 أكتوبر – 5 نوفمبر 2026');
      expect(next.visits, isEmpty);
      expect(next.today, isNull);

      final tuesday = next.days[3];
      final result = await repository.addVisit(
        Visit(
          inspector: layla,
          day: tuesday,
          time: '09:00',
          facility: 'فندق الأمواج',
          type: 'فحص أولي',
          status: VisitStatus.preContract,
        ),
        weekOffset: 1,
      );

      expect(remote.added.single.date, '2026-11-03');
      final updated = result.getOrElse(() => throw StateError('no schedule'));
      expect(updated.visitsFor(layla, tuesday).single.time, '09:00');
      // The current week is unchanged.
      final current = (await repository.getSchedule()).getOrElse(
        () => throw StateError('no schedule'),
      );
      expect(current.visits.length, 13);
    });

    test(
      'no inspectors or visits in Firebase is an empty week, not an error',
      () async {
        remote
          ..inspectors = []
          ..visits = [];

        final schedule = (await repository.getSchedule()).getOrElse(
          () => throw StateError('no schedule'),
        );

        expect(schedule.inspectors, isEmpty);
        expect(schedule.visits, isEmpty);
        expect(schedule.days, hasLength(6));
      },
    );

    test('the options are the Firebase clients with the visit types', () async {
      remote.facilities = const [
        VisitFacility(name: 'فندق الأمواج', isContracted: false),
      ];

      final options = (await repository.getSchedulingOptions()).getOrElse(
        () => throw StateError('no options'),
      );

      expect(options.facilities.single.name, 'فندق الأمواج');
      expect(options.visitTypes, expectedOptions.visitTypes);
      expect(options.defaultTypeFor(options.facilities.single), 'فحص أولي');
    });

    test('the options carry the templates and the open actions', () async {
      openActions.actions = [expectedOpenActions.last];

      final options = (await repository.getSchedulingOptions()).getOrElse(
        () => throw StateError('no options'),
      );

      expect(options.facilities, expectedOptions.facilities);
      expect(
        options.taskCatalog.templatesBySector,
        expectedTaskCatalog.templatesBySector,
      );
      expect(options.taskCatalog.openActions, [expectedOpenActions.last]);
    });

    test(
      'a booked visit is stored in Firebase and read back into the week',
      () async {
        final result = await repository.addVisit(_layla10);

        expect(remote.added.single.toJson()['inspector_id'], 'uid-layla');
        final schedule = result.getOrElse(
          () => throw StateError('no schedule'),
        );
        expect(schedule.visits.length, 14);
        expect(schedule.visitsFor(layla, wed), [_layla10]);
      },
    );

    test('Firestore errors become failures the page can explain', () async {
      Future<Failure> failureFor(String code) async {
        remote.error = FirebaseException(plugin: 'cloud_firestore', code: code);
        return (await repository.getSchedule()).fold(
          (f) => f,
          (_) => throw StateError('no failure'),
        );
      }

      expect(await failureFor('permission-denied'), const ForbiddenFailure());
      expect(await failureFor('unavailable'), const NetworkFailure());
      expect(await failureFor('internal'), isA<UnknownFailure>());
    });
  });
}
