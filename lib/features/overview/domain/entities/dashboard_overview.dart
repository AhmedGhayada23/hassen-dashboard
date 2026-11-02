import 'package:equatable/equatable.dart';

import 'compliance_record.dart';
import 'contract_alert.dart';
import 'critical_risk.dart';
import 'dashboard_kpi.dart';
import 'inspection_review.dart';
import 'visit.dart';

/// Everything the overview screen shows, loaded as one snapshot.
class DashboardOverview extends Equatable {
  final List<DashboardKpi> kpis;
  final List<InspectionReview> pendingReviews;
  final List<ComplianceRecord> compliance;
  final List<CriticalRisk> criticalRisks;
  final List<Visit> todayVisits;
  final List<ContractAlert> contractAlerts;
  final bool hasUnreadNotifications;

  const DashboardOverview({
    required this.kpis,
    required this.pendingReviews,
    required this.compliance,
    required this.criticalRisks,
    required this.todayVisits,
    required this.contractAlerts,
    required this.hasUnreadNotifications,
  });

  @override
  List<Object> get props => [
    kpis,
    pendingReviews,
    compliance,
    criticalRisks,
    todayVisits,
    contractAlerts,
    hasUnreadNotifications,
  ];
}
