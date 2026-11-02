import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../domain/entities/contract_plan.dart';
import '../../domain/entities/deal.dart';
import '../../domain/entities/deal_status.dart';
import 'deals_table.dart';

/// Shimmering stand-in for the deals table while Firebase loads. The rows
/// below only give the bones their shape; none of their text is readable.
class DealsSkeleton extends StatelessWidget {
  static const _plan = ContractPlan(id: 'p', name: 'مدة التعاقد', months: 12);
  static final _deals = [
    for (final (i, status) in const [
      DealStatus.pending,
      DealStatus.pending,
      DealStatus.accepted,
      DealStatus.accepted,
      DealStatus.accepted,
      DealStatus.rejected,
    ].indexed)
      Deal(
        id: 'skeleton-$i',
        number: 'Q-0000-000',
        client: 'اسم العميل والمنشأة',
        date: '0000-00-00',
        status: status,
        planId: _plan.id,
        startDate: DateTime(2026),
      ),
  ];

  const DealsSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Skeletonizer(
    child: DealsTable(
      deals: _deals,
      plans: const [_plan],
      onAccept: (_) {},
      onReject: (_) {},
      onSelectPlan: (_, _) {},
    ),
  );
}
