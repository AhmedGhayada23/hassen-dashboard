import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/constants/app_layout.dart';
import 'package:hassen_dashboard/core/theme/app_colors.dart';
import 'package:hassen_dashboard/core/widgets/status_badge.dart';
import 'package:hassen_dashboard/features/dashboard_contracts/domain/entities/contract_plan.dart';
import 'package:hassen_dashboard/features/dashboard_contracts/presentation/cubits/dashboard_contracts_cubit.dart';
import 'package:hassen_dashboard/features/dashboard_contracts/presentation/pages/dashboard_contracts_page.dart';
import 'package:hassen_dashboard/features/dashboard_contracts/presentation/widgets/deal_decision_buttons.dart';
import 'package:hassen_dashboard/features/dashboard_contracts/presentation/widgets/deal_plan_cell.dart';
import 'package:hassen_dashboard/features/dashboard_contracts/presentation/widgets/deal_table_row.dart';
import 'package:hassen_dashboard/features/dashboard_contracts/presentation/widgets/deals_skeleton.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/domain/entities/nav_destination.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/presentation/cubits/dashboard_navigation_cubit.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:toastification/toastification.dart';

import '../../../../helpers/test_view.dart';
import '../../helpers/contracts_cubit_factory.dart';
import '../../helpers/fake_contracts_remote_datasource.dart';

