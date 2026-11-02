import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/constants/app_layout.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/features/dashboard_clients/domain/entities/client_registration_options.dart';
import 'package:hassen_dashboard/features/dashboard_clients/domain/entities/client_stage.dart';
import 'package:hassen_dashboard/features/dashboard_clients/domain/entities/new_client.dart';
import 'package:hassen_dashboard/features/dashboard_clients/domain/usecases/add_client.dart';
import 'package:hassen_dashboard/features/dashboard_clients/domain/usecases/get_client_registration_options.dart';
import 'package:hassen_dashboard/features/dashboard_clients/domain/usecases/get_clients.dart';
import 'package:hassen_dashboard/features/dashboard_clients/presentation/cubits/dashboard_clients_cubit.dart';
import 'package:hassen_dashboard/features/dashboard_clients/presentation/pages/dashboard_clients_page.dart';
import 'package:hassen_dashboard/features/dashboard_clients/presentation/widgets/add_client_dialog.dart';
import 'package:hassen_dashboard/features/dashboard_clients/presentation/widgets/client_details_panel.dart';
import 'package:hassen_dashboard/features/dashboard_clients/presentation/widgets/client_table_row.dart';
import 'package:hassen_dashboard/features/dashboard_clients/presentation/widgets/clients_skeleton.dart';
import 'package:hassen_dashboard/features/dashboard_clients/presentation/widgets/clients_table.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/domain/entities/nav_destination.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/presentation/cubits/dashboard_navigation_cubit.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/presentation/widgets/sidebar/dashboard_sidebar.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:hassen_dashboard/shared/visit_scheduling/visit_scheduler.dart';
import 'package:toastification/toastification.dart';

import '../../../../helpers/test_view.dart';
import '../../../../helpers/fake_visit_scheduler.dart';
import '../../helpers/fake_clients_repository.dart';

