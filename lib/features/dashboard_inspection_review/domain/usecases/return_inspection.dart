import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/inspection.dart';
import '../entities/inspection_decision.dart';
import '../repositories/inspection_review_repository.dart';

/// Sends report `id` back to its inspector with notes.
class ReturnInspection extends UseCase<Inspection, String> {
  final InspectionReviewRepository repository;

  ReturnInspection(this.repository);

  @override
  Future<Either<Failure, Inspection>> call(String id) =>
      repository.updateDecision(id, InspectionDecision.returned);
}
