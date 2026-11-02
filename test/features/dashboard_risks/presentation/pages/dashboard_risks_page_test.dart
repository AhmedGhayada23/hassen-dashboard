import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/constants/app_layout.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/features/dashboard_risks/domain/usecases/get_risks.dart';
import 'package:hassen_dashboard/features/dashboard_risks/presentation/cubits/dashboard_risks_cubit.dart';
import 'package:hassen_dashboard/features/dashboard_risks/presentation/pages/dashboard_risks_page.dart';
import 'package:hassen_dashboard/features/dashboard_risks/presentation/widgets/risk_details_summary.dart';
import 'package:hassen_dashboard/features/dashboard_risks/presentation/widgets/risk_matrix_card.dart';
import 'package:hassen_dashboard/features/dashboard_risks/presentation/widgets/risk_matrix_cell.dart';
import 'package:hassen_dashboard/features/dashboard_risks/presentation/widgets/risk_table_row.dart';
import 'package:hassen_dashboard/features/dashboard_risks/presentation/widgets/risks_skeleton.dart';
import 'package:hassen_dashboard/features/dashboard_risks/presentation/widgets/risks_table.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/domain/entities/nav_destination.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/presentation/cubits/dashboard_navigation_cubit.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/presentation/widgets/sidebar/dashboard_sidebar.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../helpers/test_view.dart';
import '../../helpers/fake_risks_repository.dart';

void main() {
  late FakeRisksRepository repository;
  late DashboardRisksCubit risksCubit;
  late DashboardNavigationCubit navigationCubit;

  setUp(() {
    repository = FakeRisksRepository();
    risksCubit = DashboardRisksCubit(GetRisks(repository));
    navigationCubit = DashboardNavigationCubit();
  });
  tearDown(() {
    risksCubit.close();
    navigationCubit.close();
  });

  Future<void> pumpPage(WidgetTester tester, {bool load = true}) async {
    useDesktopView(tester);
    ignoreTestFontOverflow();
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: navigationCubit),
          BlocProvider.value(value: risksCubit),
        ],
        child: ScreenUtilInit(
          designSize: AppLayout.designSize,
          builder: (_, _) => const MaterialApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: DashboardRisksPage(),
            ),
          ),
        ),
      ),
    );
    if (load) {
      await risksCubit.load();
      await tester.pumpAndSettle();
    }
  }

  String summaryHazard(WidgetTester tester) => tester
      .widget<RiskDetailsSummary>(find.byType(RiskDetailsSummary))
      .risk
      .hazard;

  testWidgets('shows a skeleton, then the table and the 5 × 5 matrix', (
    tester,
  ) async {
    repository.gate = Completer<void>();
    await pumpPage(tester, load: false);
    unawaited(risksCubit.load());
    await tester.pump();
    expect(find.byType(RisksSkeleton), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is Skeletonizer), findsOneWidget);

    repository.gate!.complete();
    await tester.pumpAndSettle();
    expect(find.byType(RisksSkeleton), findsNothing);
    expect(find.byType(RiskTableRow), findsNWidgets(7));
    expect(find.byType(RiskMatrixCellView), findsNWidgets(25));
  });

  testWidgets(
    'layout: RTL shell, 300px matrix card, 16px gap, risks item active',
    (tester) async {
      await pumpPage(tester);

      expect(tester.getTopRight(find.byType(DashboardSidebar)).dx, 1440);
      expect(navigationCubit.state, NavDestination.riskRegister);
      expect(tester.getSize(find.byType(RiskMatrixCard)).width, 300);
      final table = tester.getRect(find.byType(RisksTable));
      final card = tester.getRect(find.byType(RiskMatrixCard));
      expect(table.left - card.right, 16);
    },
  );

  testWidgets('shows the first risk by default and follows the tapped row', (
    tester,
  ) async {
    await pumpPage(tester);
    expect(summaryHazard(tester), 'إعاقة مسار الإخلاء');

    await tester.tap(find.text('إجهاد بيئة العمل المكتبي'));
    await tester.pumpAndSettle();

    expect(summaryHazard(tester), 'إجهاد بيئة العمل المكتبي');
    expect(find.text('بنك فلسطين · الاحتمال 2 × الشدة 2 = 4'), findsOneWidget);
    final selectedCells = tester
        .widgetList<RiskMatrixCellView>(find.byType(RiskMatrixCellView))
        .where((c) => c.isSelected);
    expect(
      [for (final c in selectedCells) (c.cell.likelihood, c.cell.severity)],
      [(2, 2)],
    );
  });

  testWidgets('shows an error with retry when loading fails', (tester) async {
    repository.failure = const CacheFailure();
    await pumpPage(tester);
    expect(find.text('تعذّر تحميل بيانات لوحة التحكم'), findsOneWidget);

    repository.failure = null;
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pumpAndSettle();

    expect(find.byType(RiskTableRow), findsNWidgets(7));
  });

  testWidgets('a missing Firestore permission is explained', (tester) async {
    repository.failure = const ForbiddenFailure();
    await pumpPage(tester);

    expect(
      find.text('لا توجد صلاحية لقراءة جدول risks. راجع قواعد Firestore.'),
      findsOneWidget,
    );
  });

  testWidgets('an empty register says so, with an empty matrix', (
    tester,
  ) async {
    repository.risks = [];
    await pumpPage(tester);

    expect(find.text('لا توجد مخاطر مسجلة بعد في جدول risks.'), findsOneWidget);
    expect(find.byType(RiskTableRow), findsNothing);
    expect(find.byType(RiskMatrixCellView), findsNWidgets(25));
    expect(find.byType(RiskDetailsSummary), findsNothing);
  });
}
