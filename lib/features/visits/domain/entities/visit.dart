import 'package:equatable/equatable.dart';

import 'inspector.dart';
import 'visit_day.dart';
import 'visit_status.dart';
import 'visit_task.dart';

class Visit extends Equatable {
  final Inspector inspector;
  final VisitDay day;
  final String time;
  final String facility;
  final String type;
  final VisitStatus status;

  /// What the inspector does on site, in order.
  final List<VisitTask> tasks;

  /// Optional note from the operations manager to the inspector.
  final String note;

  const Visit({
    required this.inspector,
    required this.day,
    required this.time,
    required this.facility,
    required this.type,
    required this.status,
    this.tasks = const [],
    this.note = '',
  });

  @override
  List<Object> get props => [
    inspector,
    day,
    time,
    facility,
    type,
    status,
    tasks,
    note,
  ];
}
