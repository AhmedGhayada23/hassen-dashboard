import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/theme/app_colors.dart';
import 'package:hassen_dashboard/features/dashboard_clients/domain/entities/client_stage.dart';
import 'package:hassen_dashboard/features/dashboard_clients/domain/entities/new_client.dart';
import 'package:hassen_dashboard/features/dashboard_clients/presentation/widgets/add_client_dialog.dart';
import 'package:hassen_dashboard/features/dashboard_clients/presentation/widgets/add_client_stage_card.dart';

import '../../../../helpers/test_view.dart';
import '../../fixtures/clients_fixture.dart';

void main() {
  late NewClient? result;
  late bool closed;

  Future<void> openDialog(WidgetTester tester) async {
    result = null;
    closed = false;
    await pumpDashboardWidget(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            result = await showAddClientDialog(
              context,
              options: expectedRegistrationOptions,
              existingNames: {for (final c in expectedClients) c.name},
            );
            closed = true;
          },
          child: const Text('open'),
        ),
      ),
      size: const Size(1440, 1400),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Finder field(int index) => find.byType(TextFormField).at(index);
  // Text fields, in order: name, branches, city, address, contact name,
  // contact title, email, phone, notes.
  const name = 0,
      branches = 1,
      contactName = 4,
      email = 6,
      phone = 7,
      notes = 8;

  Future<void> submit(WidgetTester tester) async {
    await tester.tap(find.text('إضافة عميل'));
    await tester.pumpAndSettle();
  }

  Future<void> choose(
    WidgetTester tester,
    String current,
    String option,
  ) async {
    final dropdown = find
        .ancestor(
          of: find.text(current),
          matching: find.byType(DropdownButtonFormField<String>),
        )
        .first;
    await tester.ensureVisible(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text(option).last);
    await tester.pumpAndSettle();
  }

  testWidgets('opens with the original sections, texts and defaults', (
    tester,
  ) async {
    await openDialog(tester);

    for (final text in [
      'عميل جديد',
      '1 · بيانات المنشأة',
      'اسم المنشأة',
      'القطاع',
      'اختر القطاع',
      'عدد الفروع',
      'غزة',
      '2 · جهة التواصل لدى المنشأة',
      'مسؤول السلامة',
      '3 · المرحلة',
      'تواصل أولي فقط',
      'زيارة معاينة مخططة',
      'جاري إعداد عرض السعر',
      'يصبح العميل «متعاقداً» بعد توقيع العقد من صفحة العروض والعقود.',
      '4 · الإسناد',
      'اختيار المقترح',
      'بدون إسناد الآن',
      'جدولة فحص أولي بعد الإضافة',
      'يُسجَّل العميل بحالة «فحص أولي مطلوب»',
      'إضافة عميل',
      'إلغاء',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    expect(tester.widget<TextFormField>(field(branches)).controller?.text, '1');
    final cards = tester.widgetList<AddClientStageCard>(
      find.byType(AddClientStageCard),
    );
    expect(
      [for (final c in cards) (c.stage, c.selected)],
      [
        (ClientStage.potential, true),
        (ClientStage.inspection, false),
        (ClientStage.quotation, false),
      ],
    );
    expect(
      tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
      isTrue,
    );
    // Email and phone are typed left-to-right.
    final editables = tester
        .widgetList<EditableText>(find.byType(EditableText))
        .toList();
    expect(
      (editables[email].textDirection, editables[phone].textDirection),
      (TextDirection.ltr, TextDirection.ltr),
    );
  });

  testWidgets('an empty form shows every required message and stays open', (
    tester,
  ) async {
    await openDialog(tester);
    await tester.enterText(field(branches), '0');

    await submit(tester);

    for (final message in [
      'أدخل اسم المنشأة',
      'أدخل عدداً صحيحاً',
      'أدخل اسم جهة التواصل',
      'أدخل البريد أو رقم الهاتف',
    ]) {
      expect(find.text(message), findsOneWidget, reason: message);
    }
    // As in the original, the sector error repeats the hint's own words.
    expect(find.text('اختر القطاع'), findsNWidgets(2));
    expect(closed, isFalse);
  });

  testWidgets('a registered name, a bad email and a bad phone are refused', (
    tester,
  ) async {
    await openDialog(tester);
    await tester.enterText(field(name), 'بلدية غزة');
    await tester.enterText(field(email), 'a@b');
    await tester.enterText(field(phone), '12-34');

    await submit(tester);

    expect(find.text('هذه المنشأة مسجلة مسبقاً'), findsOneWidget);
    expect(find.text('صيغة البريد غير صحيحة'), findsOneWidget);
    expect(find.text('رقم الهاتف غير صحيح'), findsOneWidget);
    expect(closed, isFalse);
  });

  testWidgets(
    'the suggested inspector is marked and "اختيار المقترح" picks it',
    (tester) async {
      await openDialog(tester);

      await tester.tap(find.text('اختيار المقترح'));
      await tester.pumpAndSettle();

      expect(
        find.text('م. ليلى — 2 زيارات هذا الأسبوع (مقترح)'),
        findsOneWidget,
      );
      expect(find.text('بدون إسناد الآن'), findsNothing);
    },
  );

  testWidgets('a filled form closes with the new client and every choice', (
    tester,
  ) async {
    await openDialog(tester);
    await tester.enterText(field(name), ' مدرسة النور ');
    await choose(tester, 'اختر القطاع', 'مؤسسة تعليمية');
    await tester.enterText(field(branches), '2');
    await tester.enterText(field(2), 'خان يونس');
    await tester.enterText(field(contactName), 'أ. محمود');
    await tester.enterText(field(5), 'مدير المدرسة');
    await tester.enterText(field(phone), '0599 123456');
    await tester.enterText(field(notes), 'مبنى من ثلاثة طوابق');
    final inspectionCard = find.widgetWithText(AddClientStageCard, 'معاينة');
    await tester.ensureVisible(inspectionCard);
    await tester.pumpAndSettle();
    await tester.tap(inspectionCard);
    await tester.pumpAndSettle();
    expect(tester.widget<AddClientStageCard>(inspectionCard).selected, isTrue);
    expect(
      tester
          .widget<Material>(
            find
                .descendant(of: inspectionCard, matching: find.byType(Material))
                .first,
          )
          .color,
      HaseenColors.navy,
    );
    await tester.ensureVisible(find.text('اختيار المقترح'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('اختيار المقترح'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();

    await submit(tester);

    expect(closed, isTrue);
    expect(
      result,
      const NewClient(
        name: 'مدرسة النور',
        sector: 'مؤسسة تعليمية',
        branches: 2,
        city: 'خان يونس',
        contactName: 'أ. محمود',
        contactTitle: 'مدير المدرسة',
        phone: '0599 123456',
        stage: ClientStage.inspection,
        inspector: 'م. ليلى',
        note: 'مبنى من ثلاثة طوابق',
        schedulePreInspection: false,
      ),
    );
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
}
