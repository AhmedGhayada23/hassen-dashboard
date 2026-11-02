import 'package:hassen_dashboard/features/overview/domain/entities/compliance_record.dart';
import 'package:hassen_dashboard/features/overview/domain/entities/contract_alert.dart';
import 'package:hassen_dashboard/features/overview/domain/entities/critical_risk.dart';
import 'package:hassen_dashboard/features/overview/domain/entities/dashboard_kpi.dart';
import 'package:hassen_dashboard/features/overview/domain/entities/dashboard_overview.dart';
import 'package:hassen_dashboard/features/overview/domain/entities/inspection_review.dart';
import 'package:hassen_dashboard/features/overview/domain/entities/visit.dart';

/// The overview exactly as the original single-file screen hard-coded it.
/// Written independently of the data layer so tests catch any drift.
final expectedOverview = DashboardOverview(
  kpis: const [
    DashboardKpi(
      label: 'عملاء متعاقدون',
      value: 5,
      subtitle: 'من أصل 8 في السجل',
      tone: KpiTone.neutral,
    ),
    DashboardKpi(
      label: 'زيارات هذا الأسبوع',
      value: 13,
      subtitle: '8 منجزة · 1 جارية',
      tone: KpiTone.neutral,
    ),
    DashboardKpi(
      label: 'بانتظار الاعتماد',
      value: 4,
      subtitle: 'نتائج تفتيش',
      tone: KpiTone.warning,
    ),
    DashboardKpi(
      label: 'إجراءات متأخرة',
      value: 2,
      subtitle: 'من 9 مفتوحة',
      tone: KpiTone.danger,
    ),
    DashboardKpi(
      label: 'مخاطر حرجة مفتوحة',
      value: 1,
      subtitle: 'أُبلغت المنشأة',
      tone: KpiTone.danger,
    ),
    DashboardKpi(
      label: 'عقود تنتهي قريباً',
      value: 1,
      subtitle: 'خلال 60 يوماً',
      tone: KpiTone.warning,
    ),
  ],
  pendingReviews: const [
    InspectionReview(
      id: 'INS-0418',
      facility: 'مستشفى الشفاء',
      inspector: 'م. أحمد',
      nonConformities: 3,
      isCritical: true,
    ),
    InspectionReview(
      id: 'INS-0417',
      facility: 'بلدية غزة',
      inspector: 'م. سارة',
      nonConformities: 2,
    ),
    InspectionReview(
      id: 'INS-0416',
      facility: 'مصنع العودة',
      inspector: 'م. خالد',
      nonConformities: 4,
    ),
    InspectionReview(
      id: 'INS-0415',
      facility: 'بنك فلسطين',
      inspector: 'م. ليلى',
      nonConformities: 1,
    ),
  ],
  compliance: const [
    ComplianceRecord(facility: 'مستشفى الشفاء', percentage: 82),
    ComplianceRecord(facility: 'بلدية غزة', percentage: 76),
    ComplianceRecord(facility: 'شركة كهرباء غزة', percentage: 91),
    ComplianceRecord(facility: 'مصنع العودة', percentage: 85),
    ComplianceRecord(facility: 'بنك فلسطين', percentage: 94),
  ],
  criticalRisks: const [
    CriticalRisk(
      score: 20,
      title: 'إعاقة مسار الإخلاء',
      facility: 'مستشفى الشفاء',
      owner: 'مسؤول السلامة — المستشفى',
    ),
  ],
  todayVisits: const [
    Visit(
      time: '09:00',
      facility: 'مستشفى الشفاء',
      inspector: 'م. أحمد',
      status: VisitStatus.done,
    ),
    Visit(
      time: '11:30',
      facility: 'مستشفى الشفاء',
      inspector: 'م. أحمد',
      status: VisitStatus.inProgress,
    ),
    Visit(
      time: '13:30',
      facility: 'بلدية غزة',
      inspector: 'م. سارة',
      status: VisitStatus.planned,
    ),
    Visit(
      time: '15:00',
      facility: 'مصنع العودة',
      inspector: 'م. خالد',
      status: VisitStatus.planned,
    ),
  ],
  contractAlerts: [
    ContractAlert(
      client: 'بلدية غزة',
      endDate: DateTime(2026, 12, 15),
      daysRemaining: 47,
    ),
  ],
  hasUnreadNotifications: true,
);