void main() {
  late FakeClientsRepository repository;
  late DashboardClientsCubit clientsCubit;
  late DashboardNavigationCubit navigationCubit;
  late FakeVisitScheduler visitScheduler;

  setUp(() {
    repository = FakeClientsRepository();
    clientsCubit = DashboardClientsCubit(
      GetClients(repository),
      GetClientRegistrationOptions(repository),
      AddClient(repository),
    );
    navigationCubit = DashboardNavigationCubit();
    visitScheduler = FakeVisitScheduler();
  });
  tearDown(() {
    clientsCubit.close();
    navigationCubit.close();
  });

  Future<void> pumpPage(WidgetTester tester, {bool load = true}) async {
    useDesktopView(tester);
    ignoreTestFontOverflow();
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          RepositoryProvider<VisitScheduler>.value(value: visitScheduler),
          BlocProvider.value(value: navigationCubit),
          BlocProvider.value(value: clientsCubit),
        ],
        child: ScreenUtilInit(
          designSize: AppLayout.designSize,
          builder: (_, _) => const ToastificationWrapper(
            child: MaterialApp(
              home: Directionality(
                textDirection: TextDirection.rtl,
                child: DashboardClientsPage(),
              ),
            ),
          ),
        ),
      ),
    );
    if (load) {
      await clientsCubit.load();
      await tester.pumpAndSettle();
    }
  }

  String? panelName(WidgetTester tester) => tester
      .widget<ClientDetailsPanel>(find.byType(ClientDetailsPanel))
      .client
      ?.name;

  Future<void> tapAndSettle(WidgetTester tester, String text) async {
    await tester.tap(find.text(text).first);
    await tester.pumpAndSettle();
  }

  testWidgets('shows a skeleton while loading, then the table and details', (
    tester,
  ) async {
    repository.gate = Completer<void>();
    await pumpPage(tester, load: false);
    unawaited(clientsCubit.load());
    await tester.pump();
    expect(find.byType(ClientsSkeleton), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is Skeletonizer), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    repository.gate!.complete();
    await tester.pumpAndSettle();
    expect(find.byType(ClientTableRow), findsNWidgets(8));
    expect(panelName(tester), 'مستشفى الشفاء');
  });

  testWidgets(
    'RTL layout: sidebar right, 340px panel, 16px gap, clients active',
    (tester) async {
      await pumpPage(tester);

      expect(tester.getTopRight(find.byType(DashboardSidebar)).dx, 1440);
      expect(navigationCubit.state, NavDestination.clients);
      expect(tester.getSize(find.byType(ClientDetailsPanel)).width, 340);
      final table = tester.getRect(find.byType(ClientsTable));
      final panel = tester.getRect(find.byType(ClientDetailsPanel));
      expect(table.left - panel.right, 16);
    },
  );

  testWidgets('tapping a row updates the details panel', (tester) async {
    await pumpPage(tester);

    await tapAndSettle(tester, 'بنك فلسطين');

    expect(panelName(tester), 'بنك فلسطين');
    expect(find.text('مدير المرافق'), findsOneWidget);
  });

  testWidgets('filtering keeps a visible selection and replaces a hidden one', (
    tester,
  ) async {
    await pumpPage(tester);
    await tapAndSettle(tester, 'بنك فلسطين');

    await tapAndSettle(tester, 'متعاقد (5)');
    expect(find.byType(ClientTableRow), findsNWidgets(5));
    expect(panelName(tester), 'بنك فلسطين');

    await tapAndSettle(tester, 'عرض سعر (1)');
    expect(find.byType(ClientTableRow), findsOneWidget);
    expect(panelName(tester), 'مجمع تجاري — المنطقة الوسطى');
    final selected = tester
        .widgetList<ClientTableRow>(find.byType(ClientTableRow))
        .where((r) => r.isSelected);
    expect(selected.single.client.id, 'CL-006');
  });

  testWidgets('"جدولة زيارة" books a visit at the selected client', (
    tester,
  ) async {
    await pumpPage(tester);
    await tapAndSettle(tester, 'بلدية غزة');

    await tester.tap(find.text('جدولة زيارة'));
    await tester.pumpAndSettle();

    expect(visitScheduler.facilities, ['بلدية غزة']);
  });

  testWidgets('"التقارير" still shows the original demo snackbar text', (
    tester,
  ) async {
    await pumpPage(tester);
    await tapAndSettle(tester, 'بلدية غزة');

    // "التقارير" is also a sidebar item, so look only inside the page content.
    await tester.tap(
      find.descendant(
        of: find.byType(SingleChildScrollView),
        matching: find.text('التقارير'),
      ),
    );
    await tester.pump();
    expect(find.text('نموذج توضيحي — تقارير بلدية غزة'), findsOneWidget);
  });

  testWidgets('shows an error with retry when loading fails', (tester) async {
    repository.failure = const CacheFailure();
    await pumpPage(tester);
    expect(find.text('تعذّر تحميل بيانات لوحة التحكم'), findsOneWidget);

    repository.failure = null;
    await tapAndSettle(tester, 'إعادة المحاولة');

    expect(find.byType(ClientTableRow), findsNWidgets(8));
  });

  group('new client', () {
    const school = NewClient(
      name: 'مدرسة النور',
      sector: 'مؤسسة تعليمية',
      branches: 2,
      city: 'خان يونس',
      address: 'شارع البحر',
      contactName: 'أ. محمود',
      contactTitle: 'مدير المدرسة',
      phone: '0599 123456',
      stage: ClientStage.inspection,
      inspector: 'م. ليلى',
    );

    testWidgets('"+ عميل جديد" opens the form; cancelling adds nobody', (
      tester,
    ) async {
      await pumpPage(tester);

      await tester.tap(find.text('+ عميل جديد'));
      await tester.pumpAndSettle();
      expect(find.byType(AddClientDialog), findsOneWidget);
      expect(find.text('عميل جديد'), findsOneWidget);

      await tester.tap(find.text('إلغاء'));
      await tester.pumpAndSettle();
      expect(find.byType(AddClientDialog), findsNothing);
      expect(repository.added, isEmpty);
      expect(find.byType(ClientTableRow), findsNWidgets(8));
    });

    testWidgets(
      'an added client joins the table, is selected under "الكل", and is confirmed',
      (tester) async {
        await pumpPage(tester);
        await tapAndSettle(tester, 'متعاقد (5)');

        await clientsCubit.addClient(school);
        await tester.pumpAndSettle();

        expect(find.byType(ClientTableRow), findsNWidgets(9));
        expect(find.text('الكل (9)'), findsOneWidget);
        expect(find.text('معاينة (2)'), findsOneWidget);
        expect(panelName(tester), 'مدرسة النور');
        for (final fact in [
          'خان يونس، شارع البحر',
          'فحص أولي مطلوب',
          'م. ليلى',
          'أ. محمود — مدير المدرسة',
        ]) {
          expect(
            find.descendant(
              of: find.byType(ClientDetailsPanel),
              matching: find.text(fact),
            ),
            findsOneWidget,
            reason: fact,
          );
        }
        expect(
          find.text('أُضيف مدرسة النور — بانتظار جدولة الفحص الأولي'),
          findsOneWidget,
        );

        await tester.tap(find.text('جدولة الآن'));
        await tester.pumpAndSettle();
        expect(visitScheduler.facilities, ['مدرسة النور']);
        // Let the toast run out so no timer outlives the test.
        await tester.pump(const Duration(seconds: 6));
        await tester.pumpAndSettle();
      },
    );

    testWidgets('without a pre-inspection, the confirmation has no action', (
      tester,
    ) async {
      await pumpPage(tester);

      await clientsCubit.addClient(
        const NewClient(
          name: 'فندق الأمواج',
          sector: 'فنادق وضيافة',
          branches: 1,
          contactName: 'مدير الفندق',
          email: 'info@waves.ps',
          stage: ClientStage.quotation,
          schedulePreInspection: false,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('أُضيف فندق الأمواج إلى سجل العملاء'), findsOneWidget);
      expect(find.text('جدولة الآن'), findsNothing);
      // Let the toast run out so no timer outlives the test.
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();
    });

    testWidgets('a failed registration shows an error toast', (tester) async {
      repository.addFailure = const CacheFailure();
      await pumpPage(tester);

      await clientsCubit.addClient(school);
      await tester.pumpAndSettle();

      expect(find.text('تعذّرت إضافة العميل. حاول مرة أخرى.'), findsOneWidget);
      expect(find.byType(ClientTableRow), findsNWidgets(8));
      // Let the toast run out so no timer outlives the test.
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();
    });

    testWidgets(
      'when the inspectors cannot be read, the form stays closed and says why',
      (tester) async {
        repository.optionsFailure = const ForbiddenFailure();
        await pumpPage(tester);

        await tester.tap(find.text('+ عميل جديد'));
        await tester.pumpAndSettle();

        expect(find.byType(AddClientDialog), findsNothing);
        expect(
          find.text(
            'لا توجد صلاحية لقراءة القطاعات أو المفتشين. راجع قواعد Firestore.',
          ),
          findsOneWidget,
        );
        // Let the toast run out so no timer outlives the test.
        await tester.pump(const Duration(seconds: 6));
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'with no sectors in Firebase, the form stays closed and says why',
      (tester) async {
        repository.options = const ClientRegistrationOptions(
          sectors: [],
          inspectors: [],
        );
        await pumpPage(tester);

        await tester.tap(find.text('+ عميل جديد'));
        await tester.pumpAndSettle();

        expect(find.byType(AddClientDialog), findsNothing);
        expect(
          find.textContaining('لا توجد قطاعات في جدول sectors'),
          findsOneWidget,
        );
        // Let the toast run out so no timer outlives the test.
        await tester.pump(const Duration(seconds: 6));
        await tester.pumpAndSettle();
      },
    );

    testWidgets('an empty clients collection invites adding the first client', (
      tester,
    ) async {
      repository.clients = [];
      await pumpPage(tester);

      expect(find.byType(ClientTableRow), findsNothing);
      expect(
        find.text('لا يوجد عملاء بعد. أضف أول عميل من «+ عميل جديد».'),
        findsOneWidget,
      );
      expect(find.text('لا يوجد عميل محدد'), findsOneWidget);
      expect(find.text('الكل (0)'), findsOneWidget);
    });

    testWidgets('a refused read of clients explains how to fix it', (
      tester,
    ) async {
      repository.failure = const ForbiddenFailure();
      await pumpPage(tester);

      expect(find.text('تعذّر تحميل بيانات لوحة التحكم'), findsOneWidget);
      expect(
        find.text('لا توجد صلاحية لقراءة جدول clients. راجع قواعد Firestore.'),
        findsOneWidget,
      );
    });

    testWidgets('the original clients show "غزة" as their city', (
      tester,
    ) async {
      await pumpPage(tester);

      expect(find.text('المدينة / العنوان'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ClientDetailsPanel),
          matching: find.text('غزة'),
        ),
        findsOneWidget,
      );
    });
  });
}
