import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../domain/entities/risk.dart';
import '../../domain/entities/risk_matrix.dart';
import '../../domain/entities/risk_status.dart';
import 'risk_register_layout.dart';

/// Shimmering stand-in for the register while Firebase loads: the real
/// table and matrix card, drawn as bones. The risks below only give the
/// bones their shape; none of their text is readable.
class RisksSkeleton extends StatelessWidget {
  static final _risks = [
    for (final (i, (likelihood, severity)) in const [
      (4, 5),
      (3, 5),
      (3, 4),
      (2, 5),
      (3, 3),
    ].indexed)
      Risk(
        id: 'skeleton-$i',
        hazard: 'وصف الخطر في المنشأة',
        facility: 'اسم المنشأة',
        likelihood: likelihood,
        severity: severity,
        owner: 'المسؤول عن الخطر',
        status: RiskStatus.open,
        control: 'إجراء التحكم المتفق عليه للخطر',
      ),
  ];

  const RisksSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Skeletonizer(
    child: RiskRegisterLayout(
      risks: _risks,
      matrix: RiskMatrix.fromRisks(_risks),
      selected: _risks.first,
      onRiskTap: (_) {},
    ),
  );
}
