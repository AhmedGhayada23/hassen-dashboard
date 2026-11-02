import 'package:equatable/equatable.dart';

import 'report_activity.dart';
import 'report_facility.dart';
import 'report_month.dart';

/// Where a facility's report for the month stands.
enum MonthlyReportStatus { sent, ready, empty }

/// The report built for one facility for one month: everything that happened
/// there, and whether it has been sent.
class MonthlyReport extends Equatable {
  final ReportFacility facility;
  final ReportMonth month;
  final List<ReportActivity> activities;

  /// When it was sent, as `yyyy-MM-dd`; null until then.
  final String? sentOn;

  const MonthlyReport({
    required this.facility,
    required this.month,
    required this.activities,
    this.sentOn,
  });

  int countOf(ActivityType type) =>
      activities.where((a) => a.type == type).length;

  int get total => activities.length;

  /// Items still open, carried into next month.
  int get openCount => activities.where((a) => !a.status.isResolved).length;

  bool get isSent => sentOn != null;

  MonthlyReportStatus get status => isSent
      ? MonthlyReportStatus.sent
      : activities.isEmpty
      ? MonthlyReportStatus.empty
      : MonthlyReportStatus.ready;

  /// The PDF it is sent as, e.g. `HASEEN-2026-10-مستشفى-الشفاء.pdf`.
  String get fileName =>
      'HASEEN-${month.id}-${facility.name.replaceAll(' ', '-')}.pdf';

  MonthlyReport sent(String on) => MonthlyReport(
    facility: facility,
    month: month,
    activities: activities,
    sentOn: on,
  );

  @override
  List<Object?> get props => [facility, month, activities, sentOn];
}
