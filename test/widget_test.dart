import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/di/injection_container.dart' as di;
import 'package:hassen_dashboard/core/routes/routes.dart';
import 'package:hassen_dashboard/core/theme/app_colors.dart';
import 'package:hassen_dashboard/features/auth/domain/repositories/auth_repository.dart';
import 'package:hassen_dashboard/features/auth/presentation/pages/login_page.dart';
import 'package:hassen_dashboard/features/dashboard_actions/data/datasources/corrective_actions_remote_datasource.dart';
import 'package:hassen_dashboard/features/dashboard_actions/presentation/pages/dashboard_actions_page.dart';
import 'package:hassen_dashboard/features/dashboard_actions/presentation/widgets/corrective_action_card.dart';
import 'package:hassen_dashboard/features/dashboard_clients/data/datasources/clients_remote_datasource.dart';
import 'package:hassen_dashboard/features/dashboard_clients/presentation/pages/dashboard_clients_page.dart';
import 'package:hassen_dashboard/features/dashboard_clients/presentation/widgets/client_table_row.dart';
import 'package:hassen_dashboard/features/dashboard_contracts/data/datasources/contracts_remote_datasource.dart';
import 'package:hassen_dashboard/features/dashboard_contracts/presentation/pages/dashboard_contracts_page.dart';
import 'package:hassen_dashboard/features/dashboard_contracts/presentation/widgets/deal_table_row.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/presentation/pages/dashboard_inspection_review_page.dart';
import 'package:hassen_dashboard/features/dashboard_reports/data/datasources/reports_remote_datasource.dart';
import 'package:hassen_dashboard/features/dashboard_reports/presentation/pages/dashboard_reports_page.dart';
import 'package:hassen_dashboard/features/dashboard_reports/presentation/widgets/monthly_report_row.dart';
import 'package:hassen_dashboard/features/dashboard_risks/data/datasources/risks_remote_datasource.dart';
import 'package:hassen_dashboard/features/dashboard_risks/presentation/pages/dashboard_risks_page.dart';
import 'package:hassen_dashboard/features/dashboard_risks/presentation/widgets/risk_table_row.dart';
import 'package:hassen_dashboard/features/dashboard_settings/presentation/pages/dashboard_settings_page.dart';
import 'package:hassen_dashboard/features/dashboard_settings/presentation/widgets/inspection_template_row.dart';
import 'package:hassen_dashboard/features/dashboard_settings/presentation/widgets/operation_rule_row.dart';
import 'package:hassen_dashboard/features/dashboard_settings/presentation/widgets/system_role_row.dart';
import 'package:hassen_dashboard/features/dashboard_team/data/datasources/team_remote_datasource.dart';
import 'package:hassen_dashboard/features/dashboard_team/presentation/pages/dashboard_team_page.dart';
import 'package:hassen_dashboard/features/dashboard_team/presentation/widgets/team_member_card.dart';
import 'package:hassen_dashboard/features/overview/data/datasources/overview_remote_datasource.dart';
import 'package:hassen_dashboard/features/overview/presentation/pages/dashboard_overview_page.dart';
import 'package:hassen_dashboard/features/overview/presentation/widgets/kpi/kpi_card.dart';
import 'package:hassen_dashboard/features/visits/data/datasources/visits_local_datasource.dart';
import 'package:hassen_dashboard/features/visits/data/datasources/visits_remote_datasource.dart';
import 'package:hassen_dashboard/features/visits/presentation/pages/dashboard_visits_page.dart';
import 'package:hassen_dashboard/features/visits/presentation/widgets/visit_chip.dart';
import 'package:hassen_dashboard/main.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/presentation/widgets/sidebar/dashboard_sidebar.dart';

import 'features/auth/helpers/fake_auth_repository.dart';
import 'features/dashboard_actions/helpers/fake_corrective_actions_remote_datasource.dart';
import 'features/dashboard_clients/helpers/fake_clients_remote_datasource.dart';
import 'features/dashboard_contracts/helpers/fake_contracts_remote_datasource.dart';
import 'features/dashboard_reports/helpers/fake_reports_remote_datasource.dart';
import 'features/dashboard_risks/helpers/fake_risks_remote_datasource.dart';
import 'features/dashboard_team/helpers/fake_team_remote_datasource.dart';
import 'features/overview/helpers/fake_overview_remote_datasource.dart';
import 'features/visits/fixtures/visits_fixture.dart';
import 'features/visits/helpers/fake_visits_remote_datasource.dart';
import 'helpers/test_view.dart';

