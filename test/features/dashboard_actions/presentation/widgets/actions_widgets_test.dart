import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/theme/app_colors.dart';
import 'package:hassen_dashboard/core/widgets/status_badge.dart';
import 'package:hassen_dashboard/features/dashboard_actions/domain/entities/action_status.dart';
import 'package:hassen_dashboard/features/dashboard_actions/domain/entities/corrective_action.dart';
import 'package:hassen_dashboard/features/dashboard_actions/presentation/widgets/actions_kanban_board.dart';
import 'package:hassen_dashboard/features/dashboard_actions/presentation/widgets/actions_kanban_column.dart';
import 'package:hassen_dashboard/features/dashboard_actions/presentation/widgets/corrective_action_card.dart';
import 'package:hassen_dashboard/features/dashboard_actions/presentation/widgets/corrective_action_details_dialog.dart';

import '../../../../helpers/test_view.dart';
import '../../fixtures/actions_fixture.dart';

Map<ActionStatus, List<CorrectiveAction>> _columns(
  List<CorrectiveAction> actions,
) => {
  for (final s in ActionStatus.values)
    s: actions.where((a) => a.status == s).toList(),
};

void main() {
  CorrectiveAction byId(String id) =>
      expectedActions.firstWhere((a) => a.id == id);

  group('board', () {
    testWidgets(
      'renders four columns in RTL order with titles, dots and counts',
      (tester) async {
        await pumpDashboardWidget(
          tester,
          ActionsKanbanBoard(
            columns: _columns(expectedActions),
            onActionTap: (_) {},
          ),
        );

        final titles = [
          'مفتوحة لدى المنشأة',
          'قيد التنفيذ',
          'مطلوب إغلاقها',
          'مغلقة',
        ];
        for (var i = 1; i < titles.length; i++) {
          expect(
            tester.getCenter(find.text(titles[i])).dx,
            lessThan(tester.getCenter(find.text(titles[i - 1])).dx),
          );
        }
        final columns = tester
            .widgetList<ActionsKanbanColumn>(find.byType(ActionsKanbanColumn))
            .toList();
        expect([for (final c in columns) c.actions.length], [2, 3, 2, 2]);
        expect([
          for (final c in columns) c.actions.map((a) => a.id).toList(),
        ], expectedColumnIds);
        final dots = tester
            .widgetList<Container>(
              find.byWidgetPredicate(
                (w) =>
                    w is Container &&
                    w.decoration is BoxDecoration &&
                    (w.decoration! as BoxDecoration).shape == BoxShape.circle,
              ),
            )
            .map((c) => (c.decoration! as BoxDecoration).color);
        expect(dots, [
          HaseenColors.neutralBar,
          HaseenColors.gold,
          HaseenColors.teal,
          HaseenColors.green,
        ]);
      },
    );

    testWidgets('column width follows ((w - 36) / 4).clamp(220, 400)', (
      tester,
    ) async {
      Future<double> columnWidth(double available) async {
        await pumpDashboardWidget(
          tester,
          Align(
            alignment: Alignment.topRight,
            child: SizedBox(
              width: available,
              child: ActionsKanbanBoard(
                columns: _columns(expectedActions),
                onActionTap: (_) {},
              ),
            ),
          ),
        );
        return tester.getSize(find.byType(ActionsKanbanColumn).first).width;
      }

      expect(
        await columnWidth(1144),
        (1144 - 36) / 4,
      ); // 1440 window content width
      expect(await columnWidth(700), 220); // clamped low → scrolls horizontally
      expect(await columnWidth(1400), 341);
    });

    testWidgets('scrolls horizontally when four columns do not fit', (
      tester,
    ) async {
      await pumpDashboardWidget(
        tester,
        SizedBox(
          width: 700,
          child: ActionsKanbanBoard(
            columns: _columns(expectedActions),
            onActionTap: (_) {},
          ),
        ),
      );

      final scrollable = tester.state<ScrollableState>(
        find.byType(Scrollable).first,
      );
      expect(scrollable.position.maxScrollExtent, 4 * 220 + 36 - 700);
    });

    testWidgets('an empty board still shows four empty columns', (
      tester,
    ) async {
      await pumpDashboardWidget(
        tester,
        ActionsKanbanBoard(columns: _columns(const []), onActionTap: (_) {}),
      );

      expect(find.byType(ActionsKanbanColumn), findsNWidgets(4));
      expect(find.byType(CorrectiveActionCard), findsNothing);
      expect(find.text('0'), findsNWidgets(4));
      expect(tester.takeException(), isNull);
    });
  });

  group('card', () {
    testWidgets('shows id, severity, title, facility, owner and due pill', (
      tester,
    ) async {
      final action = byId('CA-0412');
      await pumpDashboardWidget(
        tester,
        SizedBox(
          width: 277,
          child: CorrectiveActionCard(action: action, onTap: () {}),
        ),
      );

      for (final text in [
        'CA-0412',
        'عالٍ',
        action.title,
        action.facility,
        action.owner,
        'متأخر 6 أيام',
      ]) {
        expect(find.text(text), findsOneWidget);
      }
      expect(
        tester.widget<Text>(find.text('عالٍ')).style!.color,
        HaseenColors.highText,
      );
      final pill = tester.widget<StatusBadge>(find.byType(StatusBadge));
      expect(
        (pill.background, pill.foreground),
        (HaseenColors.dangerSoft, HaseenColors.red),
      );
    });

    testWidgets('late cards get the red outline, others the normal line', (
      tester,
    ) async {
      Color outlineOf(CorrectiveAction a) {
        final material = tester.widget<Material>(
          find
              .descendant(
                of: find.byType(CorrectiveActionCard),
                matching: find.byType(Material),
              )
              .first,
        );
        return (material.shape! as RoundedRectangleBorder).side.color;
      }

      await pumpDashboardWidget(
        tester,
        CorrectiveActionCard(action: byId('CA-0431'), onTap: () {}),
      );
      expect(outlineOf(byId('CA-0431')), HaseenColors.dangerBorder);

      await pumpDashboardWidget(
        tester,
        CorrectiveActionCard(action: byId('CA-0405'), onTap: () {}),
      );
      expect(outlineOf(byId('CA-0405')), HaseenColors.line);
    });

    testWidgets('due pill colors match each due status', (tester) async {
      final expected = {
        'CA-0431': (HaseenColors.dangerSoft, HaseenColors.red),
        'CA-0405': (HaseenColors.warningSoft, HaseenColors.warningTextDark),
        'CA-0428': (HaseenColors.soft, HaseenColors.neutralText),
        'CA-0377': (HaseenColors.successSoft, HaseenColors.successText),
      };
      for (final MapEntry(key: id, value: colors) in expected.entries) {
        await pumpDashboardWidget(
          tester,
          CorrectiveActionCard(action: byId(id), onTap: () {}),
        );
        final pill = tester.widget<StatusBadge>(find.byType(StatusBadge));
        expect((pill.background, pill.foreground), colors, reason: id);
      }
    });
  });

  testWidgets('details dialog shows the tapped action and closes', (
    tester,
  ) async {
    await pumpDashboardWidget(
      tester,
      Builder(
        builder: (context) => ActionsKanbanBoard(
          columns: _columns(expectedActions),
          onActionTap: (a) => showCorrectiveActionDetailsDialog(context, a),
        ),
      ),
    );

    await tester.tap(find.text('استبدال طفايات منتهية'));
    await tester.pumpAndSettle();

    final dialog = find.byType(AlertDialog);
    expect(dialog, findsOneWidget);
    for (final (label, value) in [
      ('الرقم', 'CA-0390'),
      ('المنشأة', 'بنك فلسطين'),
      ('الخطورة', 'عالٍ'),
      ('المسؤول', 'مدير المرافق'),
      ('الحالة', 'مطلوب إغلاقها'),
    ]) {
      expect(
        find.descendant(of: dialog, matching: find.text(label)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: dialog, matching: find.text(value)),
        findsOneWidget,
        reason: label,
      );
    }
    expect(
      find.descendant(of: dialog, matching: find.text('الدليل مرفوع')),
      findsOneWidget,
    );

    await tester.tap(find.text('إغلاق'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });
}
