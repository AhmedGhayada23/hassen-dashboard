import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/client_stage.dart';
import '../../domain/entities/clients_summary.dart';
import '../config/client_stage_style.dart';
import 'clients_stage_chip.dart';

/// Stage filter chips with counts, plus the "new client" action, which shows
/// a spinner and is disabled while the form loads or a client is saved.
class ClientsFilterBar extends StatelessWidget {
  final ClientStage? selectedStage;
  final ClientsSummary summary;
  final ValueChanged<ClientStage?> onStageSelected;
  final VoidCallback onAddClient;
  final bool isBusy;

  const ClientsFilterBar({
    super.key,
    required this.selectedStage,
    required this.summary,
    required this.onStageSelected,
    required this.onAddClient,
    this.isBusy = false,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            for (final stage in clientStageFilters)
              ClientsStageChip(
                label: clientStageFilterLabel(stage),
                count: summary.countFor(stage),
                selected: stage == selectedStage,
                onSelected: () => onStageSelected(stage),
              ),
          ],
        ),
      ),
      FilledButton(
        onPressed: isBusy ? null : onAddClient,
        style: FilledButton.styleFrom(
          backgroundColor: HaseenColors.gold,
          foregroundColor: HaseenColors.navy,
          disabledBackgroundColor: HaseenColors.gold.withValues(alpha: .7),
          minimumSize: Size(0, 38.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: isBusy
            ? SizedBox(
                width: 18.r,
                height: 18.r,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: HaseenColors.navy,
                ),
              )
            : const Text(
                '+ عميل جديد',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
      ),
    ],
  );
}
