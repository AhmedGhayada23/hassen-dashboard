import 'package:equatable/equatable.dart';

enum VisitStatus { done, inProgress, planned }

/// A scheduled inspection visit.
class Visit extends Equatable {
  final String time;
  final String facility;
  final String inspector;
  final VisitStatus status;

  const Visit({
    required this.time,
    required this.facility,
    required this.inspector,
    required this.status,
  });

  @override
  List<Object> get props => [time, facility, inspector, status];
}
