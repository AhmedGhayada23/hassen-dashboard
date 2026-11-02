import 'package:flutter/material.dart';

import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/corrective_action.dart';
import '../config/action_due_style.dart';

/// Deadline text tinted by the action's due status.
class ActionDuePill extends StatelessWidget {
  final CorrectiveAction action;

  const ActionDuePill({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    final style = action.dueStatus.style;
    return StatusBadge(action.dueText, style.background, style.foreground);
  }
}
