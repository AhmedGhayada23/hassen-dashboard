import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/constants/app_layout.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/features/visits/domain/usecases/get_visit_schedule.dart';
import 'package:hassen_dashboard/features/visits/domain/usecases/get_visit_scheduling_options.dart';
import 'package:hassen_dashboard/features/visits/domain/usecases/schedule_visit.dart';
import 'package:hassen_dashboard/features/visits/presentation/cubits/dashboard_visits_cubit.dart';
import 'package:hassen_dashboard/features/visits/presentation/cubits/dashboard_visits_state.dart';
import 'package:hassen_dashboard/features/visits/presentation/pages/dashboard_visits_page.dart';
import 'package:hassen_dashboard/features/visits/presentation/widgets/schedule_visit_dialog.dart';
import 'package:hassen_dashboard/features/visits/presentation/widgets/visit_chip.dart';
import 'package:hassen_dashboard/features/visits/presentation/widgets/visit_details_dialog.dart';
import 'package:hassen_dashboard/features/visits/presentation/widgets/visit_task_text.dart';
import 'package:hassen_dashboard/features/visits/presentation/widgets/visits_legend.dart';
import 'package:hassen_dashboard/features/visits/presentation/widgets/visits_page_header.dart';
import 'package:hassen_dashboard/features/visits/presentation/widgets/visits_schedule_grid.dart';
import 'package:hassen_dashboard/features/visits/presentation/widgets/visits_skeleton.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/domain/entities/nav_destination.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/presentation/cubits/dashboard_navigation_cubit.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/presentation/widgets/sidebar/dashboard_sidebar.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:toastification/toastification.dart';

import '../../../../helpers/test_view.dart';
import '../../fixtures/visits_fixture.dart';
import '../../helpers/fake_visits_repository.dart';

