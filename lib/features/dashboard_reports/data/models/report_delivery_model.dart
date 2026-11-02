import '../../domain/entities/monthly_report.dart';
import '../../domain/entities/report_activity.dart';
import '../../domain/entities/report_delivery.dart';

/// A `report_deliveries` document: one facility's report for one month,
/// recorded as sent. Its id is `<client id>_<yyyy-MM>`, so resending
/// replaces it.
class ReportDeliveryModel {
  ReportDeliveryModel._();

  static String idFor(String clientId, String month) => '${clientId}_$month';

  /// What is stored when [report] goes to [delivery] on [sentOn], counts
  /// included so the record stands on its own.
  static Map<String, Object?> document(
    MonthlyReport report,
    ReportDelivery delivery,
    String sentOn,
  ) => {
    'client_id': report.facility.id,
    'facility': report.facility.name,
    'month': report.month.id,
    'to': delivery.to.trim(),
    'cc': delivery.cc.trim(),
    'sent_on': sentOn,
    'file_name': report.fileName,
    'counts': {
      'inspections': report.countOf(ActivityType.inspection),
      'incidents': report.countOf(ActivityType.incident),
      'checks': report.countOf(ActivityType.check),
      'repairs': report.countOf(ActivityType.repair),
      'total': report.total,
      'open': report.openCount,
    },
  };
}
