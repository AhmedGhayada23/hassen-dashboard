import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../domain/entities/compliance_record.dart';
import '../../domain/entities/contract_alert.dart';
import '../../domain/entities/critical_risk.dart';
import '../../domain/entities/dashboard_kpi.dart';
import '../../domain/entities/dashboard_overview.dart';
import '../../domain/entities/inspection_review.dart';
import '../../domain/entities/visit.dart';
import 'overview_content.dart';

/// Shimmering stand-in for the overview while Firebase loads: the real KPIs
/// and cards, drawn as bones. The values below only give the bones their
/// shape; none of their text is readable.
class OverviewSkeleton extends StatelessWidget {
  static final _overview = DashboardOverview(
    kpis: [
      for (var i = 0; i < 6; i++)
        const DashboardKpi(
          label: 'المؤشر',
          value: 0,
          subtitle: 'وصف المؤشر',
          tone: KpiTone.neutral,
        ),
    ],
    pendingReviews: [
      for (var i = 0; i < 3; i++)
        const InspectionReview(
          id: 'INS-0000',
          facility: 'اسم المنشأة',
          inspector: 'المفتش',
          nonConformities: 0,
        ),
    ],
    compliance: [
      for (var i = 0; i < 4; i++)
        const ComplianceRecord(facility: 'اسم المنشأة', percentage: 80),
    ],
    criticalRisks: const [
      CriticalRisk(
        score: 20,
        title: 'وصف الخطر',
        facility: 'اسم المنشأة',
        owner: 'المسؤول',
      ),
    ],
    todayVisits: [
      for (var i = 0; i < 3; i++)
        const Visit(
          time: '00:00',
          facility: 'اسم المنشأة',
          inspector: 'المفتش',
          status: VisitStatus.planned,
        ),
    ],
    contractAlerts: [
      ContractAlert(
        client: 'اسم العميل',
        endDate: DateTime(2026),
        daysRemaining: 30,
      ),
    ],
    hasUnreadNotifications: false,
  );

  const OverviewSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Skeletonizer(
    child: OverviewContent(
      overview: _overview,
      onKpiTap: (_) {},
      onOpenReview: () {},
      onManageContracts: () {},
    ),
  );
}
