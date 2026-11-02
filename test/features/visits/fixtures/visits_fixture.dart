import 'package:hassen_dashboard/features/visits/domain/entities/facility_open_action.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/inspection_template.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/inspector.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/visit.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/visit_day.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/visit_facility.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/visit_schedule.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/visit_scheduling_options.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/visit_status.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/visit_task_catalog.dart';

/// The week exactly as the original single-file screen hard-coded it.
/// Written independently of the data layer so tests catch any drift.
const ahmad = Inspector(id: 'uid-ahmad', name: 'م. أحمد');
const sara = Inspector(id: 'uid-sara', name: 'م. سارة');
const khaled = Inspector(id: 'uid-khaled', name: 'م. خالد');
const layla = Inspector(id: 'uid-layla', name: 'م. ليلى');

/// The week the fixture visits fall in; tests pin the clock to [fixtureNow].
final fixtureNow = DateTime(2026, 10, 28, 9, 30);

const sat = VisitDay(order: 0, label: 'السبت 24', date: '2026-10-24');
const sun = VisitDay(order: 1, label: 'الأحد 25', date: '2026-10-25');
const mon = VisitDay(order: 2, label: 'الإثنين 26', date: '2026-10-26');
const tue = VisitDay(order: 3, label: 'الثلاثاء 27', date: '2026-10-27');
const wed = VisitDay(order: 4, label: 'الأربعاء 28', date: '2026-10-28');
const thu = VisitDay(order: 5, label: 'الخميس 29', date: '2026-10-29');

Visit _v(
  Inspector i,
  VisitDay d,
  String time,
  String facility,
  String type,
  VisitStatus s,
) => Visit(
  inspector: i,
  day: d,
  time: time,
  facility: facility,
  type: type,
  status: s,
);

final expectedSchedule = VisitSchedule(
  weekLabel: 'الأسبوع 24 – 29 أكتوبر 2026',
  inspectors: const [ahmad, sara, khaled, layla],
  days: const [sat, sun, mon, tue, wed, thu],
  today: wed,
  visits: [
    _v(ahmad, sat, '09:00', 'مستشفى الشفاء', 'تفتيش دوري', VisitStatus.done),
    _v(ahmad, mon, '10:00', 'مستشفى الشفاء', 'تفتيش دوري', VisitStatus.done),
    _v(ahmad, wed, '09:00', 'مستشفى الشفاء', 'تفتيش دوري', VisitStatus.done),
    _v(
      ahmad,
      wed,
      '11:30',
      'مستشفى الشفاء',
      'متابعة ملاحظات',
      VisitStatus.inProgress,
    ),
    _v(sara, sun, '09:30', 'بلدية غزة', 'تفتيش دوري', VisitStatus.done),
    _v(sara, tue, '10:00', 'بلدية غزة', 'تفتيش دوري', VisitStatus.done),
    _v(sara, wed, '13:30', 'بلدية غزة', 'تفتيش دوري', VisitStatus.planned),
    _v(sara, thu, '11:00', 'مجمع تجاري', 'فحص أولي', VisitStatus.preContract),
    _v(khaled, sat, '08:30', 'شركة كهرباء غزة', 'تفتيش دوري', VisitStatus.done),
    _v(khaled, tue, '09:00', 'مصنع العودة', 'تفتيش دوري', VisitStatus.done),
    _v(khaled, wed, '15:00', 'مصنع العودة', 'متابعة', VisitStatus.planned),
    _v(layla, mon, '10:30', 'بنك فلسطين', 'تفتيش دوري', VisitStatus.done),
    _v(
      layla,
      thu,
      '09:00',
      'مدرسة خاصة',
      'معاينة أولية',
      VisitStatus.preContract,
    ),
  ],
);

