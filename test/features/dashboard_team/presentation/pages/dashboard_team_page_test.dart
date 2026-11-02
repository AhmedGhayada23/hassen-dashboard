import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/constants/app_layout.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/features/dashboard_team/domain/usecases/add_employee.dart';
import 'package:hassen_dashboard/features/dashboard_team/domain/usecases/get_employee_roles.dart';
import 'package:hassen_dashboard/features/dashboard_team/domain/usecases/get_team_members.dart';
import 'package:hassen_dashboard/features/dashboard_team/presentation/cubits/dashboard_team_cubit.dart';
import 'package:hassen_dashboard/features/dashboard_team/presentation/pages/dashboard_team_page.dart';
import 'package:hassen_dashboard/features/dashboard_team/presentation/widgets/add_employee_dialog.dart';
import 'package:hassen_dashboard/features/dashboard_team/presentation/widgets/team_empty_state.dart';
import 'package:hassen_dashboard/features/dashboard_team/presentation/widgets/team_member_card.dart';
import 'package:hassen_dashboard/features/dashboard_team/presentation/widgets/team_member_password.dart';
import 'package:hassen_dashboard/features/dashboard_team/presentation/widgets/team_page_header.dart';
import 'package:hassen_dashboard/features/dashboard_team/presentation/widgets/team_skeleton.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/domain/entities/nav_destination.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/presentation/cubits/dashboard_navigation_cubit.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/presentation/widgets/sidebar/dashboard_sidebar.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:toastification/toastification.dart';

import '../../../../helpers/test_view.dart';
import '../../helpers/fake_team_repository.dart';

