import 'package:equatable/equatable.dart';

/// Where a visit task came from.
enum VisitTaskSource {
  /// The facility's inspection template, picked by its sector.
  template,

  /// Checking one of the facility's open corrective actions.
  correctiveAction,

  /// Added by hand by the operations manager.
  manual,
}

/// One thing the inspector does on a visit, as listed in the field app.
class VisitTask extends Equatable {
  final String id;
  final String title;

  /// Extra line under the title; empty for a hand-added task.
  final String detail;
  final VisitTaskSource source;

  const VisitTask({
    required this.id,
    required this.title,
    this.detail = '',
    required this.source,
  });

  @override
  List<Object> get props => [id, title, detail, source];
}
