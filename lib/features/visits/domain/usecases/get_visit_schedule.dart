import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/visit_schedule.dart';
import '../repositories/visits_repository.dart';

/// The week [weekOffset] weeks away from the current one (0 = this week).
class GetVisitSchedule extends UseCase<VisitSchedule, int> {
  final VisitsRepository repository;

  GetVisitSchedule(this.repository);

  @override
  Future<Either<Failure, VisitSchedule>> call(int weekOffset) =>
      repository.getSchedule(weekOffset: weekOffset);
}
