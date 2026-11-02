import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/constants/app_layout.dart';
import 'package:hassen_dashboard/core/theme/app_colors.dart';
import 'package:hassen_dashboard/core/widgets/status_badge.dart';
import 'package:hassen_dashboard/features/dashboard_reports/domain/entities/report_month.dart';
import 'package:hassen_dashboard/features/dashboard_reports/presentation/cubits/dashboard_reports_cubit.dart';
import 'package:hassen_dashboard/features/dashboard_reports/presentation/pages/dashboard_reports_page.dart';
import 'package:hassen_dashboard/features/dashboard_reports/presentation/widgets/monthly_report_preview.dart';
import 'package:hassen_dashboard/features/dashboard_reports/presentation/widgets/monthly_report_row.dart';
import 'package:hassen_dashboard/features/dashboard_reports/presentation/widgets/report_activity_table.dart';
import 'package:hassen_dashboard/features/dashboard_reports/presentation/widgets/reports_skeleton.dart';
import 'package:hassen_dashboard/features/dashboard_reports/presentation/widgets/send_report_dialog.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/domain/entities/nav_destination.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/presentation/cubits/dashboard_navigation_cubit.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:toastification/toastification.dart';

import '../../../../helpers/test_view.dart';
import '../../helpers/fake_reports_remote_datasource.dart';
import '../../helpers/reports_cubit_factory.dart';

