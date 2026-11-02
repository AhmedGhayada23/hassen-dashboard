import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/nav_destination.dart';
import '../config/dashboard_navigation_config.dart';
import '../cubits/dashboard_navigation_cubit.dart';
import 'sidebar/dashboard_sidebar.dart';

/// Page frame shared by every dashboard screen: sidebar | header over body.
///
/// Marks [destination] active in the sidebar when the page opens, so the
/// highlight follows the current route (including direct URL loads on web).
class DashboardShell extends StatefulWidget {
  final NavDestination destination;
  final Widget header;
  final Widget body;

  /// Live sidebar counters that replace the static ones from the nav config.
  final Map<NavDestination, int> badgeCounts;

  const DashboardShell({
    super.key,
    required this.destination,
    required this.header,
    required this.body,
    this.badgeCounts = const {},
  });

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardNavigationCubit>().select(widget.destination);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          DashboardSidebar(
            groups: [
              for (final group in dashboardNavGroups)
                group.withBadgeCounts(widget.badgeCounts),
            ],
            profile: sidebarProfile,
          ),
          Expanded(
            child: Column(
              children: [
                widget.header,
                Expanded(child: widget.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
