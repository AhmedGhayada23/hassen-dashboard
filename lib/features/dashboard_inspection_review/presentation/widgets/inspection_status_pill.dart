import 'package:flutter/material.dart';

import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/inspection_decision.dart';
import '../config/inspection_decision_style.dart';

class InspectionStatusPill extends StatelessWidget {
  final InspectionDecision decision;

  const InspectionStatusPill({super.key, required this.decision});

  @override
  Widget build(BuildContext context) {
    final style = decision.style;
    return StatusBadge(style.label, style.background, style.foreground);
  }
}
