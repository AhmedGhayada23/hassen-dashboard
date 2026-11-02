import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/constants/app_layout.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/visit_facility.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/visit_status.dart';
import 'package:hassen_dashboard/features/visits/domain/usecases/get_visit_schedule.dart';
import 'package:hassen_dashboard/features/visits/domain/usecases/get_visit_scheduling_options.dart';
import 'package:hassen_dashboard/features/visits/domain/usecases/schedule_visit.dart';
import 'package:hassen_dashboard/features/visits/presentation/scheduling/dialog_visit_scheduler.dart';
import 'package:hassen_dashboard/features/visits/presentation/widgets/schedule_visit_dialog.dart';
import 'package:hassen_dashboard/features/visits/presentation/widgets/schedule_visit_field.dart';
import 'package:toastification/toastification.dart';

import '../../../../helpers/test_view.dart';
import '../../fixtures/visits_fixture.dart';
import '../../helpers/fake_visits_repository.dart';

void main() {
  late FakeVisitsRepository repository;
  late DialogVisitScheduler scheduler;

  setUp(() {
    repository = FakeVisitsRepository(Right(expectedSchedule));
    scheduler = DialogVisitScheduler(
      GetVisitSchedule(repository),
      GetVisitSchedulingOptions(repository),
      ScheduleVisit(repository),
    );
  });

  /// Opens the booking form for [facility] from a button, as a client's
  /// page does.
  Future<void> scheduleAt(WidgetTester tester, String facility) async {
    useDesktopView(tester);
    ignoreTestFontOverflow();
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: AppLayout.designSize,
        builder: (_, _) => ToastificationWrapper(
          child: MaterialApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                body: Builder(
                  builder: (context) => TextButton(
                    onPressed: () =>
                        scheduler.scheduleAt(context, facility: facility),
                    child: const Text('book'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('book'));
    await tester.pumpAndSettle();
  }

  /// Lets a toast run out so no timer outlives the test.
  Future<void> waitOutToast(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
  }

  testWidgets('opens the form with the facility fixed and its own type', (
    tester,
  ) async {
    await scheduleAt(tester, 'بنك فلسطين');

    expect(find.byType(ScheduleVisitDialog), findsOneWidget);
    expect(
      find.widgetWithText(ScheduleVisitFixedFacility, 'بنك فلسطين'),
      findsOneWidget,
    );
    expect(find.byType(DropdownButtonFormField<VisitFacility>), findsNothing);
    expect(find.text('تفتيش دوري'), findsWidgets);
    expect(
      find.text('التحقق من CA-0390: استبدال طفايات منتهية'),
      findsOneWidget,
    );
  });

  testWidgets('books the visit there and confirms it', (tester) async {
    await scheduleAt(tester, 'بنك فلسطين');

    await tester.tap(find.text('جدولة وإسناد'));
    await tester.pumpAndSettle();

    final visit = repository.added.single;
    expect(
      (visit.facility, visit.type, visit.status, visit.inspector),
      ('بنك فلسطين', 'تفتيش دوري', VisitStatus.planned, layla),
    );
    expect(visit.tasks.map((t) => t.id), ['tpl', 'CA-0390']);
    expect(
      find.text('تمت جدولة الزيارة وإسنادها إلى م. ليلى — الأربعاء 28 10:00'),
      findsOneWidget,
    );
    await waitOutToast(tester);
  });

  testWidgets('a facility without a contract is booked as a pre-contract '
      'check', (tester) async {
    await scheduleAt(tester, 'مدرسة خاصة — غزة');

    expect(
      find.widgetWithText(
        ScheduleVisitFixedFacility,
        'مدرسة خاصة — غزة — غير متعاقد',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('جدولة وإسناد'));
    await tester.pumpAndSettle();

    expect(repository.added.single.status, VisitStatus.preContract);
    await waitOutToast(tester);
  });

  testWidgets('cancelling books nothing and says nothing', (tester) async {
    await scheduleAt(tester, 'بنك فلسطين');

    await tester.tap(find.text('إلغاء'));
    await tester.pumpAndSettle();

    expect(repository.added, isEmpty);
    expect(find.byType(ScheduleVisitDialog), findsNothing);
    expect(find.byType(Toastification), findsNothing);
  });

  testWidgets('a client the schedule doesn\'t list is explained', (
    tester,
  ) async {
    await scheduleAt(tester, 'عميل محذوف');

    expect(find.byType(ScheduleVisitDialog), findsNothing);
    expect(
      find.text(
        'لم يُعثر على «عميل محذوف» في جدول clients. حدّث الصفحة وحاول مرة أخرى.',
      ),
      findsOneWidget,
    );
    await waitOutToast(tester);
  });

  testWidgets('a schedule that can\'t load is explained', (tester) async {
    repository.result = const Left(NetworkFailure());
    await scheduleAt(tester, 'بنك فلسطين');

    expect(find.byType(ScheduleVisitDialog), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(
      find.text('تعذّر الاتصال بالخادم. تحقق من الإنترنت وحاول مرة أخرى.'),
      findsOneWidget,
    );
    await waitOutToast(tester);
  });

  testWidgets('a booking that fails is explained', (tester) async {
    repository.addFailure = const ForbiddenFailure();
    await scheduleAt(tester, 'بنك فلسطين');

    await tester.tap(find.text('جدولة وإسناد'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'لا توجد صلاحية لحفظ الزيارة في جدول visits أو مهامها في جدول tasks. راجع قواعد Firestore.',
      ),
      findsOneWidget,
    );
    await waitOutToast(tester);
  });
}
