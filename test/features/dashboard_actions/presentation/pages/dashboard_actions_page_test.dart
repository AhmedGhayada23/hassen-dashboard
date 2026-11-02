import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/constants/app_layout.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/core/theme/app_colors.dart';
import 'package:hassen_dashboard/features/dashboard_actions/domain/entities/action_due_status.dart';
import 'package:hassen_dashboard/features/dashboard_actions/domain/entities/action_status.dart';
import 'package:hassen_dashboard/features/dashboard_actions/domain/usecases/get_corrective_actions.dart';
import 'package:hassen_dashboard/features/dashboard_actions/domain/usecases/update_action_status.dart';
import 'package:hassen_dashboard/features/dashboard_actions/presentation/cubits/dashboard_actions_cubit.dart';
import 'package:hassen_dashboard/features/dashboard_actions/presentation/pages/dashboard_actions_page.dart';
import 'package:hassen_dashboard/features/dashboard_actions/presentation/widgets/actions_kanban_board.dart';
import 'package:hassen_dashboard/features/dashboard_actions/presentation/widgets/actions_skeleton.dart';
import 'package:hassen_dashboard/features/dashboard_actions/presentation/widgets/corrective_action_card.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/domain/entities/nav_destination.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/presentation/cubits/dashboard_navigation_cubit.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/presentation/widgets/sidebar/dashboard_sidebar.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/presentation/widgets/sidebar/sidebar_nav_item.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:toastification/toastification.dart';

import '../../../../helpers/test_view.dart';
import '../../helpers/fake_corrective_actions_repository.dart';

void main() {
  late FakeCorrectiveActionsRepository repository;
  late DashboardActionsCubit actionsCubit;
  late DashboardNavigationCubit navigationCubit;

  setUp(() {
    repository = FakeCorrectiveActionsRepository();
    actionsCubit = DashboardActionsCubit(
      getActions: GetCorrectiveActions(repository),
      updateStatus: UpdateActionStatus(repository),
    );
    navigationCubit = DashboardNavigationCubit();
  });
  tearDown(() {
    actionsCubit.close();
    navigationCubit.close();
  });

  Future<void> pumpPage(WidgetTester tester, {bool load = true}) async {
    useDesktopView(tester);
    ignoreTestFontOverflow();
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: navigationCubit),
          BlocProvider.value(value: actionsCubit),
        ],
        child: ScreenUtilInit(
          designSize: AppLayout.designSize,
          builder: (_, _) => const ToastificationWrapper(
            child: MaterialApp(
              home: Directionality(
                textDirection: TextDirection.rtl,
                child: DashboardActionsPage(),
              ),
            ),
          ),
        ),
      ),
    );
    if (load) {
      await actionsCubit.load();
      await tester.pumpAndSettle();
    }
  }

  /// The corrective-actions sidebar counter: (text, background) or null when hidden.
  (String?, Color?)? sidebarBadge(WidgetTester tester) {
    final badge = find.descendant(
      of: find.widgetWithText(SidebarNavItem, 'الإجراءات التصحيحية'),
      matching: find.byType(SidebarNavBadge),
    );
    if (badge.evaluate().isEmpty) return null;
    final box = tester.widget<Container>(
      find.descendant(of: badge, matching: find.byType(Container)).first,
    );
    return (
      tester
          .widget<Text>(find.descendant(of: badge, matching: find.byType(Text)))
          .data,
      (box.decoration! as BoxDecoration).color,
    );
  }

  testWidgets('shows a skeleton, then the board with all nine cards', (
    tester,
  ) async {
    repository.gate = Completer<void>();
    await pumpPage(tester, load: false);
    unawaited(actionsCubit.load());
    await tester.pump();
    expect(find.byType(ActionsSkeleton), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is Skeletonizer), findsOneWidget);

    repository.gate!.complete();
    await tester.pumpAndSettle();
    expect(find.byType(ActionsSkeleton), findsNothing);
    expect(find.byType(ActionsKanbanBoard), findsOneWidget);
    expect(find.byType(CorrectiveActionCard), findsNWidgets(9));
  });

  testWidgets(
    'RTL shell with the page active and a red counter computed from the data',
    (tester) async {
      await pumpPage(tester);

      expect(tester.getTopRight(find.byType(DashboardSidebar)).dx, 1440);
      expect(navigationCubit.state, NavDestination.correctiveActions);
      expect(sidebarBadge(tester), ('3', HaseenColors.redStrong));
    },
  );

  testWidgets('the counter follows the data, not a constant', (tester) async {
    repository.actions = [
      for (final a in repository.actions)
        if (a.dueStatus != ActionDueStatus.soon) a,
    ];
    await pumpPage(tester);

    expect(sidebarBadge(tester), ('2', HaseenColors.redStrong));
  });

  testWidgets('tapping a card opens its details', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('تدريب فريق المناولة'));
    await tester.pumpAndSettle();

    final dialog = find.byType(AlertDialog);
    expect(
      find.descendant(of: dialog, matching: find.text('CA-0371')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: dialog, matching: find.text('مغلقة')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: dialog, matching: find.text('منخفض')),
      findsOneWidget,
    );
  });

  testWidgets('a status change regroups the board', (tester) async {
    await pumpPage(tester);

    await actionsCubit.moveAction('CA-0428', ActionStatus.closed);
    await tester.pumpAndSettle();

    final closedColumn = find
        .ancestor(of: find.text('مغلقة'), matching: find.byType(Container))
        .first;
    expect(
      find.descendant(of: closedColumn, matching: find.text('CA-0428')),
      findsOneWidget,
    );
    expect(find.text('3'), findsWidgets);
  });

  testWidgets('a failed status change shows a message and keeps the board', (
    tester,
  ) async {
    await pumpPage(tester);
    repository.updateFailure = const CacheFailure();

    await actionsCubit.moveAction('CA-0428', ActionStatus.closed);
    // The listener reacts to the async state event, so the toast lands a frame later.
    await tester.pumpAndSettle();

    expect(find.text('تعذّر تحديث حالة الإجراء'), findsOneWidget);
    expect(find.byType(CorrectiveActionCard), findsNWidgets(9));
    // Let the toast run out so no timer outlives the test.
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
  });

  testWidgets('a missing write permission is explained', (tester) async {
    await pumpPage(tester);
    repository.updateFailure = const ForbiddenFailure();

    await actionsCubit.moveAction('CA-0428', ActionStatus.closed);
    await tester.pumpAndSettle();

    expect(
      find.text(
        'لا توجد صلاحية لتعديل الإجراء في جدول corrective_actions. راجع قواعد Firestore.',
      ),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
  });

  testWidgets('a missing read permission is explained', (tester) async {
    repository.loadFailure = const ForbiddenFailure();
    await pumpPage(tester);

    expect(
      find.text(
        'لا توجد صلاحية لقراءة جدول corrective_actions. راجع قواعد Firestore.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows an error with retry when loading fails', (tester) async {
    repository.loadFailure = const CacheFailure();
    await pumpPage(tester);
    expect(find.text('تعذّر تحميل بيانات لوحة التحكم'), findsOneWidget);

    repository.loadFailure = null;
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pumpAndSettle();

    expect(find.byType(CorrectiveActionCard), findsNWidgets(9));
  });
}
