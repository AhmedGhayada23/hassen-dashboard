import '../../domain/entities/inspection_review.dart';

/// The inspection reports awaiting review, from the inspection review
/// page. The app's composition root supplies the implementation, so this
/// feature doesn't depend on that one.
abstract interface class PendingReviewsDataSource {
  Future<List<InspectionReview>> getPendingReviews();
}
