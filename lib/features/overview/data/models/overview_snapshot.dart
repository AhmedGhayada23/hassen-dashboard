import '../../domain/entities/compliance_record.dart';
import '../../domain/entities/contract_alert.dart';
import '../../domain/entities/critical_risk.dart';
import '../../domain/entities/dashboard_kpi.dart';
import '../../domain/entities/dashboard_overview.dart';
import '../../domain/entities/inspection_review.dart';
import '../../domain/entities/visit.dart';
import 'overview_records.dart';

/// Builds the overview from the records the other pages keep: clients,
/// this week's visits, risks, corrective actions and the inspection
/// reports awaiting review.
class OverviewSnapshot {
  OverviewSnapshot._();

  /// A risk scored this high is critical (as on the risk matrix).
  static const criticalScore = 15;

  /// A contract ending within this many days is flagged.
  static const contractAlertDays = 60;

  static DashboardOverview build({
    required List<OverviewClient> clients,
    required List<OverviewVisit> weekVisits,
    required List<OverviewRisk> risks,
    required List<OverviewAction> actions,
    required List<InspectionReview> pendingReviews,
    required DateTime today,
  }) {
    final day = DateTime(today.year, today.month, today.day);
    final contracted = clients.where((c) => c.isContracted).toList();
    final openActions = actions.where((a) => a.status != 'closed').toList();
    final lateActions = openActions.where((a) => a.dueStatus == 'late');
    final criticalRisks = [
      for (final r in risks)
        if (r.score >= criticalScore && r.status != 'monitoring')
          CriticalRisk(
            score: r.score,
            title: r.hazard,
            facility: r.facility,
            owner: r.owner,
          ),
    ]..sort((a, b) => b.score.compareTo(a.score));
    final contractAlerts = [
      for (final c in contracted)
        if (c.contractEnd case final end?)
          if (end.difference(day).inDays case final days
              when days >= 0 && days <= contractAlertDays)
            ContractAlert(client: c.name, endDate: end, daysRemaining: days),
    ]..sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));
    final todayId = _isoDate(day);
    final todayVisits = [
      for (final v
          in weekVisits.where((v) => v.date == todayId).toList()
            ..sort((a, b) => a.time.compareTo(b.time)))
        Visit(
          time: v.time,
          facility: v.facility,
          inspector: v.inspector,
          status: switch (v.status) {
            'done' => VisitStatus.done,
            'now' => VisitStatus.inProgress,
            _ => VisitStatus.planned,
          },
        ),
    ];
    int countVisits(String status) =>
        weekVisits.where((v) => v.status == status).length;
    // A KPI only takes its warning colour when there is something to see.
    KpiTone tone(int value, KpiTone alert) =>
        value == 0 ? KpiTone.neutral : alert;

    return DashboardOverview(
      kpis: [
        DashboardKpi(
          label: 'عملاء متعاقدون',
          value: contracted.length,
          subtitle: 'من أصل ${clients.length} في السجل',
          tone: KpiTone.neutral,
        ),
        DashboardKpi(
          label: 'زيارات هذا الأسبوع',
          value: weekVisits.length,
          subtitle:
              '${countVisits('done')} منجزة · ${countVisits('now')} جارية',
          tone: KpiTone.neutral,
        ),
        DashboardKpi(
          label: 'بانتظار الاعتماد',
          value: pendingReviews.length,
          subtitle: 'نتائج تفتيش',
          tone: tone(pendingReviews.length, KpiTone.warning),
        ),
        DashboardKpi(
          label: 'إجراءات متأخرة',
          value: lateActions.length,
          subtitle: 'من ${openActions.length} مفتوحة',
          tone: tone(lateActions.length, KpiTone.danger),
        ),
        DashboardKpi(
          label: 'مخاطر حرجة مفتوحة',
          value: criticalRisks.length,
          subtitle: 'من ${risks.length} في سجل المخاطر',
          tone: tone(criticalRisks.length, KpiTone.danger),
        ),
        DashboardKpi(
          label: 'عقود تنتهي قريباً',
          value: contractAlerts.length,
          subtitle: 'خلال $contractAlertDays يوماً',
          tone: tone(contractAlerts.length, KpiTone.warning),
        ),
      ],
      pendingReviews: pendingReviews,
      compliance: [
        for (final c in contracted)
          if (c.compliance case final percentage?)
            ComplianceRecord(facility: c.name, percentage: percentage),
      ],
      criticalRisks: criticalRisks,
      todayVisits: todayVisits,
      contractAlerts: contractAlerts,
      // The bell lights up while anything needs the manager's attention.
      hasUnreadNotifications:
          pendingReviews.isNotEmpty ||
          lateActions.isNotEmpty ||
          criticalRisks.isNotEmpty,
    );
  }

  /// The working week (Saturday to Thursday) holding [today]; on Friday,
  /// the week about to start. As `yyyy-MM-dd` bounds, both included.
  static (String from, String to) weekOf(DateTime today) {
    final day = DateTime.utc(today.year, today.month, today.day);
    final isFriday = day.weekday == DateTime.friday;
    final saturday = day.add(
      Duration(days: isFriday ? 1 : -((day.weekday - DateTime.saturday) % 7)),
    );
    return (
      _isoDate(saturday),
      _isoDate(saturday.add(const Duration(days: 5))),
    );
  }

  static String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
