import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/client.dart';
import 'client_table_header.dart';
import 'client_table_row.dart';

class ClientsTable extends StatelessWidget {
  final List<Client> clients;
  final String? selectedClientId;
  final ValueChanged<Client> onClientTap;

  /// Shown in place of rows when [clients] is empty.
  final String emptyMessage;

  const ClientsTable({
    super.key,
    required this.clients,
    required this.selectedClientId,
    required this.onClientTap,
    this.emptyMessage = 'لا يوجد عملاء في هذه المرحلة',
  });

  @override
  Widget build(BuildContext context) => AppCard(
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ClientTableHeader(),
        for (final client in clients)
          ClientTableRow(
            client: client,
            isSelected: client.id == selectedClientId,
            onTap: () => onClientTap(client),
          ),
        if (clients.isEmpty)
          Padding(
            padding: EdgeInsets.all(24.r),
            child: Text(
              emptyMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: HaseenColors.muted),
            ),
          ),
      ],
    ),
  );
}
