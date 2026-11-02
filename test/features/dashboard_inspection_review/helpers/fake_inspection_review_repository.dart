import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/domain/entities/inspection.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/domain/entities/inspection_decision.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/domain/repositories/inspection_review_repository.dart';

import '../fixtures/inspections_fixture.dart';

/// In-memory repository with switchable failures and an optional load gate.
class FakeInspectionReviewRepository implements InspectionReviewRepository {
  List<Inspection> inspections = [...expectedInspections];
  Failure? loadFailure;
  Failure? updateFailure;
  Completer<void>? gate;
  final updates = <(String, InspectionDecision)>[];

  @override
  Future<Either<Failure, List<Inspection>>> getInspections() async {
    await gate?.future;
    return loadFailure != null ? Left(loadFailure!) : Right(inspections);
  }

  @override
  Future<Either<Failure, Inspection>> updateDecision(
    String id,
    InspectionDecision decision,
  ) async {
    updates.add((id, decision));
    if (updateFailure != null) return Left(updateFailure!);
    final updated = inspections
        .firstWhere((i) => i.id == id)
        .withDecision(decision);
    inspections = [for (final i in inspections) i.id == id ? updated : i];
    return Right(updated);
  }
}
