import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/visit.dart';
import '../entities/visit_schedule.dart';
import '../failures/visit_clash_failure.dart';
import '../repositories/visits_repository.dart';

/// Books a visit unless its inspector is already busy at that slot.
class ScheduleVisit extends UseCase<VisitSchedule, ScheduleVisitParams> {
  final VisitsRepository repository;

  ScheduleVisit(this.repository);

  @override
  Future<Either<Failure, VisitSchedule>> call(
    ScheduleVisitParams params,
  ) async {
    final current = await repository.getSchedule(weekOffset: params.weekOffset);
    return current.fold(Left.new, (schedule) {
      final visit = params.visit;
      if (schedule.hasClash(visit.inspector, visit.day, visit.time)) {
        return const Left(VisitClashFailure());
      }
      return repository.addVisit(visit, weekOffset: params.weekOffset);
    });
  }
}

/// [visit] falls in the week [weekOffset] weeks from the current one.
class ScheduleVisitParams extends Equatable {
  final Visit visit;
  final int weekOffset;

  const ScheduleVisitParams(this.visit, {this.weekOffset = 0});

  @override
  List<Object> get props => [visit, weekOffset];
}
