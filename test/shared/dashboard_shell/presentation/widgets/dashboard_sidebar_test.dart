import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/constants/app_icons.dart';
import 'package:hassen_dashboard/core/constants/app_layout.dart';
import 'package:hassen_dashboard/core/constants/asset_paths.dart';
import 'package:hassen_dashboard/core/routes/routes.dart';
import 'package:hassen_dashboard/core/theme/app_colors.dart';
import 'package:hassen_dashboard/core/widgets/app_svg_icon.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/domain/entities/nav_destination.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/presentation/config/dashboard_navigation_config.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/presentation/cubits/dashboard_navigation_cubit.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/presentation/widgets/sidebar/dashboard_sidebar.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/presentation/widgets/sidebar/sidebar_nav_item.dart';

import '../../../../helpers/test_view.dart';

void main() {
  late DashboardNavigationCubit cubit;

  // Routes the sidebar opened, in order.
  late List<String?> opened;

  setUp(() {
    cubit = DashboardNavigationCubit();
    opened = [];
  });
  tearDown(() => cubit.close());

  Future<void> pumpSidebar(WidgetTester tester) async {
    useDesktopView(tester);
    ignoreTestFontOverflow();
    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: ScreenUtilInit(
          designSize: AppLayout.designSize,
          builder: (_, _) => MaterialApp(
            onGenerateRoute: (settings) {
              opened.add(settings.name);
              return MaterialPageRoute<void>(
                settings: settings,
                builder: (_) => const SizedBox(),
              );
            },
            home: const Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                body: Row(
                  children: [
                    DashboardSidebar(
                      groups: dashboardNavGroups,
                      profile: sidebarProfile,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Text label(WidgetTester tester, String text) =>
      tester.widget<Text>(find.text(text));

  AppSvgIcon svgIcon(WidgetTester tester, String asset) =>
      tester.widget<AppSvgIcon>(
        find.byWidgetPredicate((w) => w is AppSvgIcon && w.asset == asset),
      );

  BoxDecoration itemDecoration(WidgetTester tester, String text) =>
      tester
              .widget<Container>(
                find
                    .ancestor(
                      of: find.text(text),
                      matching: find.byType(Container),
                    )
                    .first,
              )
              .decoration!
          as BoxDecoration;

  testWidgets('renders 240px navy sidebar with logo, all groups and items', (
    tester,
  ) async {
    await pumpSidebar(tester);

    expect(tester.getSize(find.byType(DashboardSidebar)).width, 240);
    final root = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(DashboardSidebar),
            matching: find.byType(Container),
          )
          .first,
    );
    expect(root.color, HaseenColors.navy);

    expect(find.text('الحصين'), findsOneWidget);
    expect(find.text('HASEEN'), findsOneWidget);
    // cacheWidth wraps the asset in a ResizeImage.
    final logo = tester.widget<Image>(find.byType(Image)).image as ResizeImage;
    expect(logo.imageProvider, const AssetImage(AssetPaths.haseenLogo));
    for (final group in dashboardNavGroups) {
      expect(
        label(tester, group.title).style!.color,
        HaseenColors.sideGroupTitle,
      );
      for (final item in group.items) {
        expect(find.text(item.label), findsOneWidget);
      }
    }
  });

  testWidgets('shows gold counters and a red alert counter', (tester) async {
    await pumpSidebar(tester);

    BoxDecoration badgeOf(String label) {
      final badge = find.descendant(
        of: find.widgetWithText(SidebarNavItem, label),
        matching: find.byType(SidebarNavBadge),
      );
      return tester
              .widget<Container>(
                find
                    .descendant(of: badge, matching: find.byType(Container))
                    .first,
              )
              .decoration!
          as BoxDecoration;
    }

    expect(find.byType(SidebarNavBadge), findsNWidgets(3));
    expect(
      find.descendant(
        of: find.widgetWithText(SidebarNavItem, 'مراجعة التفتيش'),
        matching: find.text('4'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.widgetWithText(SidebarNavItem, 'الإجراءات التصحيحية'),
        matching: find.text('3'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.widgetWithText(SidebarNavItem, 'العروض والعقود'),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );
    expect(badgeOf('مراجعة التفتيش').color, HaseenColors.gold);
    expect(badgeOf('العروض والعقود').color, HaseenColors.gold);
    expect(badgeOf('الإجراءات التصحيحية').color, HaseenColors.redStrong);
    expect(label(tester, '3').style!.color, Colors.white);
    expect(label(tester, '4').style!.color, HaseenColors.navy);
  });

  testWidgets('shows the signed-in user at the bottom', (tester) async {
    await pumpSidebar(tester);

    expect(find.text('مدير العمليات'), findsOneWidget);
    expect(find.text('شركة الحصين'), findsOneWidget);
    expect(find.text('م'), findsOneWidget);
    expect(
      tester.getBottomLeft(find.text('شركة الحصين')).dy,
      greaterThan(tester.getBottomLeft(find.text('الإعدادات')).dy),
    );
  });

  testWidgets('نظرة عامة is active by default with gold styling', (
    tester,
  ) async {
    await pumpSidebar(tester);

    final overview = label(tester, 'نظرة عامة').style!;
    expect(overview.color, HaseenColors.gold);
    expect(overview.fontWeight, FontWeight.w700);
    expect(
      itemDecoration(tester, 'نظرة عامة').color,
      HaseenColors.sideActiveBg,
    );

    final team = label(tester, 'الفريق').style!;
    expect(team.color, HaseenColors.sideText);
    expect(team.fontWeight, FontWeight.w500);
    expect(itemDecoration(tester, 'الفريق').color, Colors.transparent);
  });

  testWidgets('tapping an item moves the highlight and opens its page', (
    tester,
  ) async {
    await pumpSidebar(tester);

    await tester.tap(find.text('الإعدادات'));
    await tester.pump();

    expect(cubit.state, NavDestination.settings);
    expect(label(tester, 'الإعدادات').style!.color, HaseenColors.gold);
    expect(svgIcon(tester, AppIcons.settings).color, HaseenColors.gold);
    expect(svgIcon(tester, AppIcons.home).color, HaseenColors.sideText);
    expect(label(tester, 'نظرة عامة').style!.color, HaseenColors.sideText);

    await tester.pumpAndSettle();
    expect(opened, [Routes.settings]);
  });

  testWidgets('navigation list scrolls inside the sidebar', (tester) async {
    await pumpSidebar(tester);

    expect(
      find.descendant(
        of: find.byType(DashboardSidebar),
        matching: find.byType(ListView),
      ),
      findsOneWidget,
    );
  });

  testWidgets('scales with the screen via ScreenUtil', (tester) async {
    await pumpSidebar(tester);
    tester.view.physicalSize = const Size(1080, 900); // 0.75 × design width
    await tester.pump();

    expect(tester.getSize(find.byType(DashboardSidebar)).width, 180);
  });
}
