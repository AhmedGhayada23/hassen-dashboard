import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../shared/dashboard_shell/presentation/config/dashboard_layout_config.dart';
import '../../domain/entities/client.dart';
import '../../domain/entities/client_stage.dart';
import '../../domain/entities/clients_summary.dart';
import '../config/clients_layout_config.dart';
import 'client_details_panel.dart';
import 'clients_filter_bar.dart';
import 'clients_table.dart';

/// Shimmering stand-in for the clients page while `clients` loads: the real
/// filter bar, table and details panel, drawn as bones. The clients below
/// only give the bones their shape; none of their text is ever readable.
class ClientsSkeleton extends StatelessWidget {
  static const placeholderCount = 6;

  static final _placeholders = [
    for (var i = 0; i < placeholderCount; i++)
      Client(
        id: 'skeleton-$i',
        name: 'اسم المنشأة الكامل',
        type: 'قطاع المنشأة',
        branches: 1,
        stage: ClientStage.contracted,
        openFindings: 0,
        compliance: 90,
        contract: 'تاريخ البداية ← تاريخ النهاية',
        visits: 'تكرار الزيارات',
        inspector: 'اسم المفتش',
        contact: 'جهة التواصل',
        city: 'المدينة',
      ),
  ];

  const ClientsSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Skeletonizer(
    child: SingleChildScrollView(
      padding: DashboardLayoutConfig.contentPadding,
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClientsFilterBar(
            selectedStage: null,
            summary: ClientsSummary.fromClients(_placeholders),
            onStageSelected: (_) {},
            onAddClient: () {},
          ),
          SizedBox(height: DashboardLayoutConfig.sectionGap),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClientsTable(
                  clients: _placeholders,
                  selectedClientId: null,
                  onClientTap: (_) {},
                ),
              ),
              SizedBox(width: ClientsLayoutConfig.panelGap),
              SizedBox(
                width: ClientsLayoutConfig.detailsPanelWidth,
                child: ClientDetailsPanel(
                  client: _placeholders.first,
                  onScheduleVisit: (_) {},
                  onReports: (_) {},
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