void main() {
  late FakeReportsRemoteDataSource remote;
  late DashboardReportsCubit reportsCubit;
  late DashboardNavigationCubit navigationCubit;

  setUp(() {
    remote = FakeReportsRemoteDataSource();
    reportsCubit = buildReportsCubit(buildReportsRepository(remote));
    navigationCubit = DashboardNavigationCubit();
  });
  tearDown(() {
    reportsCubit.close();
    navigationCubit.close();
  });

  Future<void> pumpPage(WidgetTester tester, {bool load = true}) async {
    useDesktopView(tester);
    ignoreTestFontOverflow();
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: navigationCubit),
          BlocProvider.value(value: reportsCubit),
        ],
        child: ScreenUtilInit(
          designSize: AppLayout.designSize,
          builder: (_, _) => const ToastificationWrapper(
            child: MaterialApp(
              home: Directionality(
                textDirection: TextDirection.rtl,
                child: DashboardReportsPage(),
              ),
            ),
          ),
        ),
      ),
    );
    if (load) {
      await reportsCubit.load();
      await tester.pumpAndSettle();
    }
  }

  Finder rowOf(String facility) => find.ancestor(
    of: find.text(facility),
    matching: find.byType(MonthlyReportRow),
  );
  Finder inRow(String facility, Finder finder) =>
      find.descendant(of: rowOf(facility), matching: finder);
  StatusBadge pillOf(WidgetTester tester, String facility) =>
      tester.widget<StatusBadge>(inRow(facility, find.byType(StatusBadge)));

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> showMonth(WidgetTester tester, String label) async {
    await tap(tester, find.byType(DropdownButtonFormField<ReportMonth>));
    await tap(tester, find.text(label).last);
  }

  Future<void> sendTo(WidgetTester tester, String to) async {
    await tester.enterText(
      find
          .descendant(
            of: find.byType(SendReportDialog),
            matching: find.byType(TextFormField),
          )
          .first,
      to,
    );
    await tap(tester, find.widgetWithText(FilledButton, 'إرسال'));
  }

  /// Lets a toast run out so no timer outlives the test.
  Future<void> waitOutToast(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
  }

  testWidgets('a skeleton while loading', (tester) async {
    await pumpPage(tester, load: false);

    expect(find.byType(ReportsSkeleton), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is Skeletonizer), findsOneWidget);
  });

  testWidgets('opens on this month with every contracted facility', (
    tester,
  ) async {
    await pumpPage(tester);

    expect(navigationCubit.state, NavDestination.reports);
    expect(find.text('نوفمبر 2026'), findsOneWidget);
    expect(find.text('3 منشآت متعاقدة · 0 تقارير مُرسلة'), findsOneWidget);
    final rows = tester.widgetList<MonthlyReportRow>(
      find.byType(MonthlyReportRow),
    );
    expect(
      [for (final r in rows) r.report.facility.name],
      ['بلدية غزة', 'بنك فلسطين', 'مستشفى الشفاء'],
    );
    expect(pillOf(tester, 'بنك فلسطين').text, 'جاهز للإرسال');
    expect(
      (
        pillOf(tester, 'بلدية غزة').text,
        pillOf(tester, 'بلدية غزة').background,
      ),
      ('لا توجد أنشطة', HaseenColors.soft),
    );
  });

  testWidgets('October counts what happened at each facility', (tester) async {
    await pumpPage(tester);

    await showMonth(tester, 'أكتوبر 2026');

    expect(inRow('مستشفى الشفاء', find.text('منشأة صحية')), findsOneWidget);
    expect(inRow('مستشفى الشفاء', find.text('4')), findsOneWidget);
    expect(inRow('مستشفى الشفاء', find.text('2')), findsOneWidget);
    expect(inRow('بلدية غزة', find.text('2')), findsOneWidget);
  });

  testWidgets('September shows the report already sent', (tester) async {
    await pumpPage(tester);

    await showMonth(tester, 'سبتمبر 2026');

    expect(find.text('3 منشآت متعاقدة · 1 تقارير مُرسلة'), findsOneWidget);
    expect(pillOf(tester, 'بلدية غزة').text, 'أُرسل 2026-10-02');
    expect(inRow('بلدية غزة', find.text('إعادة إرسال')), findsOneWidget);
  });

  testWidgets('the preview is built from the Firebase records', (tester) async {
    await pumpPage(tester);
    await showMonth(tester, 'أكتوبر 2026');

    await tap(tester, inRow('مستشفى الشفاء', find.text('معاينة')));

    final preview = find.byType(MonthlyReportPreview);
    Finder inPreview(String text) =>
        find.descendant(of: preview, matching: find.text(text));
    for (final text in [
      'HASEEN-2026-10-مستشفى-الشفاء.pdf',
      'أكتوبر 2026',
      'منشأة صحية',
      '2026-03-01 ← 2027-02-28',
      'تفتيش دوري — تفتيش المنشآت الصحية v2',
      'بلاغ: إعاقة مسار الإخلاء',
      'إزالة الأسرّة من أمام مخرج الطوارئ 2',
      'متأخر',
      'مجدولة',
      '3 بنود ما زالت مفتوحة وتُرحَّل للشهر القادم.',
    ]) {
      expect(inPreview(text), findsOneWidget, reason: text);
    }
    expect(find.byType(ReportActivityTable), findsOneWidget);
    expect(inPreview('بيانات تجريبية'), findsNothing);
  });

  testWidgets('sending records it in Firebase and says so', (tester) async {
    await pumpPage(tester);
    await showMonth(tester, 'أكتوبر 2026');
    await tap(tester, inRow('بنك فلسطين', find.text('إرسال عبر الإيميل')));

    await sendTo(tester, 'safety@bop.ps');

    expect(find.byType(SendReportDialog), findsNothing);
    expect(
      find.text(
        'سُجّل التقرير كمُرسَل إلى safety@bop.ps. الإرسال الفعلي بالبريد يحتاج ربط خدمة البريد',
      ),
      findsOneWidget,
    );
    expect(pillOf(tester, 'بنك فلسطين').text, 'أُرسل 2026-11-02');
    expect(remote.deliveries['c-bank_2026-10']?['to'], 'safety@bop.ps');
    await waitOutToast(tester);
  });

  testWidgets('the email form still checks the addresses', (tester) async {
    await pumpPage(tester);
    await tap(tester, inRow('بنك فلسطين', find.text('إرسال عبر الإيميل')));

    await tap(tester, find.widgetWithText(FilledButton, 'إرسال'));
    expect(find.text('أدخل بريد المنشأة'), findsOneWidget);

    await sendTo(tester, 'not-an-email');
    expect(find.text('صيغة البريد غير صحيحة'), findsOneWidget);
    expect(find.byType(SendReportDialog), findsOneWidget);
  });

  testWidgets('a send Firebase refuses is explained', (tester) async {
    await pumpPage(tester);
    await tap(tester, inRow('بنك فلسطين', find.text('إرسال عبر الإيميل')));
    remote.error = FirebaseException(
      plugin: 'cloud_firestore',
      code: 'permission-denied',
    );

    await sendTo(tester, 'safety@bop.ps');

    expect(
      find.text(
        'لا توجد صلاحية لحفظ الإرسال في جدول report_deliveries. راجع قواعد Firestore.',
      ),
      findsOneWidget,
    );
    expect(pillOf(tester, 'بنك فلسطين').text, 'جاهز للإرسال');
    await waitOutToast(tester);
  });

  testWidgets('a load error explains itself', (tester) async {
    remote.error = FirebaseException(
      plugin: 'cloud_firestore',
      code: 'permission-denied',
    );
    await pumpPage(tester);

    expect(
      find.textContaining('لا توجد صلاحية لقراءة بيانات التقارير'),
      findsOneWidget,
    );
  });

  testWidgets('no contracted facility yet says where to get one', (
    tester,
  ) async {
    remote.clients = [];
    await pumpPage(tester);

    expect(
      find.text(
        'لا توجد منشآت متعاقدة بعد. اقبل عقود العملاء من صفحة «العروض والعقود».',
      ),
      findsOneWidget,
    );
  });
}
