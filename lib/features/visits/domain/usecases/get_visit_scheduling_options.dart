import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/visit_scheduling_options.dart';
import '../repositories/visits_repository.dart';

class GetVisitSchedulingOptions
    extends UseCase<VisitSchedulingOptions, NoParams> {
  final VisitsRepository repository;

  GetVisitSchedulingOptions(this.repository);

  @override
  Future<Either<Failure, VisitSchedulingOptions>> call(NoParams params) =>
      repository.getSchedulingOptions();
}
