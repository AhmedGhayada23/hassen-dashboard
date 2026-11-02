import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

/// One stage filter, labelled `stage (count)`.
class ClientsStageChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onSelected;

  const ClientsStageChip({
    super.key,
    required this.label,
    required this.count,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) => ChoiceChip(
    label: Text('$label ($count)'),
    selected: selected,
    showCheckmark: false,
    selectedColor: HaseenColors.navy,
    backgroundColor: Colors.white,
    labelStyle: TextStyle(
      fontSize: 13.sp,
      fontWeight: FontWeight.w700,
      color: selected ? Colors.white : HaseenColors.navy,
    ),
    side: BorderSide(
      color: selected ? HaseenColors.navy : HaseenColors.chipBorder,
    ),
    shape: const StadiumBorder(),
    onSelected: (_) => onSelected(),
  );
}
