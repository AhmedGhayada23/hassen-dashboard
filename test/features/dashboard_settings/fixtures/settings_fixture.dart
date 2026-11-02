import 'package:hassen_dashboard/features/dashboard_settings/domain/entities/inspection_template.dart';
import 'package:hassen_dashboard/features/dashboard_settings/domain/entities/operation_rule.dart';
import 'package:hassen_dashboard/features/dashboard_settings/domain/entities/system_role.dart';

/// The settings exactly as the original screen hard-coded them. Written
/// independently of the data layer so tests catch any drift.
const expectedTemplates = [
  InspectionTemplate(name: 'تفتيش المنشآت الصحية', version: 'v2', items: 38),
  InspectionTemplate(name: 'تفتيش المنشآت الصناعية', version: 'v3', items: 42),
  InspectionTemplate(name: 'تفتيش المباني الإدارية', version: 'v1', items: 28),
  InspectionTemplate(name: 'تفتيش المكاتب والفروع', version: 'v1', items: 23),
  InspectionTemplate(
    name: 'الفحص الأولي قبل التعاقد',
    version: 'v2',
    items: 30,
  ),
];

const expectedRoles = [
  SystemRole(
    name: 'مدير الشركة',
    usersCount: 1,
    organization: RoleOrganization.haseen,
  ),
  SystemRole(
    name: 'مدير العمليات',
    usersCount: 1,
    organization: RoleOrganization.haseen,
  ),
  SystemRole(
    name: 'مدير السلامة',
    usersCount: 1,
    organization: RoleOrganization.haseen,
  ),
  SystemRole(
    name: 'مفتش السلامة',
    usersCount: 4,
    organization: RoleOrganization.haseen,
  ),
  SystemRole(
    name: 'موظف العملاء والعقود',
    usersCount: 1,
    organization: RoleOrganization.haseen,
  ),
  SystemRole(
    name: 'مدير حساب المنشأة',
    usersCount: 5,
    organization: RoleOrganization.facility,
  ),
  SystemRole(
    name: 'مسؤول السلامة لدى المنشأة',
    usersCount: 7,
    organization: RoleOrganization.facility,
  ),
];

const expectedRules = [
  OperationRule(title: 'منهجية التقييم', value: 'الاحتمال × الشدة (5×5)'),
  OperationRule(
    title: 'مهلة الخطر الحرج',
    value: 'احتواء 24 ساعة · معالجة 7 أيام',
  ),
  OperationRule(title: 'مهلة الخطر العالي', value: '14 يوماً'),
  OperationRule(title: 'مهلة الخطر المتوسط', value: '30 يوماً'),
  OperationRule(title: 'مدة مراجعة نتائج التفتيش', value: 'يوما عمل'),
  OperationRule(title: 'تنبيه انتهاء العقد', value: 'قبل 60 و30 يوماً'),
  OperationRule(title: 'التصعيد', value: 'بعد 7 أيام تأخير'),
];
