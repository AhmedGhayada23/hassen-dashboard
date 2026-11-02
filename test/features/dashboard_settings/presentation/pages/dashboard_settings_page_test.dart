import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/constants/app_layout.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/core/theme/app_colors.dart';
import 'package:hassen_dashboard/core/widgets/status_badge.dart';
import 'package:hassen_dashboard/features/dashboard_settings/presentation/cubits/dashboard_settings_cubit.dart';
import 'package:hassen_dashboard/features/dashboard_settings/presentation/pages/dashboard_settings_page.dart';
import 'package:hassen_dashboard/features/dashboard_settings/presentation/widgets/inspection_template_row.dart';
import 'package:hassen_dashboard/features/dashboard_settings/presentation/widgets/inspection_templates_card.dart';
import 'package:hassen_dashboard/features/dashboard_settings/presentation/widgets/operation_rule_row.dart';
import 'package:hassen_dashboard/features/dashboard_settings/presentation/widgets/operation_rules_card.dart';
import 'package:hassen_dashboard/features/dashboard_settings/presentation/widgets/system_role_row.dart';
import 'package:hassen_dashboard/features/dashboard_settings/presentation/widgets/system_roles_card.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/domain/entities/nav_destination.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/presentation/cubits/dashboard_navigation_cubit.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/presentation/widgets/sidebar/dashboard_sidebar.dart';

import '../../../../helpers/test_view.dart';
import '../../fixtures/settings_fixture.dart';
import '../../helpers/settings_cubit_factory.dart';

