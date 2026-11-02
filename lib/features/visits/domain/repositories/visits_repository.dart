import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/visit.dart';
import '../entities/visit_schedule.dart';
import '../entities/visit_scheduling_options.dart';

/// Weeks are addressed by their offset from the current one: 0 is this week,
/// -1 the one before, 1 the one after.
abstract interface class VisitsRepository {
  Future<Either<Failure, VisitSchedule>> getSchedule({int weekOffset = 0});

  Future<Either<Failure, VisitSchedulingOptions>> getSchedulingOptions();

  /// Stores [visit] and returns its week, [weekOffset], updated.
  Future<Either<Failure, VisitSchedule>> addVisit(
    Visit visit, {
    int weekOffset = 0,
  });
}
