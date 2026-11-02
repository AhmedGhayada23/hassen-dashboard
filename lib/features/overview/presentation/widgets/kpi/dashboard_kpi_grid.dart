import 'package:flutter/material.dart';

import '../../../domain/entities/dashboard_kpi.dart';
import '../../config/overview_layout_config.dart';
import 'kpi_card.dart';

/// Responsive KPI grid: 6 columns on wide content, 3 otherwise.
class DashboardKpiGrid extends StatelessWidget {
  final List<DashboardKpi> kpis;
  final ValueChanged<DashboardKpi> onKpiTap;

  const DashboardKpiGrid({
    super.key,
    required this.kpis,
    required this.onKpiTap,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = OverviewLayoutConfig.kpiColumns(constraints.maxWidth);
      final gap = OverviewLayoutConfig.kpiGap;
      final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: OverviewLayoutConfig.kpiRunGap,
        children: [
          for (final kpi in kpis)
            SizedBox(
              width: width,
              child: KpiCard(kpi: kpi, onTap: () => onKpiTap(kpi)),
            ),
        ],
      );
    },
  );
}
