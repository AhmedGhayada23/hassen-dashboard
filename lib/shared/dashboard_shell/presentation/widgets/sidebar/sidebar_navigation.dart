import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../domain/entities/nav_destination.dart';
import '../../../domain/entities/nav_group.dart';
import '../../config/dashboard_navigation_config.dart';
import '../../cubits/dashboard_navigation_cubit.dart';
import 'sidebar_nav_group.dart';

/// Scrollable list of nav groups; rebuilds when the active destination changes.
class SidebarNavigation extends StatelessWidget {
  final List<NavGroup> groups;

  const SidebarNavigation({super.key, required this.groups});

  void _select(BuildContext context, NavDestination destination) {
    context.read<DashboardNavigationCubit>().select(destination);
    // Destinations without a page yet only move the highlight.
    final route = destination.route;
    if (route != null && ModalRoute.of(context)?.settings.name != route) {
      Navigator.of(context).pushReplacementNamed(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardNavigationCubit, NavDestination>(
      builder: (context, active) => ListView(
        padding: EdgeInsets.all(10.r),
        children: [
          for (final group in groups)
            SidebarNavGroup(
              group: group,
              active: active,
              onSelect: (d) => _select(context, d),
            ),
        ],
      ),
    );
  }
}
