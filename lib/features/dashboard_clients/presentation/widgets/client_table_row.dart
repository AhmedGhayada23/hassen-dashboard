import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/client.dart';
import '../config/clients_layout_config.dart';
import 'client_stage_pill.dart';

/// One client row; the selected one is tinted.
class ClientTableRow extends StatelessWidget {
  final Client client;
  final bool isSelected;
  final VoidCallback onTap;

  const ClientTableRow({
    super.key,
    required this.client,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cell = TextStyle(fontSize: 13.sp);
    final flex = ClientsLayoutConfig.columnFlex;
    final compliance = client.compliance;
    return Material(
      color: isSelected ? HaseenColors.selectedRow : Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: HaseenColors.soft)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: flex[0],
                child: Text(
                  client.name,
                  style: cell.copyWith(
                    fontWeight: FontWeight.w700,
                    color: HaseenColors.navy,
                  ),
                ),
              ),
              Expanded(
                flex: flex[1],
                child: Text(
                  client.type,
                  style: cell.copyWith(color: HaseenColors.muted),
                ),
              ),
              Expanded(
                flex: flex[2],
                child: Text('${client.branches}', style: cell),
              ),
              Expanded(
                flex: flex[3],
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: ClientStagePill(stage: client.stage),
                ),
              ),
              Expanded(
                flex: flex[4],
                child: Text(
                  '${client.openFindings}',
                  style: cell.copyWith(
                    fontWeight: FontWeight.w700,
                    color: client.hasManyOpenFindings
                        ? HaseenColors.red
                        : HaseenColors.navy,
                  ),
                ),
              ),
              Expanded(
                flex: flex[5],
                child: Text(
                  compliance == null ? '—' : '$compliance%',
                  style: cell,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
