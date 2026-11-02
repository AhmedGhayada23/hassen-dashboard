import 'package:hassen_dashboard/features/dashboard_team/domain/entities/employee_role.dart';
import 'package:hassen_dashboard/features/dashboard_team/domain/entities/team_member.dart';

/// The six members exactly as the original screen listed them (ids are the
/// added technical keys). Written independently of the data layer.
const expectedTeam = [
  TeamMember(
    id: 'TM-001',
    name: 'م. أحمد',
    role: 'مفتش سلامة',
    facilities: 2,
    monthlyVisits: 18,
    lateVisits: 1,
    workload: 85,
  ),
  TeamMember(
    id: 'TM-002',
    name: 'م. سارة',
    role: 'مفتشة سلامة',
    facilities: 2,
    monthlyVisits: 16,
    lateVisits: 0,
    workload: 72,
  ),
  TeamMember(
    id: 'TM-003',
    name: 'م. خالد',
    role: 'مفتش سلامة',
    facilities: 2,
    monthlyVisits: 14,
    lateVisits: 1,
    workload: 68,
  ),
  TeamMember(
    id: 'TM-004',
    name: 'م. ليلى',
    role: 'مفتشة سلامة',
    facilities: 2,
    monthlyVisits: 9,
    lateVisits: 0,
    workload: 45,
  ),
  TeamMember(
    id: 'TM-005',
    name: 'مدير السلامة',
    role: 'الإشراف الفني والاعتماد',
    facilities: 5,
    monthlyVisits: 0,
    lateVisits: 0,
    workload: 60,
  ),
  TeamMember(
    id: 'TM-006',
    name: 'موظف العملاء والعقود',
    role: 'العروض والعقود والتجديد',
    facilities: 8,
    monthlyVisits: 0,
    lateVisits: 0,
    workload: 50,
  ),
];

/// A member exactly at the threshold (80%): not overloaded.
const memberAtThreshold = TeamMember(
  id: 'TM-T',
  name: 'م. اختبار',
  role: 'مفتش',
  facilities: 1,
  monthlyVisits: 1,
  lateVisits: 0,
  workload: 80,
);

/// The five roles exactly as the original "add employee" dialog listed them.
const expectedRoles = [
  EmployeeRole(
    id: 'inspector',
    name: 'مفتش سلامة',
    description: 'ينفّذ الزيارات من التطبيق الميداني',
    isFieldRole: true,
  ),
  EmployeeRole(
    id: 'field_follow_up',
    name: 'موظف ميداني للمتابعة',
    description: 'يتابع تنفيذ الإجراءات التصحيحية ميدانياً',
    isFieldRole: true,
  ),
  EmployeeRole(
    id: 'safety_manager',
    name: 'مدير السلامة',
    description: 'يراجع نتائج التفتيش ويعتمدها',
    isFieldRole: false,
  ),
  EmployeeRole(
    id: 'operations_manager',
    name: 'مدير العمليات',
    description: 'يجدول الزيارات ويوزعها',
    isFieldRole: false,
  ),
  EmployeeRole(
    id: 'clients_contracts',
    name: 'موظف العملاء والعقود',
    description: 'العروض والعقود والتجديد',
    isFieldRole: false,
  ),
];
