import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/features/visits/domain/usecases/get_visit_schedule.dart';

import '../../fixtures/visits_fixture.dart';
import '../../helpers/fake_visits_repository.dart';

void main() {
  test('returns the repository schedule', () async {
    final repository = FakeVisitsRepository(Right(expectedSchedule));

    final result = await GetVisitSchedule(repository)(0);

    expect(result, Right(expectedSchedule));
    expect(repository.calls, 1);
  });

  test('asks for the week it is given', () async {
    final repository = FakeVisitsRepository(Right(expectedSchedule));

    await GetVisitSchedule(repository)(-2);

    expect(repository.weekOffsets, [-2]);
  });

  test('passes repository failures through', () async {
    final repository = FakeVisitsRepository(const Left(CacheFailure()));

    expect(await GetVisitSchedule(repository)(0), const Left(CacheFailure()));
  });
}
