import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/theme/app_colors.dart';
import 'package:hassen_dashboard/features/dashboard_team/domain/entities/new_employee.dart';
import 'package:hassen_dashboard/features/dashboard_team/domain/entities/team_member.dart';
import 'package:hassen_dashboard/features/dashboard_team/presentation/widgets/add_employee_dialog.dart';
import 'package:hassen_dashboard/features/dashboard_team/presentation/widgets/employee_role_card.dart';
import 'package:hassen_dashboard/features/dashboard_team/presentation/widgets/team_member_card.dart';

import '../../../../helpers/test_view.dart';
import '../../fixtures/team_fixture.dart';

void main() {
  late NewEmployee? result;
  late bool closed;

  Future<void> openDialog(WidgetTester tester) async {
    result = null;
    closed = false;
    await pumpDashboardWidget(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            result = await showAddEmployeeDialog(context, roles: expectedRoles);
            closed = true;
          },
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Finder field(int index) => find.byType(TextFormField).at(index);
  Finder roleCard(String name) => find.widgetWithText(EmployeeRoleCard, name);
  Future<void> submit(WidgetTester tester) async {
    await tester.tap(find.text('إضافة وإنشاء الحساب'));
    await tester.pumpAndSettle();
  }

  testWidgets('opens with the original texts and the first role selected', (
    tester,
  ) async {
    await openDialog(tester);

    for (final text in [
      'إضافة موظف',
      'الاسم الكامل',
      'البريد الإلكتروني للعمل',
      'name@haseen.ps',
      'رقم الهاتف',
      'اختياري',
      'الدور',
      'إضافة وإنشاء الحساب',
      'إلغاء',
      'تظهر كلمة مرور مؤقتة في بطاقة الموظف لتسليمها له',
      for (final r in expectedRoles) ...[r.name, r.description],
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    final cards = tester.widgetList<EmployeeRoleCard>(
      find.byType(EmployeeRoleCard),
    );
    expect(
      [for (final c in cards) c.selected],
      [true, false, false, false, false],
    );
    expect(
      tester
          .widget<Material>(
            find
                .descendant(
                  of: roleCard('مفتش سلامة'),
                  matching: find.byType(Material),
                )
                .first,
          )
          .color,
      HaseenColors.navy,
    );
    // Email and phone are typed left-to-right.
    final fields = tester
        .widgetList<EditableText>(find.byType(EditableText))
        .toList();
    expect(
      [for (final f in fields) f.textDirection],
      [null, TextDirection.ltr, TextDirection.ltr],
    );
  });

  testWidgets('empty name and email are refused with the original messages', (
    tester,
  ) async {
    await openDialog(tester);

    await submit(tester);

    expect(find.text('أدخل الاسم الكامل'), findsOneWidget);
    expect(find.text('أدخل البريد الإلكتروني'), findsOneWidget);
    expect(find.text('رقم الهاتف غير صحيح'), findsNothing);
    expect(closed, isFalse);
  });

  testWidgets('a malformed email or phone is refused', (tester) async {
    await openDialog(tester);
    await tester.enterText(field(0), 'سامي');
    await tester.enterText(field(1), 'sami@haseen');
    await tester.enterText(field(2), '12-34');

    await submit(tester);

    expect(find.text('صيغة البريد غير صحيحة'), findsOneWidget);
    expect(find.text('رقم الهاتف غير صحيح'), findsOneWidget);
    expect(closed, isFalse);
  });

  testWidgets('a valid form closes with the employee and the chosen role', (
    tester,
  ) async {
    await openDialog(tester);
    await tester.enterText(field(0), '  رنا  ');
    await tester.enterText(field(1), ' rana@haseen.ps ');
    await tester.enterText(field(2), '+970 599 123456');
    await tester.tap(roleCard('مدير العمليات'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<EmployeeRoleCard>(roleCard('مدير العمليات')).selected,
      isTrue,
    );

    await submit(tester);

    expect(closed, isTrue);
    expect(
      result,
      NewEmployee(
        fullName: 'رنا',
        email: 'rana@haseen.ps',
        phone: '+970 599 123456',
        role: expectedRoles[3],
      ),
    );
    expect(result!.displayName, 'رنا');
  });

  testWidgets('cancel and the close button add nobody', (tester) async {
    await openDialog(tester);
    await tester.tap(find.text('إلغاء'));
    await tester.pumpAndSettle();
    expect((closed, result), (true, null));

    await openDialog(tester);
    await tester.tap(find.byTooltip('إغلاق'));
    await tester.pumpAndSettle();
    expect((closed, result), (true, null));
  });

  testWidgets('a member awaiting activation is tagged on their card', (
    tester,
  ) async {
    const invited = TeamMember(
      id: 'TM-007',
      name: 'م. سامي',
      role: 'مفتش سلامة',
      facilities: 0,
      monthlyVisits: 0,
      lateVisits: 0,
      workload: 0,
      isPendingActivation: true,
    );
    await pumpDashboardWidget(
      tester,
      Column(
        children: [
          SizedBox(
            width: 300,
            child: TeamMemberCard(member: expectedTeam.first),
          ),
          const SizedBox(width: 300, child: TeamMemberCard(member: invited)),
        ],
      ),
    );

    final badge = find.text('بانتظار التفعيل');
    expect(badge, findsOneWidget);
    expect(
      find.descendant(
        of: find.widgetWithText(TeamMemberCard, 'م. سامي'),
        matching: badge,
      ),
      findsOneWidget,
    );
    expect(find.text('0%'), findsOneWidget);
  });
}
