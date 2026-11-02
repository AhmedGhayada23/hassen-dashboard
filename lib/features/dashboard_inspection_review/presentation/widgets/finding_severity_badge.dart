import 'package:flutter/material.dart';

import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/finding_severity.dart';
import '../config/finding_severity_style.dart';

class FindingSeverityBadge extends StatelessWidget {
  final FindingSeverity severity;

  const FindingSeverityBadge({super.key, required this.severity});

  @override
  Widget build(BuildContext context) {
    final style = severity.style;
    return StatusBadge(style.label, style.background, style.foreground);
  }
}