void main() {
  late FakeVisitsRepository repository;
  late DashboardVisitsCubit visitsCubit;
  late DashboardNavigationCubit navigationCubit;

  setUp(() {
    repository = FakeVisitsRepository(Right(expectedSchedule));
    visitsCubit = DashboardVisitsCubit(
      GetVisitSchedule(repository),
      GetVisitSchedulingOptions(repository),
      ScheduleVisit(repository),
    );
    navigationCubit = DashboardNavigationCubit();
  });
  tearDown(() {
    visitsCubit.close();
    navigationCubit.close();
  });

  Future<void> pumpPage(WidgetTester tester, {bool load = true}) async {
    useDesktopView(tester);
    ignoreTestFontOverflow();
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: navigationCubit),
          BlocProvider.value(value: visitsCubit),
        ],
        child: ScreenUtilInit(
          designSize: AppLayout.designSize,
          builder: (_, _) => const ToastificationWrapper(
            child: MaterialApp(
              home: Directionality(
                textDirection: TextDirection.rtl,
                child: DashboardVisitsPage(),
              ),
            ),
          ),
        ),
      ),
    );
    if (load) {
      await visitsCubit.load();
      await tester.pumpAndSettle();
    }
  }

  testWidgets('shows a skeleton while loading', (tester) async {
    repository.gate = Completer<void>();
    await pumpPage(tester, load: false);
    unawaited(visitsCubit.load());
    await tester.pump();

    expect(find.byType(VisitsSkeleton), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is Skeletonizer), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    repository.gate!.complete();
    await tester.pumpAndSettle();
    expect(find.byType(VisitsSkeleton), findsNothing);
    expect(find.byType(VisitsScheduleGrid), findsOneWidget);
  });

  testWidgets('composes header, grid and legend in the original order', (
    tester,
  ) async {
    await pumpPage(tester);

    expect(find.text('جدول الزيارات'), findsWidgets);
    double top(Type t) => tester.getTopLeft(find.byType(t)).dy;
    expect(top(VisitsPageHeader), lessThan(top(VisitsScheduleGrid)));
    expect(top(VisitsScheduleGrid), lessThan(top(VisitsLegend)));
    expect(find.byType(VisitChip), findsNWidgets(13));
  });

  testWidgets(
    'RTL with the 240px sidebar on the right, schedule marked active, bell dot on',
    (tester) async {
      await pumpPage(tester);

      final sidebar = find.byType(DashboardSidebar);
      expect(tester.getSize(sidebar).width, 240);
      expect(tester.getTopRight(sidebar).dx, 1440);
      expect(navigationCubit.state, NavDestination.visitSchedule);
      expect(tester.widget<Badge>(find.byType(Badge)).isLabelVisible, isTrue);
    },
  );

  testWidgets('tapping a visit opens its details', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('15:00 · مصنع العودة'));
    await tester.pumpAndSettle();

    expect(find.byType(VisitDetailsPanel), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(VisitDetailsPanel),
        matching: find.text('متابعة · الأربعاء 28 · 15:00 · م. خالد'),
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'a booked visit shows its task count on the grid and its tasks on tap',
    (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text('+ جدولة زيارة'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('جدولة وإسناد'));
      await tester.pumpAndSettle();

      final booked = repository.added.single;
      expect(booked.tasks, hasLength(3));
      final chip = find.ancestor(
        of: find.text('10:00 · مستشفى الشفاء').last,
        matching: find.byType(VisitChip),
      );
      expect(
        find.descendant(of: chip, matching: find.text('3 مهام')),
        findsOneWidget,
      );

      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();
      await tester.tap(chip);
      await tester.pumpAndSettle();

      expect(find.byType(VisitTaskTile), findsNWidgets(3));
    },
  );

  testWidgets(
    'scheduling a visit adds it to the grid, updates the load and confirms it',
    (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text('+ جدولة زيارة'));
      await tester.pumpAndSettle();
      expect(find.byType(ScheduleVisitDialog), findsOneWidget);

      await tester.tap(find.text('جدولة وإسناد'));
      await tester.pumpAndSettle();

      expect(find.byType(ScheduleVisitDialog), findsNothing);
      expect(repository.added.single.inspector, layla);
      expect(find.byType(VisitChip), findsNWidgets(14));
      // Ahmad already has a Monday 10:00 at the same hospital; the new one is Layla's.
      expect(find.text('10:00 · مستشفى الشفاء'), findsNWidgets(2));
      expect(find.text('3 زيارات'), findsNWidgets(2));
      expect(
        find.text('تمت جدولة الزيارة وإسنادها إلى م. ليلى — الأربعاء 28 10:00'),
        findsOneWidget,
      );
      // Let the toast run out so no timer outlives the test.
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();
    },
  );

  testWidgets('cancelling the dialog schedules nothing', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('+ جدولة زيارة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('إلغاء'));
    await tester.pumpAndSettle();

    expect(repository.added, isEmpty);
    expect(find.byType(VisitChip), findsNWidgets(13));
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets(
    'a booking that fails is reported and leaves the grid as it was',
    (tester) async {
      repository.addFailure = const CacheFailure();
      await pumpPage(tester);

      await tester.tap(find.text('+ جدولة زيارة'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('جدولة وإسناد'));
      await tester.pumpAndSettle();

      expect(find.text('تعذّرت جدولة الزيارة. حاول مرة أخرى.'), findsOneWidget);
      expect(find.byType(VisitChip), findsNWidgets(13));
      // Let the toast run out so no timer outlives the test.
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();
    },
  );

  group('week navigation', () {
    final previous = find.byTooltip(VisitsPageHeader.previousWeekTooltip);
    final next = find.byTooltip(VisitsPageHeader.nextWeekTooltip);
    final current = find.text(VisitsPageHeader.currentWeekLabel);

    testWidgets(
      'the arrows sit either side of the week, previous on the right',
      (tester) async {
        await pumpPage(tester);

        final label = tester
            .getCenter(find.text(expectedSchedule.weekLabel))
            .dx;
        expect(tester.getCenter(previous).dx, greaterThan(label));
        expect(tester.getCenter(next).dx, lessThan(label));
        expect(current, findsNothing);
      },
    );

    testWidgets('the arrows load the next and previous weeks', (tester) async {
      await pumpPage(tester);

      await tester.tap(next);
      await tester.pumpAndSettle();
      await tester.tap(next);
      await tester.pumpAndSettle();
      await tester.tap(previous);
      await tester.pumpAndSettle();

      expect(repository.weekOffsets, [0, 1, 2, 1]);
      expect((visitsCubit.state as DashboardVisitsLoaded).weekOffset, 1);
    });

    testWidgets('away from this week, a button brings it back', (tester) async {
      await pumpPage(tester);

      await tester.tap(previous);
      await tester.pumpAndSettle();
      expect(current, findsOneWidget);

      await tester.tap(current);
      await tester.pumpAndSettle();

      expect(repository.weekOffsets, [0, -1, 0]);
      expect(current, findsNothing);
    });

    testWidgets('a visit is booked into the week shown', (tester) async {
      await pumpPage(tester);
      await tester.tap(next);
      await tester.pumpAndSettle();
      repository.weekOffsets.clear();

      await tester.tap(find.text('+ جدولة زيارة'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('جدولة وإسناد'));
      await tester.pumpAndSettle();

      expect(repository.added, hasLength(1));
      expect(repository.weekOffsets, [1, 1]);
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();
    });
  });

  testWidgets('shows an error with retry, and retry loads the schedule', (
    tester,
  ) async {
    repository.result = const Left(CacheFailure());
    await pumpPage(tester);

    expect(find.text('تعذّر تحميل بيانات لوحة التحكم'), findsOneWidget);

    repository.result = Right(expectedSchedule);
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pumpAndSettle();

    expect(find.byType(VisitChip), findsNWidgets(13));
  });
}
