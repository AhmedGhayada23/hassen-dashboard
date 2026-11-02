import 'package:equatable/equatable.dart';

enum ComplianceLevel { excellent, good, needsImprovement }

/// A facility's compliance percentage (0–100).
class ComplianceRecord extends Equatable {
  final String facility;
  final int percentage;

  const ComplianceRecord({required this.facility, required this.percentage});

  ComplianceLevel get level => switch (percentage) {
    >= 90 => ComplianceLevel.excellent,
    >= 80 => ComplianceLevel.good,
    _ => ComplianceLevel.needsImprovement,
  };

  @override
  List<Object> get props => [facility, percentage];
}
