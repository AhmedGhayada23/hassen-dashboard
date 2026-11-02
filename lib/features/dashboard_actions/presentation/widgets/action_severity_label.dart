import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/action_severity.dart';
import '../config/action_severity_style.dart';

/// Colored severity word shown at the top of an action card.
class ActionSeverityLabel extends StatelessWidget {
  final ActionSeverity severity;

  const ActionSeverityLabel({super.key, required this.severity});

  @override
  Widget build(BuildContext context) {
    final style = severity.style;
    return Text(
      style.label,
      style: TextStyle(
        fontSize: 11.5.sp,
        fontWeight: FontWeight.w700,
        color: style.color,
      ),
    );
  }
}
