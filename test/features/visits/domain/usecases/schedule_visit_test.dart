import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/core/usecases/usecase.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/visit.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/visit_status.dart';
import 'package:hassen_dashboard/features/visits/domain/failures/visit_clash_failure.dart';
import 'package:hassen_dashboard/features/visits/domain/usecases/get_visit_scheduling_options.dart';
import 'package:hassen_dashboard/features/visits/domain/usecases/schedule_visit.dart';

import '../../fixtures/visits_fixture.dart';
import '../../helpers/fake_visits_repository.dart';

const _free = Visit(
  inspector: layla,
  day: wed,
  time: '10:00',
  facility: 'مستشفى الشفاء',
  type: 'تفتيش دوري',
  status: VisitStatus.planned,
);

void main() {
  late FakeVisitsRepository repository;

  setUp(() => repository = FakeVisitsRepository(Right(expectedSchedule)));

  test('books a free slot and returns the updated week', () async {
    final result = await ScheduleVisit(repository)(ScheduleVisitParams(_free));

    expect(repository.added, [_free]);
    result.fold((_) => fail('expected success'), (schedule) {
      expect(schedule.visits.length, 14);
      expect(schedule.visitsFor(layla, wed), [_free]);
    });
  });

  test(
    'refuses a slot the inspector already has, without storing anything',
    () async {
      const clash = Visit(
        inspector: ahmad,
        day: mon,
        time: '10:00',
        facility: 'بنك فلسطين',
        type: 'متابعة ملاحظات',
        status: VisitStatus.planned,
      );

      final result = await ScheduleVisit(repository)(
        ScheduleVisitParams(clash),
      );

      expect(result, const Left<Failure, Never>(VisitClashFailure()));
      expect(repository.added, isEmpty);
    },
  );

  test('checks and books in the week the visit belongs to', () async {
    await ScheduleVisit(repository)(ScheduleVisitParams(_free, weekOffset: 2));

    // Read for the clash check, then written.
    expect(repository.weekOffsets, [2, 2]);
  });

  test('passes on a failure to read the week', () async {
    repository.result = const Left(CacheFailure());

    expect(
      await ScheduleVisit(repository)(ScheduleVisitParams(_free)),
      const Left<Failure, Never>(CacheFailure()),
    );
    expect(repository.added, isEmpty);
  });

  test('GetVisitSchedulingOptions returns the repository options', () async {
    expect(
      await GetVisitSchedulingOptions(repository)(const NoParams()),
      const Right(expectedOptions),
    );
  });
}
