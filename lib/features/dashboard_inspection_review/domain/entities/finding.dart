import 'package:equatable/equatable.dart';

import 'finding_severity.dart';

/// A non-conformity recorded during an inspection.
class Finding extends Equatable {
  final String title;
  final FindingSeverity severity;
  final String note;

  /// Correction deadline as worded for the facility (e.g. "14 يوماً").
  final String due;

  const Finding({
    required this.title,
    required this.severity,
    required this.note,
    required this.due,
  });

  @override
  List<Object> get props => [title, severity, note, due];
}
