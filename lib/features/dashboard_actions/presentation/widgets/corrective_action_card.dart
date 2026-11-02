import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/corrective_action.dart';
import '../config/action_due_style.dart';
import 'action_due_pill.dart';
import 'action_severity_label.dart';

/// Tappable action card: id + severity, title, facility, owner + due pill.
class CorrectiveActionCard extends StatelessWidget {
  final CorrectiveAction action;
  final VoidCallback onTap;

  const CorrectiveActionCard({
    super.key,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(10.r);
    final muted = TextStyle(fontSize: 11.5.sp, color: HaseenColors.muted);
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: action.dueStatus.style.cardBorder),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: Text(action.id, style: muted)),
                  ActionSeverityLabel(severity: action.severity),
                ],
              ),
              SizedBox(height: 6.h),
              Text(
                action.title,
                style: TextStyle(
                  fontSize: 13.sp,
                  height: 1.45,
                  fontWeight: FontWeight.w700,
                  color: HaseenColors.navy,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                action.facility,
                style: TextStyle(fontSize: 12.sp, color: HaseenColors.muted),
              ),
              SizedBox(height: 6.h),
              Row(
                children: [
                  Expanded(child: Text(action.owner, style: muted)),
                  ActionDuePill(action: action),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