void main() {
  late FakeTeamRepository repository;
  late DashboardTeamCubit teamCubit;
  late DashboardNavigationCubit navigationCubit;

  setUp(() {
    repository = FakeTeamRepository();
    teamCubit = DashboardTeamCubit(
      GetTeamMembers(repository),
      GetEmployeeRoles(repository),
      AddEmployee(repository),
    );
    navigationCubit = DashboardNavigationCubit();
  });
  tearDown(() {
    teamCubit.close();
    navigationCubit.close();
  });

  Future<void> pumpPage(WidgetTester tester, {bool load = true}) async {
    useDesktopView(tester);
    ignoreTestFontOverflow();
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: navigationCubit),
          BlocProvider.value(value: teamCubit),
        ],
        child: ScreenUtilInit(
          designSize: AppLayout.designSize,
          builder: (_, _) => const ToastificationWrapper(
            child: MaterialApp(
              home: Directionality(
                textDirection: TextDirection.rtl,
                child: DashboardTeamPage(),
              ),
            ),
          ),
        ),
      ),
    );
    if (load) {
      await teamCubit.load();
      await tester.pumpAndSettle();
    }
  }

  testWidgets('shows a skeleton, then six cards in four columns at 1440px', (
    tester,
  ) async {
    repository.gate = Completer<void>();
    await pumpPage(tester, load: false);
    unawaited(teamCubit.load());
    await tester.pump();
    expect(find.byType(TeamSkeleton), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is Skeletonizer), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    repository.gate!.complete();
    await tester.pumpAndSettle();
    expect(find.byType(TeamSkeleton), findsNothing);
    expect(find.byType(TeamMemberCard), findsNWidgets(6));
    final top = tester.getTopLeft(find.byType(TeamMemberCard).first).dy;
    expect(
      find
          .byType(TeamMemberCard)
          .evaluate()
          .where((e) => tester.getTopLeft(find.byWidget(e.widget)).dy == top),
      hasLength(4),
    );
  });

  testWidgets('RTL shell with the team item active', (tester) async {
    await pumpPage(tester);

    expect(tester.getTopRight(find.byType(DashboardSidebar)).dx, 1440);
    expect(navigationCubit.state, NavDestination.team);
    expect(find.text('الفريق'), findsWidgets);
  });

  testWidgets('shows an error with retry when loading fails', (tester) async {
    repository.failure = const CacheFailure();
    await pumpPage(tester);
    expect(find.text('تعذّر تحميل بيانات لوحة التحكم'), findsOneWidget);

    repository.failure = null;
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pumpAndSettle();

    expect(find.byType(TeamMemberCard), findsNWidgets(6));
  });

  testWidgets('an empty users collection shows the empty state', (
    tester,
  ) async {
    repository.members = [];
    await pumpPage(tester);

    expect(find.byType(TeamEmptyState), findsOneWidget);
    expect(find.text('لا يوجد موظفون بعد'), findsOneWidget);
    expect(find.text('0 موظفين'), findsOneWidget);
    expect(find.byType(TeamMemberCard), findsNothing);
  });

  testWidgets('a refused read of users explains how to fix it', (tester) async {
    repository.failure = const ForbiddenFailure();
    await pumpPage(tester);

    expect(find.text('تعذّر تحميل بيانات لوحة التحكم'), findsOneWidget);
    expect(
      find.textContaining('لا توجد صلاحية لقراءة جدول users'),
      findsOneWidget,
    );
  });

  testWidgets('the head count and "add employee" sit above the cards', (
    tester,
  ) async {
    await pumpPage(tester);

    expect(find.text('6 موظفين'), findsOneWidget);
    expect(
      tester.getTopLeft(find.byType(TeamPageHeader)).dy,
      lessThan(tester.getTopLeft(find.byType(TeamMemberCard).first).dy),
    );
  });

  testWidgets(
    'adding an employee appends a pending card and confirms the invitation',
    (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text('+ إضافة موظف'));
      await tester.pumpAndSettle();
      expect(find.byType(AddEmployeeDialog), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).at(0), 'سامي');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'sami@haseen.ps',
      );
      await tester.tap(find.text('إضافة وإنشاء الحساب'));
      await tester.pumpAndSettle();

      expect(find.byType(AddEmployeeDialog), findsNothing);
      expect(find.byType(TeamMemberCard), findsNWidgets(7));
      expect(find.text('7 موظفين'), findsOneWidget);
      final card = find.widgetWithText(TeamMemberCard, 'م. سامي');
      expect(
        find.descendant(of: card, matching: find.text('بانتظار التفعيل')),
        findsOneWidget,
      );
      // Confirmed by a success toast, not a SnackBar.
      expect(
        find.text('أُضيف م. سامي — كلمة المرور المؤقتة في بطاقته لتسليمها له.'),
        findsOneWidget,
      );
      expect(find.byType(SnackBar), findsNothing);
      // Let the toast run out so no timer outlives the test.
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();
      expect(
        find.text('أُضيف م. سامي — كلمة المرور المؤقتة في بطاقته لتسليمها له.'),
        findsNothing,
      );
    },
  );

  testWidgets('with no roles in Firestore, adding explains why instead', (
    tester,
  ) async {
    repository.roles = [];
    await pumpPage(tester);

    await tester.tap(find.text('+ إضافة موظف'));
    await tester.pumpAndSettle();

    expect(find.byType(AddEmployeeDialog), findsNothing);
    expect(find.textContaining('لا توجد أدوار في جدول roles'), findsOneWidget);
    // Let the toast run out so no timer outlives the test.
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
  });

  testWidgets('cancelling adds nobody', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('+ إضافة موظف'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('إلغاء'));
    await tester.pumpAndSettle();

    expect(repository.added, isEmpty);
    expect(find.byType(TeamMemberCard), findsNWidgets(6));
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('a failed invitation is reported and the roster is unchanged', (
    tester,
  ) async {
    repository.addFailure = const CacheFailure();
    await pumpPage(tester);

    await tester.tap(find.text('+ إضافة موظف'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'سامي');
    await tester.enterText(find.byType(TextFormField).at(1), 'sami@haseen.ps');
    await tester.tap(find.text('إضافة وإنشاء الحساب'));
    await tester.pumpAndSettle();

    expect(find.text('تعذّرت إضافة الموظف. حاول مرة أخرى.'), findsOneWidget);
    expect(find.byType(TeamMemberCard), findsNWidgets(6));
    // Let the error toast run out so no timer outlives the test.
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
  });

  testWidgets(
    'the new card masks its temporary password until revealed, and copies it',
    (tester) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await pumpPage(tester);
      await tester.tap(find.text('+ إضافة موظف'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'سامي');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'sami@haseen.ps',
      );
      await tester.tap(find.text('إضافة وإنشاء الحساب'));
      await tester.pumpAndSettle();

      final password = repository.passwords.single;
      final card = find.widgetWithText(TeamMemberCard, 'م. سامي');
      Finder inCard(Finder matching) =>
          find.descendant(of: card, matching: matching);
      // Only accounts created here carry a password row.
      expect(find.byType(TeamMemberPassword), findsOneWidget);
      expect(inCard(find.text(TeamMemberPassword.mask)), findsOneWidget);
      expect(find.text(password), findsNothing);

      await tester.tap(inCard(find.byTooltip('عرض كلمة المرور')));
      await tester.pumpAndSettle();
      expect(inCard(find.text(password)), findsOneWidget);

      await tester.tap(inCard(find.byTooltip('نسخ كلمة المرور')));
      await tester.pumpAndSettle();
      expect(copied, password);
      expect(find.text('تم نسخ كلمة المرور'), findsOneWidget);

      await tester.tap(inCard(find.byTooltip('إخفاء كلمة المرور')));
      await tester.pumpAndSettle();
      expect(find.text(password), findsNothing);
      // Let the toast run out so no timer outlives the test.
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();
    },
  );
}
