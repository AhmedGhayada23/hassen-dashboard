import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/inspection.dart';
import '../entities/inspection_decision.dart';

abstract interface class InspectionReviewRepository {
  Future<Either<Failure, List<Inspection>>> getInspections();

  /// Records [decision] for the report [id] and returns the updated report.
  Future<Either<Failure, Inspection>> updateDecision(
    String id,
    InspectionDecision decision,
  );
}
