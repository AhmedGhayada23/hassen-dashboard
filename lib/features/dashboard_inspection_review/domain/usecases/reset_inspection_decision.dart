import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/inspection.dart';
import '../entities/inspection_decision.dart';
import '../repositories/inspection_review_repository.dart';

/// Undoes the decision on report `id`, putting it back in the pending queue.
class ResetInspectionDecision extends UseCase<Inspection, String> {
  final InspectionReviewRepository repository;

  ResetInspectionDecision(this.repository);

  @override
  Future<Either<Failure, Inspection>> call(String id) =>
      repository.updateDecision(id, InspectionDecision.pending);
}
