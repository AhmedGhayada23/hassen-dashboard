import 'package:equatable/equatable.dart';

/// A corrective action still open at a facility, for a visit to follow up.
class FacilityOpenAction extends Equatable {
  final String id;
  final String title;
  final String facility;

  /// Workflow stage and severity as worded on the actions board.
  final String statusLabel;
  final String severityLabel;

  /// The facility has uploaded evidence of the fix, to be checked on site.
  final bool hasEvidence;

  const FacilityOpenAction({
    required this.id,
    required this.title,
    required this.facility,
    required this.statusLabel,
    required this.severityLabel,
    this.hasEvidence = false,
  });

  @override
  List<Object> get props => [
    id,
    title,
    facility,
    statusLabel,
    severityLabel,
    hasEvidence,
  ];
}
