import 'package:equatable/equatable.dart';

/// What kind of thing happened at a facility during the month.
enum ActivityType { inspection, incident, check, repair }

/// Where an activity stands at the end of the month.
enum ActivityStatus {
  completed,
  closed,

  /// An incident being dealt with.
  handling,

  /// A repair under way.
  inProgress,
  awaitingVerification,
  open,
  overdue,

  /// A visit booked but not carried out yet.
  scheduled;

  /// Done with: nothing to carry into next month.
  bool get isResolved =>
      this == ActivityStatus.completed || this == ActivityStatus.closed;
}

/// One line of a monthly report.
class ReportActivity extends Equatable {
  /// As `yyyy-MM-dd`.
  final String date;
  final ActivityType type;
  final String description;

  /// Who carried it out or owns it.
  final String owner;
  final ActivityStatus status;

  const ReportActivity({
    required this.date,
    required this.type,
    required this.description,
    required this.owner,
    required this.status,
  });

  @override
  List<Object> get props => [date, type, description, owner, status];
}
