import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/dashboard_overview.dart';
import '../../domain/entities/inspection_review.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/overview_remote_datasource.dart';
import '../datasources/pending_reviews_datasource.dart';
import '../models/overview_records.dart';
import '../models/overview_snapshot.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final OverviewRemoteDataSource remoteDataSource;
  final PendingReviewsDataSource reviewsDataSource;
  final DateTime Function() _clock;

  const DashboardRepositoryImpl(
    this.remoteDataSource,
    this.reviewsDataSource, {
    DateTime Function() clock = DateTime.now,
  }) : _clock = clock;

  /// Today's overview, built from the pages' own records.
  @override
  Future<Either<Failure, DashboardOverview>> getOverview() async {
    try {
      final today = _clock();
      final (from, to) = OverviewSnapshot.weekOf(today);
      // Future.wait (unlike a record's .wait) rethrows the first error as
      // is, so a FirebaseException still reaches the catch below.
      final results = await Future.wait<Object>([
        remoteDataSource.getClients(),
        remoteDataSource.getVisits(from: from, to: to),
        remoteDataSource.getRisks(),
        remoteDataSource.getActions(),
        reviewsDataSource.getPendingReviews(),
      ]);
      return Right(
        OverviewSnapshot.build(
          clients: results[0] as List<OverviewClient>,
          weekVisits: results[1] as List<OverviewVisit>,
          risks: results[2] as List<OverviewRisk>,
          actions: results[3] as List<OverviewAction>,
          pendingReviews: results[4] as List<InspectionReview>,
          today: today,
        ),
      );
    } on FirebaseException catch (e) {
      return Left(switch (e.code) {
        'permission-denied' => const ForbiddenFailure(),
        'unavailable' => const NetworkFailure(),
        _ => UnknownFailure(message: e.message ?? e.code),
      });
    } on AppException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }
}
