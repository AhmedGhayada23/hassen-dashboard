import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/di/pending_reviews_bridge.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/data/datasources/inspection_review_local_datasource.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/data/repositories/inspection_review_repository_impl.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/domain/entities/inspection.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/domain/entities/inspection_decision.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/domain/repositories/inspection_review_repository.dart';
import 'package:hassen_dashboard/features/overview/domain/entities/inspection_review.dart';

class _FailingReviews implements InspectionReviewRepository {
  const _FailingReviews();

  @override
  Future<Either<Failure, List<Inspection>>> getInspections() async =>
      const Left(CacheFailure());

  @override
  Future<Either<Failure, Inspection>> updateDecision(
    String id,
    InspectionDecision decision,
  ) => throw UnimplementedError();
}

void main() {
  InspectionReviewRepositoryImpl reviewPage() =>
      InspectionReviewRepositoryImpl(InspectionReviewLocalDataSource());

  test(
    'the review page\'s pending reports, as the overview lists them',
    () async {
      expect(
        await InspectionReviewsPending(reviewPage()).getPendingReviews(),
        const [
          InspectionReview(
            id: 'INS-0418',
            facility: 'مستشفى الشفاء',
            inspector: 'م. أحمد',
            nonConformities: 3,
            isCritical: true,
          ),
          InspectionReview(
            id: 'INS-0417',
            facility: 'بلدية غزة',
            inspector: 'م. سارة',
            nonConformities: 2,
          ),
          InspectionReview(
            id: 'INS-0416',
            facility: 'مصنع العودة',
            inspector: 'م. خالد',
            nonConformities: 4,
          ),
          InspectionReview(
            id: 'INS-0415',
            facility: 'بنك فلسطين',
            inspector: 'م. ليلى',
            nonConformities: 1,
          ),
        ],
      );
    },
  );

  test('a report decided on the review page leaves the overview', () async {
    final page = reviewPage();
    await page.updateDecision('INS-0418', InspectionDecision.approved);

    final pending = await InspectionReviewsPending(page).getPendingReviews();

    expect(pending.map((r) => r.id), ['INS-0417', 'INS-0416', 'INS-0415']);
  });

  test('an unreadable review page leaves the list empty', () async {
    expect(
      await const InspectionReviewsPending(
        _FailingReviews(),
      ).getPendingReviews(),
      isEmpty,
    );
  });
}
