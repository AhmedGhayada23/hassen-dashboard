import 'package:hassen_dashboard/features/dashboard_inspection_review/domain/entities/finding.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/domain/entities/finding_severity.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/domain/entities/inspection.dart';

/// The four reports exactly as the original single-file screen hard-coded them.
/// Written independently of the data layer so tests catch any drift.
final expectedInspections = [
  Inspection(
    id: 'INS-0418',
    facility: 'مستشفى الشفاء',
    inspector: 'م. أحمد',
    date: DateTime(2026, 10, 28),
    template: 'تفتيش المنشآت الصحية v2',
    passCount: 20,
    failCount: 3,
    findings: const [
      Finding(
        title: 'مخرج الطوارئ رقم 2 تعيقه أسرّة مخزنة',
        severity: FindingSeverity.critical,
        note: 'احتواء خلال 24 ساعة',
        due: '24 ساعة',
      ),
      Finding(
        title: 'طفاية حريق منتهية الصلاحية — الطابق الأول',
        severity: FindingSeverity.high,
        note: 'استبدال الطفاية وتحديث سجل الفحص',
        due: '14 يوماً',
      ),
      Finding(
        title: 'لوحة إرشاد باهتة عند الدرج الشرقي',
        severity: FindingSeverity.medium,
        note: 'استبدال اللوحة',
        due: '30 يوماً',
      ),
    ],
  ),
  Inspection(
    id: 'INS-0417',
    facility: 'بلدية غزة',
    inspector: 'م. سارة',
    date: DateTime(2026, 10, 27),
    template: 'تفتيش المباني الإدارية v1',
    passCount: 26,
    failCount: 2,
    findings: const [
      Finding(
        title: 'تمديدات كهربائية مكشوفة في الأرشيف',
        severity: FindingSeverity.high,
        note: 'تغطية التمديدات وفحص اللوحة',
        due: '14 يوماً',
      ),
      Finding(
        title: 'صندوق إسعافات أولية ناقص',
        severity: FindingSeverity.low,
        note: 'استكمال المحتويات',
        due: 'حتى الزيارة القادمة',
      ),
    ],
  ),
  Inspection(
    id: 'INS-0416',
    facility: 'مصنع العودة',
    inspector: 'م. خالد',
    date: DateTime(2026, 10, 27),
    template: 'تفتيش المنشآت الصناعية v3',
    passCount: 31,
    failCount: 4,
    findings: const [
      Finding(
        title: 'غياب حاجز حماية على آلة القص 3',
        severity: FindingSeverity.high,
        note: 'تركيب حاجز وإيقاف الآلة حتى التركيب',
        due: '14 يوماً',
      ),
      Finding(
        title: 'انسكاب زيوت في الممر B',
        severity: FindingSeverity.medium,
        note: 'تنظيف وتوفير مواد امتصاص',
        due: '30 يوماً',
      ),
    ],
  ),
  Inspection(
    id: 'INS-0415',
    facility: 'بنك فلسطين',
    inspector: 'م. ليلى',
    date: DateTime(2026, 10, 26),
    template: 'تفتيش المكاتب والفروع v1',
    passCount: 22,
    failCount: 1,
    findings: const [
      Finding(
        title: 'مخطط الإخلاء غير محدّث — فرع الرمال',
        severity: FindingSeverity.low,
        note: 'تحديث المخطط',
        due: 'حتى الزيارة القادمة',
      ),
    ],
  ),
];
