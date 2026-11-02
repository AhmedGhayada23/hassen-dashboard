import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/client.dart';

/// Initial avatar with the client's name and sector.
class ClientDetailsHeader extends StatelessWidget {
  final Client client;

  const ClientDetailsHeader({super.key, required this.client});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 44.r,
        height: 44.r,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: HaseenColors.navy,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Text(
          client.name.characters.first,
          style: TextStyle(
            color: HaseenColors.gold,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      SizedBox(width: 12.w),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              client.name,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: HaseenColors.navy,
              ),
            ),
            Text(
              client.type,
              style: TextStyle(fontSize: 12.sp, color: HaseenColors.muted),
            ),
          ],
        ),
      ),
    ],
  );
}
