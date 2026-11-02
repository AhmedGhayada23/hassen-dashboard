import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/client.dart';
import 'client_actions_buttons.dart';
import 'client_details_facts.dart';
import 'client_details_header.dart';

/// Details card for the selected client, or an empty state when there is none.
class ClientDetailsPanel extends StatelessWidget {
  final Client? client;
  final ValueChanged<Client> onScheduleVisit;
  final ValueChanged<Client> onReports;

  const ClientDetailsPanel({
    super.key,
    required this.client,
    required this.onScheduleVisit,
    required this.onReports,
  });

  @override
  Widget build(BuildContext context) {
    final client = this.client;
    return AppCard(
      padding: EdgeInsets.all(18.r),
      child: client == null
          ? Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Text(
                'لا يوجد عميل محدد',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.sp, color: HaseenColors.muted),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClientDetailsHeader(client: client),
                SizedBox(height: 16.h),
                ClientDetailsFacts(client: client),
                SizedBox(height: 8.h),
                ClientActionsButtons(
                  onScheduleVisit: () => onScheduleVisit(client),
                  onReports: () => onReports(client),
                ),
              ],
            ),
    );
  }
}
