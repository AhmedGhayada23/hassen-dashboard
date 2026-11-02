import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/constants/app_icons.dart';
import 'package:hassen_dashboard/core/constants/asset_paths.dart';
import 'package:hassen_dashboard/core/routes/routes.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/domain/entities/nav_destination.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/presentation/config/dashboard_navigation_config.dart';

void main() {
  test('groups keep the original titles and order', () {
    expect(dashboardNavGroups.map((g) => g.title), [
      'التشغيل',
      'العملاء',
      'السلامة',
      'الإدارة',
    ]);
  });

  test('items keep the original Arabic labels, order and grouping', () {
    expect(
      dashboardNavGroups.map((g) => g.items.map((i) => i.label).toList()),
      [
        ['نظرة عامة', 'جدول الزيارات', 'مراجعة التفتيش', 'الإجراءات التصحيحية'],
        ['العملاء والمنشآت', 'العروض والعقود'],
        ['سجل المخاطر', 'التقارير'],
        ['الفريق', 'الإعدادات'],
      ],
    );
  });

  test('every destination appears exactly once', () {
    final destinations = [
      for (final g in dashboardNavGroups) ...g.items.map((i) => i.destination),
    ];

    expect(destinations, unorderedEquals(NavDestination.values));
  });

  test('each item uses its HASEEN SVG icon', () {
    final icons = {
      for (final g in dashboardNavGroups)
        for (final i in g.items) i.label: i.destination.iconAsset,
    };

    expect(icons, {
      'نظرة عامة': AppIcons.home,
      'جدول الزيارات': AppIcons.calendar,
      'مراجعة التفتيش': AppIcons.clipboardCheck,
      'الإجراءات التصحيحية': AppIcons.checkCircle,
      'العملاء والمنشآت': AppIcons.building,
      'العروض والعقود': AppIcons.document,
      'سجل المخاطر': AppIcons.alertTriangle,
      'التقارير': AppIcons.barChart,
      'الفريق': AppIcons.hardHat,
      'الإعدادات': AppIcons.settings,
    });
  });

  test('badges and alert flags match the original sidebar', () {
    final badges = {
      for (final g in dashboardNavGroups)
        for (final i in g.items)
          if (i.hasBadge) i.label: (i.badgeCount, i.isAlert),
    };

    expect(badges, {
      'مراجعة التفتيش': (4, false),
      'الإجراءات التصحيحية': (3, true),
      'العروض والعقود': (1, false),
    });
  });

  test('every destination opens its page', () {
    final routed = {
      for (final d in NavDestination.values)
        if (d.route != null) d: d.route,
    };

    expect(routed, {
      NavDestination.overview: Routes.overview,
      NavDestination.visitSchedule: Routes.visits,
      NavDestination.inspectionReview: Routes.inspectionReview,
      NavDestination.correctiveActions: Routes.correctiveActions,
      NavDestination.clients: Routes.clients,
      NavDestination.contracts: Routes.contracts,
      NavDestination.riskRegister: Routes.risks,
      NavDestination.reports: Routes.reports,
      NavDestination.team: Routes.team,
      NavDestination.settings: Routes.settings,
    });
  });

  test('sidebar profile keeps the original user', () {
    expect(sidebarProfile, (
      name: 'مدير العمليات',
      organization: 'شركة الحصين',
    ));
  });

  test('every icon and the logo exist on disk', () {
    final assets = [
      for (final d in NavDestination.values) d.iconAsset,
      AppIcons.search,
      AppIcons.user,
      AppIcons.bell,
      AppIcons.clock,
      AssetPaths.haseenLogo,
    ];

    for (final path in assets) {
      expect(File(path).existsSync(), isTrue, reason: path);
    }
  });
}
