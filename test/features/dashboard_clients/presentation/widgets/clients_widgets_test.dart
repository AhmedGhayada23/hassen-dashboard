import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/theme/app_colors.dart';
import 'package:hassen_dashboard/core/widgets/status_badge.dart';
import 'package:hassen_dashboard/features/dashboard_clients/domain/entities/client.dart';
import 'package:hassen_dashboard/features/dashboard_clients/domain/entities/client_stage.dart';
import 'package:hassen_dashboard/features/dashboard_clients/domain/entities/clients_summary.dart';
import 'package:hassen_dashboard/features/dashboard_clients/presentation/widgets/client_details_panel.dart';
import 'package:hassen_dashboard/features/dashboard_clients/presentation/widgets/client_table_row.dart';
import 'package:hassen_dashboard/features/dashboard_clients/presentation/widgets/clients_filter_bar.dart';
import 'package:hassen_dashboard/features/dashboard_clients/presentation/widgets/clients_stage_chip.dart';
import 'package:hassen_dashboard/features/dashboard_clients/presentation/widgets/clients_table.dart';

import '../../../../helpers/test_view.dart';
import '../../fixtures/clients_fixture.dart';

void main() {
  double x(WidgetTester tester, String text) =>
      tester.getCenter(find.text(text).first).dx;

  testWidgets(
    '15. table shows the six columns in RTL order with the original weights',
    (tester) async {
      await pumpDashboardWidget(
        tester,
        SizedBox(
          width: 760,
          child: ClientsTable(
            clients: expectedClients,
            selectedClientId: 'CL-001',
            onClientTap: (_) {},
          ),
        ),
      );

      const headers = [
        'العميل',
        'القطاع',
        'الفروع',
        'المرحلة',
        'ملاحظات مفتوحة',
        'المطابقة',
      ];
      for (var i = 1; i < headers.length; i++) {
        expect(
          x(tester, headers[i]),
          lessThan(x(tester, headers[i - 1])),
          reason: headers[i],
        );
      }
      // flex 4 : 3 → the first two columns start 4/14 of the inner width apart.
      final inner = 760 - 2 * 18 - 2; // padding + card border
      final first = tester.getTopRight(find.text('العميل')).dx;
      final second = tester.getTopRight(find.text('القطاع')).dx;
      expect(first - second, closeTo(inner * 4 / 14, 0.5));
      expect(find.byType(ClientTableRow), findsNWidgets(8));
    },
  );

  testWidgets(
    'rows show values, compliance "—" for null, and red for many open findings',
    (tester) async {
      await pumpDashboardWidget(
        tester,
        SizedBox(
          width: 760,
          child: ClientsTable(
            clients: expectedClients,
            selectedClientId: null,
            onClientTap: (_) {},
          ),
        ),
      );

      Text cell(String clientId, String text) => tester.widget<Text>(
        find.descendant(
          of: find.byWidgetPredicate(
            (w) => w is ClientTableRow && w.client.id == clientId,
          ),
          matching: find.text(text),
        ),
      );

      expect(cell('CL-002', '9').style!.color, HaseenColors.red);
      expect(cell('CL-005', '1').style!.color, HaseenColors.navy);
      expect(cell('CL-005', '94%'), isNotNull);
      expect(cell('CL-008', '—'), isNotNull);
      final pill = tester.widget<StatusBadge>(
        find.descendant(
          of: find.byWidgetPredicate(
            (w) => w is ClientTableRow && w.client.id == 'CL-007',
          ),
          matching: find.byType(StatusBadge),
        ),
      );
      expect(
        (pill.text, pill.background, pill.foreground),
        ('معاينة', HaseenColors.infoSoft, HaseenColors.infoText),
      );
    },
  );

  testWidgets(
    '16. tapping a row reports that exact client and only it is highlighted',
    (tester) async {
      Client? tapped;
      await pumpDashboardWidget(
        tester,
        SizedBox(
          width: 760,
          child: ClientsTable(
            clients: expectedClients,
            selectedClientId: 'CL-003',
            onClientTap: (c) => tapped = c,
          ),
        ),
      );

      await tester.tap(find.text('بنك فلسطين'));
      expect(tapped, expectedClients[4]);

      final rows = tester.widgetList<ClientTableRow>(
        find.byType(ClientTableRow),
      );
      expect(
        [
          for (final r in rows)
            if (r.isSelected) r.client.id,
        ],
        ['CL-003'],
      );
      final material = tester.widget<Material>(
        find
            .descendant(
              of: find.byWidgetPredicate(
                (w) => w is ClientTableRow && w.isSelected,
              ),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(material.color, HaseenColors.selectedRow);
    },
  );

  testWidgets(
    '17. details panel shows the client facts in the original order and wires the buttons',
    (tester) async {
      Client? scheduled, reported;
      final client = expectedClients[1];
      await pumpDashboardWidget(
        tester,
        SizedBox(
          width: 340,
          child: ClientDetailsPanel(
            client: client,
            onScheduleVisit: (c) => scheduled = c,
            onReports: (c) => reported = c,
          ),
        ),
      );

      expect(find.text('ب'), findsOneWidget);
      expect(find.text('مؤسسة حكومية'), findsOneWidget);
      const labels = [
        'المرحلة',
        'العقد',
        'تكرار الزيارات',
        'المفتش المسؤول',
        'جهة التواصل',
        'ملاحظات مفتوحة',
      ];
      const values = [
        'متعاقد',
        '2025-12-16 ← 2026-12-15',
        'زيارة أسبوعية',
        'م. سارة',
        'مدير الخدمات العامة',
        '9',
      ];
      for (var i = 0; i < labels.length; i++) {
        expect(find.text(values[i]), findsOneWidget, reason: labels[i]);
        if (i > 0) {
          expect(
            tester.getTopLeft(find.text(labels[i])).dy,
            greaterThan(tester.getTopLeft(find.text(labels[i - 1])).dy),
          );
        }
      }

      await tester.tap(find.text('جدولة زيارة'));
      await tester.tap(find.text('التقارير'));
      expect((scheduled, reported), (client, client));
    },
  );

  testWidgets(
    '18. details panel shows an empty state when nothing is selected',
    (tester) async {
      await pumpDashboardWidget(
        tester,
        SizedBox(
          width: 340,
          child: ClientDetailsPanel(
            client: null,
            onScheduleVisit: (_) {},
            onReports: (_) {},
          ),
        ),
      );

      expect(find.text('لا يوجد عميل محدد'), findsOneWidget);
      expect(find.text('جدولة زيارة'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('filter bar lists the five filters in order with counts', (
    tester,
  ) async {
    ClientStage? picked = ClientStage.contracted;
    await pumpDashboardWidget(
      tester,
      ClientsFilterBar(
        selectedStage: null,
        summary: ClientsSummary.fromClients(expectedClients),
        onStageSelected: (s) => picked = s,
        onAddClient: () {},
      ),
    );

    const labels = [
      'الكل (8)',
      'متعاقد (5)',
      'عرض سعر (1)',
      'معاينة (1)',
      'محتمل (1)',
    ];
    for (var i = 1; i < labels.length; i++) {
      expect(
        x(tester, labels[i]),
        lessThan(x(tester, labels[i - 1])),
        reason: labels[i],
      );
    }
    final chips = tester.widgetList<ClientsStageChip>(
      find.byType(ClientsStageChip),
    );
    expect(
      [for (final c in chips) c.selected],
      [true, false, false, false, false],
    );

    await tester.tap(find.text('الكل (8)'));
    expect(picked, isNull);
    await tester.tap(find.text('معاينة (1)'));
    expect(picked, ClientStage.inspection);
  });

  testWidgets('an empty table shows a message instead of rows', (tester) async {
    await pumpDashboardWidget(
      tester,
      SizedBox(
        width: 760,
        child: ClientsTable(
          clients: const [],
          selectedClientId: null,
          onClientTap: (_) {},
        ),
      ),
    );

    expect(find.text('العميل'), findsOneWidget);
    expect(find.text('لا يوجد عملاء في هذه المرحلة'), findsOneWidget);
  });
}
