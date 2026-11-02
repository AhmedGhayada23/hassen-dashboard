import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/constants/app_layout.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/core/routes/routes.dart';
import 'package:hassen_dashboard/features/overview/domain/usecases/get_dashboard_overview.dart';
import 'package:hassen_dashboard/features/overview/presentation/cubits/dashboard_overview_cubit.dart';
import 'package:hassen_dashboard/features/overview/presentation/pages/dashboard_overview_page.dart';
import 'package:hassen_dashboard/features/overview/presentation/widgets/compliance/compliance_card.dart';
import 'package:hassen_dashboard/features/overview/presentation/widgets/contracts/contract_alert_card.dart';
import 'package:hassen_dashboard/features/overview/presentation/widgets/inspections/inspection_review_card.dart';
import 'package:hassen_dashboard/features/overview/presentation/widgets/kpi/kpi_card.dart';
import 'package:hassen_dashboard/features/overview/presentation/widgets/overview_skeleton.dart';
import 'package:hassen_dashboard/features/overview/presentation/widgets/risks/critical_risk_card.dart';
import 'package:hassen_dashboard/features/overview/presentation/widgets/visits/today_visits_card.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/domain/entities/nav_destination.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/presentation/cubits/dashboard_navigation_cubit.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/presentation/widgets/sidebar/dashboard_sidebar.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../helpers/test_view.dart';
import '../../fixtures/overview_fixture.dart';
import '../../helpers/fake_dashboard_repository.dart';

void main() {
  late FakeDashboardRepository repository;
  late DashboardOverviewCubit overviewCubit;
  late DashboardNavigationCubit navigationCubit;
  // Routes the page opened, in order.
  late List<String?> opened;

  setUp(() {
    repository = FakeDashboardRepository(Right(expectedOverview));
    overviewCubit = DashboardOverviewCubit(GetDashboardOverview(repository));
    navigationCubit = DashboardNavigationCubit();
    opened = [];
  });
  tearDown(() {
    overviewCubit.close();
    navigationCubit.close();
  });

  Future<void> pumpPage(WidgetTester tester) async {
    useDesktopView(tester);
    ignoreTestFontOverflow();
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: navigationCubit),
          BlocProvider.value(value: overviewCubit),
        ],
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
              child: DashboardOverviewPage(),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('shows a skeleton while loading', (tester) async {
    repository.gate = Completer<void>();
    await pumpPage(tester);
    unawaited(overviewCubit.load());
    await tester.pump();

    expect(find.byType(OverviewSkeleton), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is Skeletonizer), findsOneWidget);

    repository.gate!.complete();
    await tester.pumpAndSettle();
    expect(find.byType(OverviewSkeleton), findsNothing);
    expect(find.byType(KpiCard), findsNWidgets(6));
  });

  testWidgets('renders every section in the original order once loaded', (
    tester,
  ) async {
    await pumpPage(tester);
    await overviewCubit.load();
    await tester.pumpAndSettle();

    expect(find.byType(KpiCard), findsNWidgets(6));
    final sections = [
      InspectionReviewCard,
      ComplianceCard,
      CriticalRiskCard,
      TodayVisitsCard,
      ContractAlertCard,
    ];
    for (final type in sections) {
      expect(find.byType(type), findsOneWidget);
    }
    // Row 1: inspections | compliance. Row 2: risk | visits | contracts.
    double top(Type t) => tester.getTopLeft(find.byType(t)).dy;
    expect(top(InspectionReviewCard), top(ComplianceCard));
    expect(top(CriticalRiskCard), top(TodayVisitsCard));
    expect(top(TodayVisitsCard), top(ContractAlertCard));
    expect(top(CriticalRiskCard), greaterThan(top(InspectionReviewCard)));
    // RTL: first child sits on the right.
    expect(
      tester.getCenter(find.byType(InspectionReviewCard)).dx,
      greaterThan(tester.getCenter(find.byType(ComplianceCard)).dx),
    );
    expect(
      tester.getCenter(find.byType(CriticalRiskCard)).dx,
      greaterThan(tester.getCenter(find.byType(ContractAlertCard)).dx),
    );
  });

  testWidgets(
    'lays out RTL with the 240px sidebar on the right and marks overview active',
    (tester) async {
      await pumpPage(tester);
      await overviewCubit.load();
      await tester.pumpAndSettle();

      final sidebar = find.byType(DashboardSidebar);
      expect(tester.getSize(sidebar).width, 240);
      expect(tester.getTopRight(sidebar).dx, 1440);
      expect(navigationCubit.state, NavDestination.overview);
      expect(tester.widget<Badge>(find.byType(Badge)).isLabelVisible, isTrue);
    },
  );

  testWidgets('KPI taps show the demo snackbar', (tester) async {
    await pumpPage(tester);
    await overviewCubit.load();
    await tester.pumpAndSettle();

    await tester.tap(find.text('عملاء متعاقدون'));
    await tester.pump();

    expect(find.text('نموذج توضيحي — فتح عملاء متعاقدون'), findsOneWidget);
  });

  testWidgets('"فتح المراجعة" opens the inspection review page', (
    tester,
  ) async {
    await pumpPage(tester);
    await overviewCubit.load();
    await tester.pumpAndSettle();

    await tester.tap(find.text('فتح المراجعة ←'));
    await tester.pumpAndSettle();
    expect(opened, [Routes.inspectionReview]);
  });

  testWidgets('"إدارة العقود" opens the contracts page', (tester) async {
    await pumpPage(tester);
    await overviewCubit.load();
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('إدارة العقود'));
    await tester.tap(find.text('إدارة العقود'));
    await tester.pumpAndSettle();
    expect(opened, [Routes.contracts]);
  });

  testWidgets('a missing Firestore permission is explained', (tester) async {
    repository.result = const Left(ForbiddenFailure());
    await pumpPage(tester);
    await overviewCubit.load();
    await tester.pumpAndSettle();

    expect(
      find.textContaining('لا توجد صلاحية لقراءة بيانات النظرة العامة'),
      findsOneWidget,
    );
  });

  testWidgets('shows an error with retry, and retry loads the data', (
    tester,
  ) async {
    repository.result = const Left(CacheFailure());
    await pumpPage(tester);
    await overviewCubit.load();
    await tester.pumpAndSettle();

    expect(find.text('تعذّر تحميل بيانات لوحة التحكم'), findsOneWidget);

    repository.result = Right(expectedOverview);
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pumpAndSettle();

    expect(find.byType(KpiCard), findsNWidgets(6));
    expect(repository.calls, 2);
  });
}
