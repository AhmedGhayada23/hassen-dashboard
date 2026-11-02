import 'package:equatable/equatable.dart';

/// An inspection result waiting for approval.
class InspectionReview extends Equatable {
  /// More non-conformities than this flags the inspection as high.
  static const highNonConformityThreshold = 2;

  final String id;
  final String facility;
  final String inspector;
  final int nonConformities;
  final bool isCritical;

  const InspectionReview({
    required this.id,
    required this.facility,
    required this.inspector,
    required this.nonConformities,
    this.isCritical = false,
  });

  bool get hasHighNonConformities =>
      nonConformities > highNonConformityThreshold;

  @override
  List<Object> get props => [
    id,
    facility,
    inspector,
    nonConformities,
    isCritical,
  ];
}
