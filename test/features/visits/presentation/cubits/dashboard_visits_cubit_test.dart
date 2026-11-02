import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/visit.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/visit_status.dart';
import 'package:hassen_dashboard/features/visits/domain/failures/visit_clash_failure.dart';
import 'package:hassen_dashboard/features/visits/domain/usecases/get_visit_schedule.dart';
import 'package:hassen_dashboard/features/visits/domain/usecases/get_visit_scheduling_options.dart';
import 'package:hassen_dashboard/features/visits/domain/usecases/schedule_visit.dart';
import 'package:hassen_dashboard/features/visits/presentation/cubits/dashboard_visits_cubit.dart';
import 'package:hassen_dashboard/features/visits/presentation/cubits/dashboard_visits_state.dart';

import '../../../../helpers/cubit_emissions.dart';
import '../../fixtures/visits_fixture.dart';
import '../../helpers/fake_visits_repository.dart';

void main() {
  late FakeVisitsRepository repository;
  late DashboardVisitsCubit cubit;

  setUp(() {
    repository = FakeVisitsRepository(Right(expectedSchedule));
    cubit = DashboardVisitsCubit(
      GetVisitSchedule(repository),
      GetVisitSchedulingOptions(repository),
      ScheduleVisit(repository),
    );
  });
  tearDown(() => cubit.close());

  test('starts in the initial state without loading', () {
    expect(cubit.state, const DashboardVisitsInitial());
    expect(repository.calls, 0);
  });

  test('is loading while the use case runs', () async {
    repository.gate = Completer<void>();

    final pending = cubit.load();

    expect(cubit.state, const DashboardVisitsLoading());
    repository.gate!.complete();
    await pending;
  });

  test('emits loading then the full schedule', () async {
    final states = await emissionsOf(cubit, cubit.load);

    expect(states, [
      const DashboardVisitsLoading(),
      DashboardVisitsLoaded(expectedSchedule, expectedOptions),
    ]);
  });

  test('emits loading then failure, and recovers on retry', () async {
    repository.result = const Left(CacheFailure(message: 'boom'));
    final states = await emissionsOf(cubit, cubit.load);
    expect(states, [
      const DashboardVisitsLoading(),
      const DashboardVisitsFailure(CacheFailure(message: 'boom')),
    ]);

    repository.result = Right(expectedSchedule);
    await cubit.load();
    expect(
      cubit.state,
      DashboardVisitsLoaded(expectedSchedule, expectedOptions),
    );
  });

  test('fails to load when the booking options cannot be read', () async {
    repository.optionsResult = const Left(CacheFailure(message: 'options'));

    await cubit.load();

    expect(
      cubit.state,
      const DashboardVisitsFailure(CacheFailure(message: 'options')),
    );
  });

  group('scheduleVisit', () {
    const visit = Visit(
      inspector: layla,
      day: wed,
      time: '10:00',
      facility: 'مستشفى الشفاء',
      type: 'تفتيش دوري',
      status: VisitStatus.planned,
    );

    test('adds the visit and reports it once', () async {
      await cubit.load();

      await cubit.scheduleVisit(visit);

      final state = cubit.state as DashboardVisitsLoaded;
      expect(state.schedule.visits, [...expectedSchedule.visits, visit]);
      expect(
        (state.lastScheduled, state.actionFailure, state.options),
        (visit, null, expectedOptions),
      );
    });

    test('keeps the week and reports the failure when booking fails', () async {
      await cubit.load();
      repository.addFailure = const CacheFailure();

      await cubit.scheduleVisit(visit);

      expect(
        cubit.state,
        DashboardVisitsLoaded(
          expectedSchedule,
          expectedOptions,
          actionFailure: const CacheFailure(),
        ),
      );
    });

    test('a clash is refused with VisitClashFailure', () async {
      await cubit.load();

      await cubit.scheduleVisit(
        const Visit(
          inspector: ahmad,
          day: mon,
          time: '10:00',
          facility: 'f',
          type: 't',
          status: VisitStatus.planned,
        ),
      );

      expect(
        (cubit.state as DashboardVisitsLoaded).actionFailure,
        const VisitClashFailure(),
      );
      expect(repository.added, isEmpty);
    });

    test('is ignored before the week has loaded', () async {
      await cubit.scheduleVisit(visit);

      expect(cubit.state, const DashboardVisitsInitial());
      expect(repository.added, isEmpty);
    });

    test('books into the week shown and stays on it', () async {
      await cubit.showWeek(1);
      repository.weekOffsets.clear();

      await cubit.scheduleVisit(visit);

      expect(repository.weekOffsets, [1, 1]);
      expect((cubit.state as DashboardVisitsLoaded).weekOffset, 1);
    });
  });

  group('weeks', () {
    test('starts on the current week', () async {
      await cubit.load();

      expect(repository.weekOffsets, [0]);
      expect((cubit.state as DashboardVisitsLoaded).weekOffset, 0);
    });

    test('next, previous and back to the current week', () async {
      await cubit.load();

      await cubit.showNextWeek();
      await cubit.showNextWeek();
      expect((cubit.state as DashboardVisitsLoaded).weekOffset, 2);

      await cubit.showPreviousWeek();
      expect((cubit.state as DashboardVisitsLoaded).weekOffset, 1);

      await cubit.showCurrentWeek();
      expect(repository.weekOffsets, [0, 1, 2, 1, 0]);
      expect((cubit.state as DashboardVisitsLoaded).weekOffset, 0);
    });

    test('a retry reloads the week that failed, not the current one', () async {
      repository.result = const Left(CacheFailure());
      await cubit.showWeek(-1);
      expect(cubit.state, const DashboardVisitsFailure(CacheFailure()));

      repository.result = Right(expectedSchedule);
      await cubit.load();

      expect(repository.weekOffsets, [-1, -1]);
      expect((cubit.state as DashboardVisitsLoaded).weekOffset, -1);
    });

    test('a slow week is dropped once another has been asked for', () async {
      final gate = repository.gate = Completer<void>();
      final slow = cubit.showWeek(3);
      repository.gate = null;
      await cubit.showWeek(1);

      final states = <DashboardVisitsState>[];
      final sub = cubit.stream.listen(states.add);
      gate.complete();
      await slow;
      await sub.cancel();

      expect(states, isEmpty);
      expect((cubit.state as DashboardVisitsLoaded).weekOffset, 1);
    });
  });
}