void main() {
  setUp(() async {
    await di.sl.reset();
    await di.init();
    // Firebase is not available in tests: keep added employees, clients,
    // deals, risks and visits in memory, seeded with the original screens'
    // data.
    di.sl
      ..unregister<TeamRemoteDataSource>()
      ..registerLazySingleton<TeamRemoteDataSource>(
        FakeTeamRemoteDataSource.new,
      )
      ..unregister<ClientsRemoteDataSource>()
      ..registerLazySingleton<ClientsRemoteDataSource>(
        FakeClientsRemoteDataSource.new,
      )
      ..unregister<ContractsRemoteDataSource>()
      ..registerLazySingleton<ContractsRemoteDataSource>(
        FakeContractsRemoteDataSource.new,
      )
      ..unregister<RisksRemoteDataSource>()
      ..registerLazySingleton<RisksRemoteDataSource>(
        FakeRisksRemoteDataSource.new,
      )
      ..unregister<OverviewRemoteDataSource>()
      ..registerLazySingleton<OverviewRemoteDataSource>(
        FakeOverviewRemoteDataSource.new,
      )
      ..unregister<ReportsRemoteDataSource>()
      ..registerLazySingleton<ReportsRemoteDataSource>(
        FakeReportsRemoteDataSource.new,
      )
      ..unregister<CorrectiveActionsRemoteDataSource>()
      ..registerLazySingleton<CorrectiveActionsRemoteDataSource>(
        FakeCorrectiveActionsRemoteDataSource.new,
      )
      ..unregister<VisitsRemoteDataSource>()
      ..registerLazySingleton<VisitsRemoteDataSource>(
        FakeVisitsRemoteDataSource.new,
      )
      // The fixture visits fall in the week of 24–29 October 2026.
      ..unregister<VisitsLocalDataSource>()
      ..registerLazySingleton<VisitsLocalDataSource>(
        () => VisitsLocalDataSource(clock: () => fixtureNow),
      );
  });

  Future<void> pumpApp(WidgetTester tester) async {
    useDesktopView(tester);
    ignoreTestFontOverflow();
    // Dashboard tests start past the sign-in, on the overview.
    await tester.pumpWidget(
      const HaseenDashboardApp(initialRoute: Routes.overview),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('app opens on the overview, wired through DI, in RTL', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.byType(DashboardOverviewPage), findsOneWidget);
    expect(find.byType(KpiCard), findsNWidgets(6));
    expect(
      Directionality.of(tester.element(find.byType(DashboardSidebar))),
      TextDirection.rtl,
    );
    // Sidebar is the first Row child, so in RTL it sits on the right edge.
    expect(tester.getTopRight(find.byType(DashboardSidebar)).dx, 1440);
    final overviewLabel = find.descendant(
      of: find.byType(DashboardSidebar),
      matching: find.text('نظرة عامة'),
    );
    expect(tester.widget<Text>(overviewLabel).style!.color, HaseenColors.gold);
    // The users page was removed; the team page manages accounts.
    expect(find.text('المستخدمون'), findsNothing);
  });

  testWidgets('sidebar opens the visits schedule, wired through DI', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('جدول الزيارات'));
    await tester.pumpAndSettle();

    expect(find.byType(DashboardVisitsPage), findsOneWidget);
    expect(find.byType(VisitChip), findsNWidgets(13));
    final label = find.descendant(
      of: find.byType(DashboardSidebar),
      matching: find.text('جدول الزيارات'),
    );
    expect(tester.widget<Text>(label).style!.color, HaseenColors.gold);
  });

  testWidgets(
    'a scheduled visit stays on the schedule after leaving the page',
    (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('جدول الزيارات'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('+ جدولة زيارة'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('جدولة وإسناد'));
      await tester.pumpAndSettle();
      expect(find.byType(VisitChip), findsNWidgets(14));

      await tester.tap(find.text('نظرة عامة').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('جدول الزيارات'));
      await tester.pumpAndSettle();

      expect(find.byType(VisitChip), findsNWidgets(14));
      expect(find.text('3 زيارات'), findsNWidgets(2));
      // Let the confirmation toast run out so no timer outlives the test.
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'inspection review: decisions persist across page changes via DI',
    (tester) async {
      await pumpApp(tester);

      await tester.tap(find.text('مراجعة التفتيش'));
      await tester.pumpAndSettle();
      expect(find.byType(DashboardInspectionReviewPage), findsOneWidget);

      await tester.tap(find.text('اعتماد ونشر للمنشأة'));
      await tester.pumpAndSettle();
      expect(
        find.text('تم الاعتماد — النتائج ظاهرة الآن لدى المنشأة'),
        findsOneWidget,
      );

      await tester.tap(find.text('نظرة عامة').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('مراجعة التفتيش'));
      await tester.pumpAndSettle();

      expect(
        find.text('تم الاعتماد — النتائج ظاهرة الآن لدى المنشأة'),
        findsOneWidget,
      );
      expect(find.text('معتمد'), findsOneWidget);
    },
  );

  testWidgets('sidebar opens the corrective actions board, wired through DI', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('الإجراءات التصحيحية'));
    await tester.pumpAndSettle();

    expect(find.byType(DashboardActionsPage), findsOneWidget);
    expect(find.byType(CorrectiveActionCard), findsNWidgets(9));
  });

  testWidgets('sidebar opens clients & facilities, wired through DI', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('العملاء والمنشآت'));
    await tester.pumpAndSettle();

    expect(find.byType(DashboardClientsPage), findsOneWidget);
    expect(find.byType(ClientTableRow), findsNWidgets(8));
  });

  testWidgets('a new client stays in the list after leaving the page', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.text('العملاء والمنشآت'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('+ عميل جديد'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'مدرسة النور');
    final sector = find
        .ancestor(
          of: find.text('اختر القطاع'),
          matching: find.byType(DropdownButtonFormField<String>),
        )
        .first;
    await tester.ensureVisible(sector);
    await tester.pumpAndSettle();
    await tester.tap(sector);
    await tester.pumpAndSettle();
    await tester.tap(find.text('مؤسسة تعليمية').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(4), 'أ. محمود');
    await tester.enterText(find.byType(TextFormField).at(7), '0599 123456');
    await tester.tap(find.text('إضافة عميل'));
    await tester.pumpAndSettle();
    expect(find.byType(ClientTableRow), findsNWidgets(9));

    await tester.tap(find.text('نظرة عامة').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('العملاء والمنشآت'));
    await tester.pumpAndSettle();

    expect(find.byType(ClientTableRow), findsNWidgets(9));
    expect(find.text('مدرسة النور'), findsOneWidget);
    // Let the success toast run out so no timer outlives the test.
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
  });

  testWidgets('sidebar opens quotes & contracts, wired through DI', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('العروض والعقود'));
    await tester.pumpAndSettle();

    expect(find.byType(DashboardContractsPage), findsOneWidget);
    expect(find.byType(DealTableRow), findsNWidgets(8));
  });

  testWidgets('sidebar opens the risk register, wired through DI', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('سجل المخاطر'));
    await tester.pumpAndSettle();

    expect(find.byType(DashboardRisksPage), findsOneWidget);
    expect(find.byType(RiskTableRow), findsNWidgets(7));
  });

  testWidgets('sidebar opens the settings, wired through DI', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('الإعدادات'));
    await tester.pumpAndSettle();

    expect(find.byType(DashboardSettingsPage), findsOneWidget);
    expect(find.byType(InspectionTemplateRow), findsNWidgets(5));
    expect(find.byType(SystemRoleRow), findsNWidgets(7));
    expect(find.byType(OperationRuleRow), findsNWidgets(7));
  });

  testWidgets('sidebar opens the reports catalogue, wired through DI', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('التقارير'));
    await tester.pumpAndSettle();

    expect(find.byType(DashboardReportsPage), findsOneWidget);
    expect(find.byType(MonthlyReportRow), findsNWidgets(3));
  });

  testWidgets(
    'the app opens on sign-in; an admin sign-in leads to the overview for good',
    (tester) async {
      // Firebase is not available in tests: answer as the admin account.
      di.sl
        ..unregister<AuthRepository>()
        ..registerLazySingleton<AuthRepository>(
          () => FakeAuthRepository()..result = const Right(adminUser),
        );
      useDesktopView(tester);
      ignoreTestFontOverflow();
      await tester.pumpWidget(const HaseenDashboardApp());
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(DashboardOverviewPage), findsNothing);
      // Only the sign-in is on the stack, so "back" cannot skip it.
      final navigator = tester.state<NavigatorState>(
        find.byType(Navigator).first,
      );
      expect(navigator.canPop(), isFalse);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'name@haseen.ps',
      );
      await tester.enterText(find.byType(TextFormField).at(1), '12345678');
      await tester.tap(find.text('دخول'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsNothing);
      expect(find.byType(DashboardOverviewPage), findsOneWidget);
      expect(navigator.canPop(), isFalse);
    },
  );

  testWidgets('sidebar opens the team page, wired through DI', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('الفريق'));
    await tester.pumpAndSettle();

    expect(find.byType(DashboardTeamPage), findsOneWidget);
    // The (fake) users collection starts empty.
    expect(find.byType(TeamMemberCard), findsNothing);
    expect(find.text('لا يوجد موظفون بعد'), findsOneWidget);
  });

  testWidgets('an invited employee stays on the team after leaving the page', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.text('الفريق'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('+ إضافة موظف'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'سامي');
    await tester.enterText(find.byType(TextFormField).at(1), 'sami@haseen.ps');
    await tester.tap(find.text('إضافة وإنشاء الحساب'));
    await tester.pumpAndSettle();
    expect(find.byType(TeamMemberCard), findsOneWidget);

    await tester.tap(find.text('نظرة عامة').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('الفريق'));
    await tester.pumpAndSettle();

    expect(find.byType(TeamMemberCard), findsOneWidget);
    expect(find.text('م. سامي'), findsOneWidget);
    // Let the success toast run out so no timer outlives the test.
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
  });
}
