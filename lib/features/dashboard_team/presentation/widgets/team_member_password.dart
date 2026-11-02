import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

/// The temporary password on a card: masked until the admin reveals it, with
/// a copy button for handing it to the employee.
class TeamMemberPassword extends StatelessWidget {
  static const mask = '••••••••••';

  final String password;
  final bool revealed;
  final VoidCallback onToggleVisibility;
  final VoidCallback onCopy;

  const TeamMemberPassword({
    super.key,
    required this.password,
    required this.revealed,
    required this.onToggleVisibility,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsetsDirectional.only(start: 10.w, end: 2.w),
    decoration: BoxDecoration(
      color: HaseenColors.bg,
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: Row(
      children: [
        Icon(Icons.key_outlined, size: 14.sp, color: HaseenColors.muted),
        SizedBox(width: 6.w),
        Text(
          'كلمة المرور المؤقتة',
          style: TextStyle(fontSize: 11.sp, color: HaseenColors.muted),
        ),
        const Spacer(),
        Flexible(
          flex: 0,
          child: Text(
            revealed ? password : mask,
            textDirection: TextDirection.ltr,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: HaseenColors.navy,
              letterSpacing: revealed ? 0.5 : 1,
            ),
          ),
        ),
        _IconAction(
          tooltip: revealed ? 'إخفاء كلمة المرور' : 'عرض كلمة المرور',
          icon: revealed
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          onPressed: onToggleVisibility,
        ),
        _IconAction(
          tooltip: 'نسخ كلمة المرور',
          icon: Icons.copy_outlined,
          onPressed: onCopy,
        ),
      ],
    ),
  );
}

class _IconAction extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  const _IconAction({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    onPressed: onPressed,
    visualDensity: VisualDensity.compact,
    icon: Icon(icon, size: 16.sp, color: HaseenColors.muted),
  );
}
