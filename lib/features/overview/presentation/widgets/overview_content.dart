import 'package:flutter/material.dart';

import '../../../../shared/dashboard_shell/presentation/config/dashboard_layout_config.dart';
import '../../domain/entities/dashboard_kpi.dart';
import '../../domain/entities/dashboard_overview.dart';
import '../config/overview_layout_config.dart';
import 'compliance/compliance_card.dart';
import 'contracts/contract_alert_card.dart';
import 'inspections/inspection_review_card.dart';
import 'kpi/dashboard_kpi_grid.dart';
import 'risks/critical_risk_card.dart';
import 'visits/today_visits_card.dart';

/// The overview's KPIs and cards, laid out as in the original screen.
class OverviewContent extends StatelessWidget {
  final DashboardOverview overview;
  final ValueChanged<DashboardKpi> onKpiTap;
  final VoidCallback onOpenReview;
  final VoidCallback onManageContracts;

  const OverviewContent({
    super.key,
    required this.overview,
    required this.onKpiTap,
    required this.onOpenReview,
    required this.onManageContracts,
  });

  @override
  Widget build(BuildContext context) {
    final cardGap = SizedBox(width: OverviewLayoutConfig.cardGap);
    return SingleChildScrollView(
      padding: DashboardLayoutConfig.contentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DashboardKpiGrid(kpis: overview.kpis, onKpiTap: onKpiTap),
          SizedBox(height: DashboardLayoutConfig.sectionGap),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 16,
                  child: InspectionReviewCard(
                    reviews: overview.pendingReviews,
                    onOpenReview: onOpenReview,
                  ),
                ),
                cardGap,
                Expanded(
                  flex: 10,
                  child: ComplianceCard(records: overview.compliance),
                ),
              ],
            ),
          ),
          SizedBox(height: DashboardLayoutConfig.sectionGap),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: CriticalRiskCard(risks: overview.criticalRisks),
                ),
                cardGap,
                Expanded(child: TodayVisitsCard(visits: overview.todayVisits)),
                cardGap,
                Expanded(
                  child: ContractAlertCard(
                    alerts: overview.contractAlerts,
                    onManageContracts: onManageContracts,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