/// The corrective actions the original screen listed as not closed.
const expectedOpenActions = [
  FacilityOpenAction(
    id: 'CA-0431',
    title: 'إزالة الأسرّة من أمام مخرج الطوارئ 2',
    facility: 'مستشفى الشفاء',
    statusLabel: 'مفتوح',
    severityLabel: 'حرج',
  ),
  FacilityOpenAction(
    id: 'CA-0428',
    title: 'تغطية التمديدات في الأرشيف',
    facility: 'بلدية غزة',
    statusLabel: 'مفتوح',
    severityLabel: 'عالٍ',
  ),
  FacilityOpenAction(
    id: 'CA-0412',
    title: 'تركيب حاجز على آلة القص 3',
    facility: 'مصنع العودة',
    statusLabel: 'قيد التنفيذ',
    severityLabel: 'عالٍ',
  ),
  FacilityOpenAction(
    id: 'CA-0405',
    title: 'تركيب نقاط تثبيت للعمل على ارتفاع',
    facility: 'شركة كهرباء غزة',
    statusLabel: 'قيد التنفيذ',
    severityLabel: 'عالٍ',
  ),
  FacilityOpenAction(
    id: 'CA-0399',
    title: 'توفير ملصقات لمواد التنظيف',
    facility: 'مستشفى الشفاء',
    statusLabel: 'قيد التنفيذ',
    severityLabel: 'متوسط',
  ),
  FacilityOpenAction(
    id: 'CA-0398',
    title: 'تحديث لوحات الإرشاد',
    facility: 'بلدية غزة',
    statusLabel: 'دليل مرفوع',
    severityLabel: 'متوسط',
    hasEvidence: true,
  ),
  FacilityOpenAction(
    id: 'CA-0390',
    title: 'استبدال طفايات منتهية',
    facility: 'بنك فلسطين',
    statusLabel: 'دليل مرفوع',
    severityLabel: 'عالٍ',
    hasEvidence: true,
  ),
];

/// The original's inspection templates by sector.
const expectedTaskCatalog = VisitTaskCatalog(
  templatesBySector: {
    'منشأة صحية': InspectionTemplate(
      name: 'تفتيش المنشآت الصحية v2',
      itemCount: 38,
    ),
    'منشأة صناعية': InspectionTemplate(
      name: 'تفتيش المنشآت الصناعية v3',
      itemCount: 42,
    ),
    'الطاقة والمرافق': InspectionTemplate(
      name: 'تفتيش المنشآت الصناعية v3',
      itemCount: 42,
    ),
    'خدمات مصرفية': InspectionTemplate(
      name: 'تفتيش المكاتب والفروع v1',
      itemCount: 23,
    ),
  },
  defaultTemplate: InspectionTemplate(
    name: 'تفتيش المباني الإدارية v1',
    itemCount: 28,
  ),
  preContractTemplate: InspectionTemplate(
    name: 'الفحص الأولي قبل التعاقد v2',
    itemCount: 30,
  ),
  openActions: expectedOpenActions,
);

/// Booking choices exactly as the original dialog listed them, with the
/// sectors and tasks it drew on.
const expectedOptions = VisitSchedulingOptions(
  facilities: [
    VisitFacility(
      name: 'مستشفى الشفاء',
      isContracted: true,
      sector: 'منشأة صحية',
    ),
    VisitFacility(
      name: 'بلدية غزة',
      isContracted: true,
      sector: 'مؤسسة حكومية',
    ),
    VisitFacility(
      name: 'شركة كهرباء غزة',
      isContracted: true,
      sector: 'الطاقة والمرافق',
    ),
    VisitFacility(
      name: 'مصنع العودة',
      isContracted: true,
      sector: 'منشأة صناعية',
    ),
    VisitFacility(
      name: 'بنك فلسطين',
      isContracted: true,
      sector: 'خدمات مصرفية',
    ),
    VisitFacility(name: 'مجمع تجاري — المنطقة الوسطى', isContracted: false),
    VisitFacility(name: 'مدرسة خاصة — غزة', isContracted: false),
    VisitFacility(name: 'شركة نقل وخدمات لوجستية', isContracted: false),
  ],
  visitTypes: ['تفتيش دوري', 'متابعة ملاحظات', 'فحص أولي'],
  routineType: 'تفتيش دوري',
  preContractType: 'فحص أولي',
  taskCatalog: expectedTaskCatalog,
);
