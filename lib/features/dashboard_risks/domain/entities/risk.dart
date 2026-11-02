import 'package:equatable/equatable.dart';

import 'risk_level.dart';
import 'risk_status.dart';

/// A hazard rated on a 5 × 5 likelihood/severity scale.
class Risk extends Equatable {
  static const minRating = 1;
  static const maxRating = 5;

  static bool isValidRating(int value) =>
      value >= minRating && value <= maxRating;

  /// Stable key, so selection never depends on list position.
  final String id;
  final String hazard;
  final String facility;
  final int likelihood;
  final int severity;
  final String owner;
  final RiskStatus status;

  /// Control measure agreed for the hazard.
  final String control;

  const Risk({
    required this.id,
    required this.hazard,
    required this.facility,
    required this.likelihood,
    required this.severity,
    required this.owner,
    required this.status,
    required this.control,
  }) : assert(
         likelihood >= minRating && likelihood <= maxRating,
         'likelihood must be 1–5',
       ),
       assert(
         severity >= minRating && severity <= maxRating,
         'severity must be 1–5',
       );

  int get score => likelihood * severity;

  RiskLevel get level => RiskLevel.fromScore(score);

  @override
  List<Object> get props => [
    id,
    hazard,
    facility,
    likelihood,
    severity,
    owner,
    status,
    control,
  ];
}
