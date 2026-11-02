import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/dashboard_shell/domain/entities/nav_destination.dart';
import '../../../../shared/dashboard_shell/presentation/config/dashboard_layout_config.dart';
import '../../../../shared/dashboard_shell/presentation/config/dashboard_navigation_config.dart';
import '../../../../shared/dashboard_shell/presentation/widgets/dashboard_load_error.dart';
import '../../../../shared/dashboard_shell/presentation/widgets/dashboard_shell.dart';
import '../../../../shared/dashboard_shell/presentation/widgets/header/dashboard_header.dart';
import '../../../../shared/dashboard_shell/presentation/widgets/header/notifications_button.dart';
import '../config/inspection_review_layout_config.dart';
import '../cubits/inspection_review_cubit.dart';
import '../cubits/inspection_review_state.dart';
import '../widgets/inspection_review_details.dart';
import '../widgets/inspection_review_list.dart';

/// HASEEN dashboard — inspection review. Expects an [InspectionReviewCubit] above it.
class DashboardInspectionReviewPage extends StatelessWidget {
  const DashboardInspectionReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InspectionReviewCubit, InspectionReviewState>(
      listenWhen: (_, state) =>
          state is InspectionReviewLoaded && state.actionFailure != null,
      listener: (context, _) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذّر حفظ القرار، حاول مرة أخرى'),
          behavior: SnackBarBehavior.floating,
        ),
      ),
      builder: (context, state) => DashboardShell(
        destination: NavDestination.inspectionReview,
        // The sidebar counter follows the live queue once loaded.
        badgeCounts: {
          if (state is InspectionReviewLoaded)
            NavDestination.inspectionReview: state.pendingCount,
        },
        header: DashboardHeader(
          title: 'مراجعة التفتيش',
          searchHint: 'ابحث عن عميل، زيارة، أو إجراء…',
          actions: [
            NotificationsButton(
              hasUnread: demoHasUnreadNotifications,
              onPressed: () {},
            ),
          ],
        ),
        body: switch (state) {
          InspectionReviewInitial() || InspectionReviewLoading() =>
            const Center(child: CircularProgressIndicator()),
          InspectionReviewFailure() => DashboardLoadError(
            onRetry: context.read<InspectionReviewCubit>().load,
          ),
          InspectionReviewLoaded() => _ReviewContent(state: state),
        },
      ),
    );
  }
}

class _ReviewContent extends StatelessWidget {
  final InspectionReviewLoaded state;

  const _ReviewContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InspectionReviewCubit>();
    final selected = state.selected;
    return SingleChildScrollView(
      padding: DashboardLayoutConfig.contentPadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: InspectionReviewLayoutConfig.listWidth,
            child: InspectionReviewList(
              inspections: state.inspections,
              selectedIndex: state.selectedIndex,
              onSelect: cubit.select,
            ),
          ),
          SizedBox(width: InspectionReviewLayoutConfig.panelGap),
          Expanded(
            child: selected == null
                ? const SizedBox.shrink()
                : InspectionReviewDetails(
                    inspection: selected,
                    onApprove: () => cubit.approve(selected.id),
                    onReturn: () => cubit.returnToInspector(selected.id),
                    onUndo: () => cubit.undoDecision(selected.id),
                  ),
          ),
        ],
      ),
    );
  }
}
