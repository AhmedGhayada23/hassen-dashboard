import '../../features/dashboard_inspection_review/domain/entities/finding_severity.dart';
import '../../features/dashboard_inspection_review/domain/repositories/inspection_review_repository.dart';
import '../../features/overview/data/datasources/pending_reviews_datasource.dart';
import '../../features/overview/domain/entities/inspection_review.dart';

/// Hands the overview the inspection reports still awaiting a decision,
/// from the inspection review page, so neither feature imports the other.
class InspectionReviewsPending implements PendingReviewsDataSource {
  final InspectionReviewRepository _reviews;

  const InspectionReviewsPending(this._reviews);

  /// Empty when the reports can't be read: the rest of the overview still
  /// shows.
  @override
  Future<List<InspectionReview>> getPendingReviews() async =>
      (await _reviews.getInspections()).fold(
        (_) => const [],
        (inspections) => [
          for (final i in inspections)
            if (i.isPending)
              InspectionReview(
                id: i.id,
                facility: i.facility,
                inspector: i.inspector,
                nonConformities: i.failCount,
                isCritical: i.findings.any(
                  (f) => f.severity == FindingSeverity.critical,
                ),
              ),
        ],
      );
}
