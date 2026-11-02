import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/inspection.dart';
import '../entities/inspection_decision.dart';
import '../repositories/inspection_review_repository.dart';

/// Approves report `id`, publishing its results to the facility.
class ApproveInspection extends UseCase<Inspection, String> {
  final InspectionReviewRepository repository;

  ApproveInspection(this.repository);

  @override
  Future<Either<Failure, Inspection>> call(String id) =>
      repository.updateDecision(id, InspectionDecision.approved);
}
