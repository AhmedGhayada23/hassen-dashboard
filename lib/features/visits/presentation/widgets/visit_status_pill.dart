import 'package:flutter/material.dart';

import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/visit_status.dart';
import '../config/visit_status_style.dart';

class VisitStatusPill extends StatelessWidget {
  final VisitStatus status;

  const VisitStatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final style = status.style;
    return StatusBadge(style.label, style.background, style.foreground);
  }
}