void main() {
  late FakeContractsRemoteDataSource remote;
  late DashboardContractsCubit contractsCubit;
  late DashboardNavigationCubit navigationCubit;

  setUp(() {
    remote = FakeContractsRemoteDataSource();
    contractsCubit = buildContractsCubit(buildContractsRepository(remote));
    navigationCubit = DashboardNavigationCubit();
  });
  tearDown(() {
    contractsCubit.close();
    navigationCubit.close();
  });

  Future<void> pumpPage(WidgetTester tester, {bool load = true}) async {
    useDesktopView(tester);
    ignoreTestFontOverflow();
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: navigationCubit),
          BlocProvider.value(value: contractsCubit),
        ],
        child: ScreenUtilInit(
          designSize: AppLayout.designSize,
          builder: (_, _) => const ToastificationWrapper(
            child: MaterialApp(
              home: Directionality(
                textDirection: TextDirection.rtl,
                child: DashboardContractsPage(),
              ),
            ),
          ),
        ),
      ),
    );
    if (load) {
      await contractsCubit.load();
      await tester.pumpAndSettle();
    }
  }

  // Rows are found by their quote number.
  Finder rowOf(String number) =>
      find.ancestor(of: find.text(number), matching: find.byType(DealTableRow));
  Finder inRow(String number, Finder finder) =>
      find.descendant(of: rowOf(number), matching: finder);
  const mall = 'Q-2026-005', school = 'Q-2026-004', power = 'Q-2025-003';
  const transport = 'Q-2025-002', gaza = 'Q-2025-001', bank = 'Q-2026-027';

  /// Lets a toast run out so no timer outlives the test.
  Future<void> waitOutToast(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
  }

  testWidgets('the intro, the six headers and every client, pending first', (
    tester,
  ) async {
    await pumpPage(tester);

    expect(navigationCubit.state, NavDestination.contracts);
    expect(
      find.text(
        'كل عميل جديد يُدرج هنا تلقائياً بانتظار القرار. بعد القبول اختر مدة التعاقد.',
      ),
      findsOneWidget,
    );
    for (final header in [
      'الرقم',
      'العميل',
      'التاريخ',
      'الحالة',
      'مدة التعاقد',
      'الإجراءات',
    ]) {
      expect(find.text(header), findsOneWidget);
    }
    final rows = tester.widgetList<DealTableRow>(find.byType(DealTableRow));
    expect(
      [for (final r in rows) r.deal.number],
      [mall, school, 'Q-2026-003', 'Q-2026-002', bank, power, gaza, transport],
    );
    expect(inRow(mall, find.text('2026-10-20')), findsOneWidget);
  });

  testWidgets('every deal offers the decisions it doesn\'t already have', (
    tester,
  ) async {
    await pumpPage(tester);

    StatusBadge pill(String id) =>
        tester.widget<StatusBadge>(inRow(id, find.byType(StatusBadge)));
    expect(
      (pill(mall).text, pill(mall).background),
      ('بانتظار القرار', HaseenColors.warningSoft),
    );
    expect(
      (pill(bank).text, pill(bank).foreground),
      ('مقبول', HaseenColors.successText),
    );
    expect(
      (pill(transport).text, pill(transport).foreground),
      ('مرفوض', HaseenColors.red),
    );

    expect(find.byType(DealDecisionButtons), findsNWidgets(8));
    expect(inRow(mall, find.text('قبول العقد')), findsOneWidget);
    expect(inRow(mall, find.text('رفض')), findsOneWidget);
    expect(inRow(bank, find.text('قبول العقد')), findsNothing);
    expect(inRow(bank, find.text('رفض')), findsOneWidget);
    expect(inRow(transport, find.text('قبول العقد')), findsOneWidget);
    expect(inRow(transport, find.text('رفض')), findsNothing);

    expect(find.byType(DealPlanCell), findsNWidgets(5));
    expect(inRow(transport, find.text('—')), findsOneWidget);
    expect(inRow(power, find.text('6 شهور')), findsOneWidget);
    expect(inRow(power, find.text('2026-07-01 ← 2026-12-31')), findsOneWidget);
    expect(inRow(gaza, find.text('2025-12-16 ← 2026-12-15')), findsOneWidget);
  });

  testWidgets('accepting saves it to the client, then a length shows its '
      'period', (tester) async {
    await pumpPage(tester);

    await tester.tap(inRow(mall, find.text('قبول العقد')));
    await tester.pumpAndSettle();

    expect(
      find.text('قُبل العقد — مجمع تجاري — المنطقة الوسطى. اختر مدة التعاقد'),
      findsOneWidget,
    );
    expect(remote.updates.single.$1, 'c-mall');
    expect(inRow(mall, find.text('مقبول')), findsOneWidget);
    expect(inRow(mall, find.text('قبول العقد')), findsNothing);
    expect(inRow(mall, find.text('رفض')), findsOneWidget);
    expect(inRow(mall, find.text(DealPlanCell.hint)), findsOneWidget);
    await waitOutToast(tester);

    await tester.tap(
      inRow(mall, find.byType(DropdownButtonFormField<ContractPlan>)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('3 شهور').last);
    await tester.pumpAndSettle();

    expect(inRow(mall, find.text('2026-11-02 ← 2027-02-01')), findsOneWidget);
    expect(remote.updates.last.$2['contract'], '2026-11-02 ← 2027-02-01');
  });

  testWidgets('rejecting a pending quote needs no confirmation', (
    tester,
  ) async {
    await pumpPage(tester);

    await tester.tap(inRow(school, find.text('رفض')));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('رُفض العقد — مدرسة خاصة — غزة'), findsOneWidget);
    expect(inRow(school, find.text('مرفوض')), findsOneWidget);
    expect(inRow(school, find.text('قبول العقد')), findsOneWidget);
    await waitOutToast(tester);
  });

  testWidgets('cancelling an accepted contract is confirmed first', (
    tester,
  ) async {
    await pumpPage(tester);

    await tester.tap(inRow(power, find.text('رفض')));
    await tester.pumpAndSettle();
    expect(find.text('رفض عقد شركة كهرباء غزة؟'), findsOneWidget);
    await tester.tap(find.text('إلغاء'));
    await tester.pumpAndSettle();
    expect(remote.updates, isEmpty);
    expect(inRow(power, find.text('مقبول')), findsOneWidget);

    await tester.tap(inRow(power, find.text('رفض')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('رفض العقد'));
    await tester.pumpAndSettle();

    expect(remote.updates.single.$1, 'c-power');
    expect(inRow(power, find.text('مرفوض')), findsOneWidget);
    expect(inRow(power, find.byType(DealPlanCell)), findsNothing);
    await waitOutToast(tester);
  });

  testWidgets('a rejected quote can be accepted after all', (tester) async {
    await pumpPage(tester);
    // The last row sits below the fold with the test font.
    await tester.ensureVisible(inRow(transport, find.text('قبول العقد')));
    await tester.pumpAndSettle();

    await tester.tap(inRow(transport, find.text('قبول العقد')));
    await tester.pumpAndSettle();

    expect(inRow(transport, find.text('مقبول')), findsOneWidget);
    expect(inRow(transport, find.byType(DealPlanCell)), findsOneWidget);
    await waitOutToast(tester);
  });

  testWidgets('changing an accepted deal\'s length updates its period', (
    tester,
  ) async {
    await pumpPage(tester);

    await tester.tap(find.text('6 شهور'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('سنوي — يتجدد تلقائياً').last);
    await tester.pumpAndSettle();

    expect(inRow(power, find.text('2026-07-01 ← 2027-06-30')), findsOneWidget);
  });

  testWidgets('a change that can\'t be saved is reported', (tester) async {
    await pumpPage(tester);
    remote.error = FirebaseException(
      plugin: 'cloud_firestore',
      code: 'permission-denied',
    );

    await tester.tap(inRow(mall, find.text('قبول العقد')));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'لا توجد صلاحية لتعديل العميل في جدول clients. راجع قواعد Firestore.',
      ),
      findsOneWidget,
    );
    expect(inRow(mall, find.text('بانتظار القرار')), findsOneWidget);
    await waitOutToast(tester);
  });

  testWidgets('a skeleton while loading', (tester) async {
    await pumpPage(tester, load: false);

    expect(find.byType(DealsSkeleton), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is Skeletonizer), findsOneWidget);
  });

  testWidgets('a load error explains itself, and retry loads', (tester) async {
    remote.error = FirebaseException(
      plugin: 'cloud_firestore',
      code: 'permission-denied',
    );
    await pumpPage(tester);

    expect(
      find.text('لا توجد صلاحية لقراءة جدول clients. راجع قواعد Firestore.'),
      findsOneWidget,
    );

    remote.error = null;
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pumpAndSettle();
    expect(find.byType(DealTableRow), findsNWidgets(8));
  });

  testWidgets('no clients yet says where to add them', (tester) async {
    remote.clients.clear();
    await pumpPage(tester);

    expect(
      find.text('لا يوجد عملاء بعد. أضفهم من صفحة «العملاء والمنشآت».'),
      findsOneWidget,
    );
  });
}