void main() {
  late FakeSettingsRepository repository;
  late DashboardSettingsCubit settingsCubit;
  late DashboardNavigationCubit navigationCubit;

  setUp(() {
    repository = FakeSettingsRepository();
    settingsCubit = buildSettingsCubit(repository);
    navigationCubit = DashboardNavigationCubit();
  });
  tearDown(() {
    settingsCubit.close();
    navigationCubit.close();
  });

  Future<void> pumpPage(
    WidgetTester tester, {
    bool load = true,
    Size size = const Size(1440, 900),
  }) async {
    useDesktopView(tester, size: size);
    ignoreTestFontOverflow();
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: navigationCubit),
          BlocProvider.value(value: settingsCubit),
        ],
        child: ScreenUtilInit(
          designSize: AppLayout.designSize,
          builder: (_, _) => const MaterialApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: DashboardSettingsPage(),
            ),
          ),
        ),
      ),
    );
    if (load) {
      await settingsCubit.load();
      await tester.pumpAndSettle();
    }
  }

  testWidgets('a spinner while loading, then the three cards', (tester) async {
    repository.gate = Completer<void>();
    await pumpPage(tester, load: false);
    unawaited(settingsCubit.load());
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    repository.gate!.complete();
    await tester.pumpAndSettle();
    expect(find.byType(InspectionTemplatesCard), findsOneWidget);
    expect(find.byType(SystemRolesCard), findsOneWidget);
    expect(find.byType(OperationRulesCard), findsOneWidget);
  });

  testWidgets('in the shell: RTL, 240px sidebar, settings active, titled', (
    tester,
  ) async {
    await pumpPage(tester);

    final sidebar = find.byType(DashboardSidebar);
    expect(tester.getSize(sidebar).width, 240);
    expect(tester.getTopRight(sidebar).dx, 1440);
    expect(navigationCubit.state, NavDestination.settings);
    expect(find.text('الإعدادات'), findsWidgets);
  });

  testWidgets('three cards side by side at 1440, in the original order', (
    tester,
  ) async {
    await pumpPage(tester);

    final templates = tester.getRect(find.byType(InspectionTemplatesCard));
    final roles = tester.getRect(find.byType(SystemRolesCard));
    final rules = tester.getRect(find.byType(OperationRulesCard));
    // RTL: the first card sits on the right.
    expect(templates.left, greaterThan(roles.left));
    expect(roles.left, greaterThan(rules.left));
    expect((templates.top, roles.top), (rules.top, rules.top));
    // 1440 − 240 sidebar − 56 padding = 1144 → 3 × 370.7 with 16px gaps.
    expect(templates.width, closeTo((1144 - 32) / 3, 0.5));
    expect(templates.left - roles.right, closeTo(16, 0.01));
  });

  testWidgets('narrower windows drop to two columns, then one', (tester) async {
    // Design width, so ScreenUtil leaves sizes unscaled: 1144 → 3 columns.
    await pumpPage(tester);
    double cardWidth() => tester.getSize(find.byType(SystemRolesCard)).width;
    expect(cardWidth(), closeTo((1144 - 32) / 3, 0.5));

    for (final (window, columns) in const [(1024.0, 2), (700.0, 1)]) {
      await pumpPage(tester, size: Size(window, 900));
      // Scaled: padding and gaps shrink with the window.
      final scale = window / 1440;
      final available = window - 240 * scale - 56 * scale;
      expect(
        cardWidth(),
        closeTo((available - 16 * scale * (columns - 1)) / columns, 0.5),
        reason: '$window',
      );
    }
  });

  testWidgets('templates: names, version badges and item counts', (
    tester,
  ) async {
    await pumpPage(tester);

    expect(find.text('نماذج الفحص'), findsOneWidget);
    final rows = tester.widgetList<InspectionTemplateRow>(
      find.byType(InspectionTemplateRow),
    );
    expect([for (final r in rows) r.template], expectedTemplates);
    for (final text in ['v3', '42 بنداً', '23 بنداً', 'تفتيش المنشآت الصحية']) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    expect(find.text('v2'), findsNWidgets(2));
  });

  testWidgets('roles: users and organization pills in order', (tester) async {
    await pumpPage(tester);

    expect(find.text('الأدوار والصلاحيات'), findsOneWidget);
    final rows = tester.widgetList<SystemRoleRow>(find.byType(SystemRoleRow));
    expect([for (final r in rows) r.role], expectedRoles);
    expect(find.text('4 مستخدم'), findsOneWidget);
    expect(find.text('7 مستخدم'), findsOneWidget);

    final pills = tester
        .widgetList<StatusBadge>(
          find.descendant(
            of: find.byType(SystemRolesCard),
            matching: find.byType(StatusBadge),
          ),
        )
        .toList();
    expect(pills.map((p) => p.text), [
      ...List.filled(5, 'الحصين'),
      ...List.filled(2, 'المنشأة'),
    ]);
    expect(
      (pills.first.background, pills.first.foreground),
      (HaseenColors.infoSoft, HaseenColors.infoText),
    );
    expect(
      (pills.last.background, pills.last.foreground),
      (HaseenColors.tealSoft, HaseenColors.tealText),
    );
  });

  testWidgets('rules: titles with their values, end-aligned', (tester) async {
    await pumpPage(tester);

    expect(find.text('قواعد التشغيل'), findsOneWidget);
    final rows = tester.widgetList<OperationRuleRow>(
      find.byType(OperationRuleRow),
    );
    expect([for (final r in rows) r.rule], expectedRules);
    final value = tester.widget<Text>(
      find.text('احتواء 24 ساعة · معالجة 7 أيام'),
    );
    expect(value.textAlign, TextAlign.end);
  });

  testWidgets('"+ نموذج" shows the original demo message', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('+ نموذج'));
    await tester.pump();

    expect(
      find.text('نموذج توضيحي — محرر النماذج يُربط بالخادم عند التنفيذ'),
      findsOneWidget,
    );
  });

  testWidgets('a load error offers a retry that loads the cards', (
    tester,
  ) async {
    repository.rolesFailure = const CacheFailure();
    await pumpPage(tester);
    expect(find.text('تعذّر تحميل بيانات لوحة التحكم'), findsOneWidget);

    repository.rolesFailure = null;
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pumpAndSettle();

    expect(find.byType(SystemRolesCard), findsOneWidget);
  });
}
