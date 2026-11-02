import 'package:hassen_dashboard/features/dashboard_risks/domain/entities/risk.dart';
import 'package:hassen_dashboard/features/dashboard_risks/domain/entities/risk_status.dart';

/// [expectedRisks] as Firestore `risks` documents, keyed by document id.
Map<String, Map<String, Object?>> riskDocuments() => {
  for (final r in expectedRisks)
    r.id: {
      'hazard': r.hazard,
      'facility': r.facility,
      'likelihood': r.likelihood,
      'severity': r.severity,
      'owner': r.owner,
      'status': switch (r.status) {
        RiskStatus.open => 'open',
        RiskStatus.inTreatment => 'in_treatment',
        RiskStatus.monitoring => 'monitoring',
      },
      'control': r.control,
    },
};

/// The seven risks exactly as the original single-file screen hard-coded them
/// (ids are the added technical keys). Written independently of the data layer.
const expectedRisks = [
  Risk(
    id: 'RSK-001',
    hazard: 'إعاقة مسار الإخلاء',
    facility: 'مستشفى الشفاء',
    likelihood: 4,
    severity: 5,
    owner: 'مسؤول السلامة — المستشفى',
    status: RiskStatus.open,
    control: 'إزالة العوائق فوراً وتحديد منطقة تخزين بديلة',
  ),
  Risk(
    id: 'RSK-002',
    hazard: 'آلة قص دون حاجز حماية',
    facility: 'مصنع العودة',
    likelihood: 3,
    severity: 5,
    owner: 'مدير الإنتاج',
    status: RiskStatus.inTreatment,
    control: 'تركيب حاجز وتدريب المشغلين',
  ),
  Risk(
    id: 'RSK-003',
    hazard: 'تمديدات كهربائية مكشوفة',
    facility: 'بلدية غزة',
    likelihood: 3,
    severity: 4,
    owner: 'مدير الخدمات العامة',
    status: RiskStatus.open,
    control: 'تغطية التمديدات وفحص دوري للوحات',
  ),
  Risk(
    id: 'RSK-004',
    hazard: 'العمل على ارتفاع دون حماية',
    facility: 'شركة كهرباء غزة',
    likelihood: 2,
    severity: 5,
    owner: 'مهندس السلامة',
    status: RiskStatus.inTreatment,
    control: 'أحزمة أمان ونقاط تثبيت معتمدة',
  ),
  Risk(
    id: 'RSK-005',
    hazard: 'انسكاب زيوت في الممرات',
    facility: 'مصنع العودة',
    likelihood: 3,
    severity: 3,
    owner: 'مشرف الصيانة',
    status: RiskStatus.open,
    control: 'تنظيف فوري ومواد امتصاص',
  ),
  Risk(
    id: 'RSK-006',
    hazard: 'إجهاد بيئة العمل المكتبي',
    facility: 'بنك فلسطين',
    likelihood: 2,
    severity: 2,
    owner: 'مدير المرافق',
    status: RiskStatus.monitoring,
    control: 'تقييم بيئة العمل وتعديل المقاعد',
  ),
  Risk(
    id: 'RSK-007',
    hazard: 'تخزين مواد تنظيف دون ملصقات',
    facility: 'مستشفى الشفاء',
    likelihood: 2,
    severity: 3,
    owner: 'مسؤول المرافق',
    status: RiskStatus.open,
    control: 'توفير صحائف بيانات السلامة والملصقات',
  ),
];
