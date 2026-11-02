import 'package:hassen_dashboard/features/dashboard_contracts/data/models/deal_model.dart';
import 'package:hassen_dashboard/features/dashboard_contracts/domain/entities/contract_plan.dart';
import 'package:hassen_dashboard/features/dashboard_contracts/domain/entities/deal.dart';
import 'package:hassen_dashboard/features/dashboard_contracts/domain/entities/deal_status.dart';

const monthly = ContractPlan(id: 'm', name: 'شهر', months: 1);
const quarterly = ContractPlan(id: 'q', name: '3 شهور', months: 3);
const halfYear = ContractPlan(id: 'h', name: '6 شهور', months: 6);
const yearly = ContractPlan(id: 'y', name: 'سنوي — يتجدد تلقائياً', months: 12);

const expectedPlans = [monthly, quarterly, halfYear, yearly];

/// The original screen's clients as Firestore `clients` documents, in the
/// (shuffled) order Firestore might return them.
List<ClientRecord> clientRecords() => [
  (
    id: 'c-shifa',
    json: {
      'name': 'مستشفى الشفاء',
      'stage': 'contracted',
      'deal_status': 'accepted',
      'contract_plan': 'y',
      'contract_start': '2026-03-01',
    },
    createdAt: DateTime(2026, 2, 15),
  ),
  (
    id: 'c-mall',
    json: {'name': 'مجمع تجاري — المنطقة الوسطى', 'stage': 'quotation'},
    createdAt: DateTime(2026, 10, 20),
  ),
  (
    // Contracted before decisions were kept here: read as accepted.
    id: 'c-gaza',
    json: {
      'name': 'بلدية غزة',
      'stage': 'contracted',
      'contract_plan': 'y',
      'contract_start': '2025-12-16',
    },
    createdAt: DateTime(2025, 12, 1),
  ),
  (
    id: 'c-bank',
    json: {
      'name': 'بنك فلسطين',
      'stage': 'contracted',
      'deal_status': 'accepted',
      'contract_plan': 'y',
      'contract_start': '2026-02-01',
      'quote_number': 'Q-2026-027',
    },
    createdAt: DateTime(2026, 1, 10),
  ),
  (
    id: 'c-power',
    json: {
      'name': 'شركة كهرباء غزة',
      'stage': 'contracted',
      'deal_status': 'accepted',
      'contract_plan': 'h',
      'contract_start': '2026-07-01',
    },
    createdAt: DateTime(2025, 12, 20),
  ),
  (
    id: 'c-school',
    json: {'name': 'مدرسة خاصة — غزة', 'stage': 'potential'},
    createdAt: DateTime(2026, 10, 18),
  ),
  (
    id: 'c-factory',
    json: {
      'name': 'مصنع العودة',
      'stage': 'contracted',
      'deal_status': 'accepted',
      'contract_plan': 'y',
      'contract_start': '2026-05-01',
    },
    createdAt: DateTime(2026, 4, 12),
  ),
  (
    id: 'c-transport',
    json: {
      'name': 'شركة نقل وخدمات لوجستية',
      'stage': 'quotation',
      'deal_status': 'rejected',
    },
    createdAt: DateTime(2025, 12, 2),
  ),
];

/// The deals read from [clientRecords], oldest client first, numbered within
/// each year.
final expectedDeals = [
  Deal(
    id: 'c-gaza',
    number: 'Q-2025-001',
    client: 'بلدية غزة',
    date: '2025-12-01',
    status: DealStatus.accepted,
    planId: 'y',
    startDate: DateTime(2025, 12, 16),
  ),
  const Deal(
    id: 'c-transport',
    number: 'Q-2025-002',
    client: 'شركة نقل وخدمات لوجستية',
    date: '2025-12-02',
    status: DealStatus.rejected,
  ),
  Deal(
    id: 'c-power',
    number: 'Q-2025-003',
    client: 'شركة كهرباء غزة',
    date: '2025-12-20',
    status: DealStatus.accepted,
    planId: 'h',
    startDate: DateTime(2026, 7, 1),
  ),
  Deal(
    id: 'c-bank',
    number: 'Q-2026-027',
    client: 'بنك فلسطين',
    date: '2026-01-10',
    status: DealStatus.accepted,
    planId: 'y',
    startDate: DateTime(2026, 2, 1),
  ),
  Deal(
    id: 'c-shifa',
    number: 'Q-2026-002',
    client: 'مستشفى الشفاء',
    date: '2026-02-15',
    status: DealStatus.accepted,
    planId: 'y',
    startDate: DateTime(2026, 3, 1),
  ),
  Deal(
    id: 'c-factory',
    number: 'Q-2026-003',
    client: 'مصنع العودة',
    date: '2026-04-12',
    status: DealStatus.accepted,
    planId: 'y',
    startDate: DateTime(2026, 5, 1),
  ),
  const Deal(
    id: 'c-school',
    number: 'Q-2026-004',
    client: 'مدرسة خاصة — غزة',
    date: '2026-10-18',
    status: DealStatus.pending,
  ),
  const Deal(
    id: 'c-mall',
    number: 'Q-2026-005',
    client: 'مجمع تجاري — المنطقة الوسطى',
    date: '2026-10-20',
    status: DealStatus.pending,
  ),
];

Deal dealOf(String id) => expectedDeals.singleWhere((d) => d.id == id);
