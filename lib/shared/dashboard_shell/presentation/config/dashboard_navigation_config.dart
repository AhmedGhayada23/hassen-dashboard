import '../../../../core/constants/app_icons.dart';
import '../../../../core/routes/routes.dart';
import '../../domain/entities/nav_destination.dart';
import '../../domain/entities/nav_group.dart';
import '../../domain/entities/nav_item.dart';

/// Static sidebar menu. Kept in presentation because it has no real data source yet.
const dashboardNavGroups = <NavGroup>[
  NavGroup(
    title: 'التشغيل',
    items: [
      NavItem(destination: NavDestination.overview, label: 'نظرة عامة'),
      NavItem(
        destination: NavDestination.visitSchedule,
        label: 'جدول الزيارات',
      ),
      NavItem(
        destination: NavDestination.inspectionReview,
        label: 'مراجعة التفتيش',
        badgeCount: 4,
      ),
      NavItem(
        destination: NavDestination.correctiveActions,
        label: 'الإجراءات التصحيحية',
        badgeCount: 3,
        isAlert: true,
      ),
    ],
  ),
  NavGroup(
    title: 'العملاء',
    items: [
      NavItem(destination: NavDestination.clients, label: 'العملاء والمنشآت'),
      NavItem(
        destination: NavDestination.contracts,
        label: 'العروض والعقود',
        badgeCount: 1,
      ),
    ],
  ),
  NavGroup(
    title: 'السلامة',
    items: [
      NavItem(destination: NavDestination.riskRegister, label: 'سجل المخاطر'),
      NavItem(destination: NavDestination.reports, label: 'التقارير'),
    ],
  ),
  NavGroup(
    title: 'الإدارة',
    items: [
      NavItem(destination: NavDestination.team, label: 'الفريق'),
      NavItem(destination: NavDestination.settings, label: 'الإعدادات'),
    ],
  ),
];

/// Signed-in user shown at the bottom of the sidebar.
typedef SidebarProfile = ({String name, String organization});

const SidebarProfile sidebarProfile = (
  name: 'مدير العمليات',
  organization: 'شركة الحصين',
);

/// Demo unread state for the header bell on pages whose data has no notifications feed.
const demoHasUnreadNotifications = true;

/// Sidebar SVG icon (from `assets/icons/`) for each destination.
extension NavDestinationIcon on NavDestination {
  String get iconAsset => switch (this) {
    NavDestination.overview => AppIcons.home,
    NavDestination.visitSchedule => AppIcons.calendar,
    NavDestination.inspectionReview => AppIcons.clipboardCheck,
    NavDestination.correctiveActions => AppIcons.checkCircle,
    NavDestination.clients => AppIcons.building,
    NavDestination.contracts => AppIcons.document,
    NavDestination.riskRegister => AppIcons.alertTriangle,
    NavDestination.reports => AppIcons.barChart,
    NavDestination.team => AppIcons.hardHat,
    NavDestination.settings => AppIcons.settings,
  };
}

/// Named route for destinations that have a page; null for those not built yet.
extension NavDestinationRoute on NavDestination {
  String? get route => switch (this) {
    NavDestination.overview => Routes.overview,
    NavDestination.visitSchedule => Routes.visits,
    NavDestination.inspectionReview => Routes.inspectionReview,
    NavDestination.correctiveActions => Routes.correctiveActions,
    NavDestination.clients => Routes.clients,
    NavDestination.contracts => Routes.contracts,
    NavDestination.riskRegister => Routes.risks,
    NavDestination.reports => Routes.reports,
    NavDestination.team => Routes.team,
    NavDestination.settings => Routes.settings,
  };
}
