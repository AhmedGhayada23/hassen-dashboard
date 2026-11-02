import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/visit.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/visit_schedule.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/visit_scheduling_options.dart';
import 'package:hassen_dashboard/features/visits/domain/repositories/visits_repository.dart';

import '../fixtures/visits_fixture.dart';

/// Repository stub: returns [result], optionally held until [gate] completes.
/// [addVisit] appends to [result] (or answers [addFailure]) and records [added].
/// Every week asked for is recorded in [weekOffsets].
class FakeVisitsRepository implements VisitsRepository {
  Either<Failure, VisitSchedule> result;
  Either<Failure, VisitSchedulingOptions> optionsResult = const Right(
    expectedOptions,
  );
  Failure? addFailure;
  Completer<void>? gate;
  int calls = 0;
  final added = <Visit>[];
  final weekOffsets = <int>[];

  FakeVisitsRepository(this.result);

  @override
  Future<Either<Failure, VisitSchedule>> getSchedule({
    int weekOffset = 0,
  }) async {
    calls++;
    weekOffsets.add(weekOffset);
    await gate?.future;
    return result;
  }

  @override
  Future<Either<Failure, VisitSchedulingOptions>>
  getSchedulingOptions() async => optionsResult;

  @override
  Future<Either<Failure, VisitSchedule>> addVisit(
    Visit visit, {
    int weekOffset = 0,
  }) async {
    added.add(visit);
    weekOffsets.add(weekOffset);
    if (addFailure case final failure?) return Left(failure);
    final current = result.getOrElse(
      () => throw StateError('No schedule to add to.'),
    );
    result = Right(
      VisitSchedule(
        weekLabel: current.weekLabel,
        inspectors: current.inspectors,
        days: current.days,
        today: current.today,
        visits: [...current.visits, visit],
      ),
    );
    return result;
  }
}
