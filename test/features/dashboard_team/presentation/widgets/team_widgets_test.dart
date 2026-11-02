import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/theme/app_colors.dart';
import 'package:hassen_dashboard/features/dashboard_team/domain/entities/team_member.dart';
import 'package:hassen_dashboard/features/dashboard_team/presentation/config/team_layout_config.dart';
import 'package:hassen_dashboard/features/dashboard_team/presentation/widgets/team_grid.dart';
import 'package:hassen_dashboard/features/dashboard_team/presentation/widgets/team_member_avatar.dart';
import 'package:hassen_dashboard/features/dashboard_team/presentation/widgets/team_member_card.dart';
import 'package:hassen_dashboard/features/dashboard_team/presentation/widgets/team_member_stat_item.dart';

import '../../../../helpers/test_view.dart';
import '../../fixtures/team_fixture.dart';

void main() {
  Finder inCard(String name, Finder matching) => find.descendant(
    of: find.widgetWithText(TeamMemberCard, name),
    matching: matching,
  );

  test(
    '8. columns follow floor(width / 274) clamped to 1–4, as in the original',
    () {
      expect(
        [
          for (final w in [250.0, 548.0, 822.0, 1144.0, 3000.0])
            TeamLayoutConfig.columns(w),
        ],
        [1, 2, 3, 4, 4],
      );
    },
  );

  testWidgets('1–2. shows six cards with names and roles, in order', (
    tester,
  ) async {
    await pumpDashboardWidget(
      tester,
      SizedBox(width: 1144, child: TeamGrid(members: expectedTeam)),
    );

    final cards = tester
        .widgetList<TeamMemberCard>(find.byType(TeamMemberCard))
        .toList();
    expect(cards.map((c) => c.member.id), [for (final m in expectedTeam) m.id]);
    for (final m in expectedTeam) {
      expect(inCard(m.name, find.text(m.role)), findsOneWidget);
    }
  });

  testWidgets(
    '3. stats show facilities, monthly visits and late visits; late > 0 is red',
    (tester) async {
      await pumpDashboardWidget(
        tester,
        SizedBox(width: 1144, child: TeamGrid(members: expectedTeam)),
      );

      List<(String, String)> statsOf(String name) => [
        for (final s in tester.widgetList<TeamMemberStatItem>(
          inCard(name, find.byType(TeamMemberStatItem)),
        ))
          (s.value, s.label),
      ];
      expect(statsOf('م. أحمد'), [
        ('2', 'منشآت'),
        ('18', 'زيارات الشهر'),
        ('1', 'متأخرة'),
      ]);
      expect(statsOf('موظف العملاء والعقود'), [
        ('8', 'منشآت'),
        ('0', 'زيارات الشهر'),
        ('0', 'متأخرة'),
      ]);

      Color lateColor(String name) => tester
          .widgetList<TeamMemberStatItem>(
            inCard(name, find.byType(TeamMemberStatItem)),
          )
          .last
          .valueColor;
      expect(lateColor('م. خالد'), HaseenColors.red);
      expect(lateColor('م. سارة'), HaseenColors.navy);
    },
  );

  testWidgets('4–5. workload percentages and avatar initials', (tester) async {
    await pumpDashboardWidget(
      tester,
      SizedBox(width: 1144, child: TeamGrid(members: expectedTeam)),
    );

    for (final (name, percent) in [
      ('م. أحمد', '85%'),
      ('م. ليلى', '45%'),
      ('مدير السلامة', '60%'),
    ]) {
      expect(inCard(name, find.text(percent)), findsOneWidget);
    }
    final initials = tester
        .widgetList<TeamMemberAvatar>(find.byType(TeamMemberAvatar))
        .map((a) => a.member.initial);
    expect(initials, ['أ', 'س', 'خ', 'ل', 'م', 'م']);
    expect(
      inCard(
        'م. سارة',
        find.descendant(
          of: find.byType(TeamMemberAvatar),
          matching: find.text('س'),
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('6–7. the bar is orange above 80% and teal at exactly 80%', (
    tester,
  ) async {
    Future<LinearProgressIndicator> barOf(TeamMember member) async {
      await pumpDashboardWidget(
        tester,
        SizedBox(width: 300, child: TeamMemberCard(member: member)),
      );
      return tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
    }

    final over = await barOf(expectedTeam.first);
    expect((over.value, over.color), (0.85, HaseenColors.highStrong));

    final atThreshold = await barOf(memberAtThreshold);
    expect((atThreshold.value, atThreshold.color), (0.80, HaseenColors.teal));
  });

  testWidgets('cards take the responsive column count with equal widths', (
    tester,
  ) async {
    Future<(int, double)> layoutAt(double width) async {
      await pumpDashboardWidget(
        tester,
        Align(
          alignment: Alignment.topRight,
          child: SizedBox(
            width: width,
            child: TeamGrid(members: expectedTeam),
          ),
        ),
      );
      final cards = find.byType(TeamMemberCard);
      final top = tester.getTopLeft(cards.first).dy;
      final perRow = cards
          .evaluate()
          .where((e) => tester.getTopLeft(find.byWidget(e.widget)).dy == top)
          .length;
      return (perRow, tester.getSize(cards.first).width);
    }

    expect(await layoutAt(1144), (4, (1144 - 14 * 3) / 4));
    expect(await layoutAt(822), (3, (822 - 14 * 2) / 3));
    expect(await layoutAt(300), (1, 300.0));
  });
}
