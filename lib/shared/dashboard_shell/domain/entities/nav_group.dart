import 'nav_destination.dart';
import 'nav_item.dart';

/// A titled section of sidebar entries.
class NavGroup {
  final String title;
  final List<NavItem> items;

  const NavGroup({required this.title, required this.items});

  /// Replaces the static counters of the given destinations with live ones.
  NavGroup withBadgeCounts(Map<NavDestination, int> counts) => counts.isEmpty
      ? this
      : NavGroup(
          title: title,
          items: [
            for (final item in items)
              if (counts[item.destination] case final count?)
                item.withBadgeCount(count)
              else
                item,
          ],
        );
}
