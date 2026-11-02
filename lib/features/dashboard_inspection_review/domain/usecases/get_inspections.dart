import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/inspection.dart';
import '../repositories/inspection_review_repository.dart';

class GetInspections extends UseCase<List<Inspection>, NoParams> {
  final InspectionReviewRepository repository;

  GetInspections(this.repository);

  @override
  Future<Either<Failure, List<Inspection>>> call(NoParams params) =>
      repository.getInspections();
}
