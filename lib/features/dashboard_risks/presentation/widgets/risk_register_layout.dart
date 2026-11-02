import 'package:flutter/material.dart';

import '../../../../shared/dashboard_shell/presentation/config/dashboard_layout_config.dart';
import '../../domain/entities/risk.dart';
import '../../domain/entities/risk_matrix.dart';
import '../config/risks_layout_config.dart';
import 'risk_matrix_card.dart';
import 'risks_table.dart';

/// The register table beside the matrix card, shared by the page and its
/// loading skeleton.
class RiskRegisterLayout extends StatelessWidget {
  final List<Risk> risks;
  final RiskMatrix matrix;
  final Risk? selected;
  final ValueChanged<Risk> onRiskTap;
  final String emptyMessage;

  const RiskRegisterLayout({
    super.key,
    required this.risks,
    required this.matrix,
    required this.selected,
    required this.onRiskTap,
    this.emptyMessage = '',
  });

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: DashboardLayoutConfig.contentPadding,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: RisksTable(
            risks: risks,
            selectedRiskId: selected?.id,
            onRiskTap: onRiskTap,
            emptyMessage: emptyMessage,
          ),
        ),
        SizedBox(width: RisksLayoutConfig.panelGap),
        SizedBox(
          width: RisksLayoutConfig.matrixCardWidth,
          child: RiskMatrixCard(matrix: matrix, selected: selected),
        ),
      ],
    ),
  );
}
