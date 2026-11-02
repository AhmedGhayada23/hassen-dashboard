import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/constants/app_layout.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/domain/usecases/approve_inspection.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/domain/usecases/get_inspections.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/domain/usecases/reset_inspection_decision.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/domain/usecases/return_inspection.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/presentation/cubits/inspection_review_cubit.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/presentation/pages/dashboard_inspection_review_page.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/presentation/widgets/inspection_review_details.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/presentation/widgets/inspection_review_list.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/domain/entities/nav_destination.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/presentation/cubits/dashboard_navigation_cubit.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/presentation/widgets/sidebar/dashboard_sidebar.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/presentation/widgets/sidebar/sidebar_nav_item.dart';

import '../../../../helpers/test_view.dart';
import '../../helpers/fake_inspection_review_repository.dart';

void main() {
  late FakeInspectionReviewRepository repository;
  late InspectionReviewCubit reviewCubit;
  late DashboardNavigationCubit navigationCubit;

  setUp(() {
    repository = FakeInspectionReviewRepository();
    reviewCubit = InspectionReviewCubit(
      getInspections: GetInspections(repository),
      approveInspection: ApproveInspection(repository),
      returnInspection: ReturnInspection(repository),
      resetDecision: ResetInspectionDecision(repository),
    );
    navigationCubit = DashboardNavigationCubit();
  });
  tearDown(() {
    reviewCubit.close();
    navigationCubit.close();
  });

  Future<void> pumpPage(WidgetTester tester, {bool load = true}) async {
    useDesktopView(tester);
    ignoreTestFontOverflow();
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: navigationCubit),
          BlocProvider.value(value: reviewCubit),
        ],
        child: ScreenUtilInit(
          designSize: AppLayout.designSize,
          builder: (_, _) => const MaterialApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: DashboardInspectionReviewPage(),
            ),
          ),
        ),
      ),
    );
    if (load) {
      await reviewCubit.load();
      await tester.pumpAndSettle();
    }
  }

  /// Text of the "مراجعة التفتيش" sidebar counter, or null when hidden.
  String? reviewBadge(WidgetTester tester) {
    final badge = find.descendant(
      of: find.widgetWithText(SidebarNavItem, 'مراجعة التفتيش'),
      matching: find.byType(SidebarNavBadge),
    );
    if (badge.evaluate().isEmpty) return null;
    return tester
        .widget<Text>(find.descendant(of: badge, matching: find.byType(Text)))
        .data;
  }

  Future<void> tapAndSettle(WidgetTester tester, String text) async {
    await tester.tap(find.text(text).last);
    await tester.pumpAndSettle();
  }

  testWidgets('shows a spinner while loading, then list and details', (
    tester,
  ) async {
    repository.gate = Completer<void>();
    await pumpPage(tester, load: false);
    unawaited(reviewCubit.load());
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // Before data arrives the sidebar keeps the static counter.
    expect(reviewBadge(tester), '4');

    repository.gate!.complete();
    await tester.pumpAndSettle();
    expect(find.byType(InspectionReviewList), findsOneWidget);
    expect(find.byType(InspectionReviewDetails), findsOneWidget);
  });

  testWidgets('lays out a 320px list and the details side by side in RTL', (
    tester,
  ) async {
    await pumpPage(tester);

    expect(tester.getSize(find.byType(InspectionReviewList)).width, 320);
    final list = tester.getRect(find.byType(InspectionReviewList));
    final details = tester.getRect(find.byType(InspectionReviewDetails));
    expect(list.left - details.right, 16);
    expect(tester.getTopRight(find.byType(DashboardSidebar)).dx, 1440);
    expect(navigationCubit.state, NavDestination.inspectionReview);
  });

  testWidgets('selecting a report swaps the details', (tester) async {
    await pumpPage(tester);
    expect(
      find.text('INS-0418 · تفتيش المنشآت الصحية v2 · م. أحمد · 2026-10-28'),
      findsOneWidget,
    );

    await tapAndSettle(tester, 'بنك فلسطين');

    expect(
      find.text('INS-0415 · تفتيش المكاتب والفروع v1 · م. ليلى · 2026-10-26'),
      findsOneWidget,
    );
    expect(find.text('96%'), findsOneWidget);
  });

  testWidgets(
    'approve: banner, buttons gone, list pill and sidebar counter update',
    (tester) async {
      await pumpPage(tester);
      expect(reviewBadge(tester), '4');

      await tapAndSettle(tester, 'اعتماد ونشر للمنشأة');

      expect(
        find.text('تم الاعتماد — النتائج ظاهرة الآن لدى المنشأة'),
        findsOneWidget,
      );
      expect(find.text('اعتماد ونشر للمنشأة'), findsNothing);
      expect(find.text('معتمد'), findsOneWidget);
      expect(reviewBadge(tester), '3');
    },
  );

  testWidgets('return then undo: banner, then buttons and counter come back', (
    tester,
  ) async {
    await pumpPage(tester);

    await tapAndSettle(tester, 'إعادة للمفتش');
    expect(find.text('أُعيد للمفتش مع ملاحظات'), findsOneWidget);
    expect(reviewBadge(tester), '3');

    await tapAndSettle(tester, 'تراجع');
    expect(find.text('اعتماد ونشر للمنشأة'), findsOneWidget);
    expect(find.text('أُعيد للمفتش مع ملاحظات'), findsNothing);
    expect(reviewBadge(tester), '4');
  });

  testWidgets('the sidebar counter disappears once every report is decided', (
    tester,
  ) async {
    await pumpPage(tester);

    for (final facility in [
      'مستشفى الشفاء',
      'بلدية غزة',
      'مصنع العودة',
      'بنك فلسطين',
    ]) {
      await tapAndSettle(tester, facility);
      await tapAndSettle(tester, 'اعتماد ونشر للمنشأة');
    }

    expect(reviewBadge(tester), isNull);
  });

  testWidgets('a failed save shows a message and keeps the buttons', (
    tester,
  ) async {
    await pumpPage(tester);
    repository.updateFailure = const CacheFailure();

    await tester.tap(find.text('اعتماد ونشر للمنشأة'));
    await tester.pump();

    expect(find.text('تعذّر حفظ القرار، حاول مرة أخرى'), findsOneWidget);
    expect(find.text('اعتماد ونشر للمنشأة'), findsOneWidget);
    expect(reviewBadge(tester), '4');
  });

  testWidgets('shows an error with retry when loading fails', (tester) async {
    repository.loadFailure = const CacheFailure();
    await pumpPage(tester);
    expect(find.text('تعذّر تحميل بيانات لوحة التحكم'), findsOneWidget);

    repository.loadFailure = null;
    await tapAndSettle(tester, 'إعادة المحاولة');

    expect(find.byType(InspectionReviewDetails), findsOneWidget);
  });
}
