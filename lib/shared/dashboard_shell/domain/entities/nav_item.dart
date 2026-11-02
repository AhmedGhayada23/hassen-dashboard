import 'nav_destination.dart';

/// A single sidebar entry pointing at a [NavDestination].
class NavItem {
  final NavDestination destination;
  final String label;

  /// Pending-work counter shown next to the label; 0 hides it.
  final int badgeCount;

  /// Marks the counter as overdue/urgent rather than informational.
  final bool isAlert;

  const NavItem({
    required this.destination,
    required this.label,
    this.badgeCount = 0,
    this.isAlert = false,
  });

  bool get hasBadge => badgeCount > 0;

  NavItem withBadgeCount(int count) => NavItem(
    destination: destination,
    label: label,
    badgeCount: count,
    isAlert: isAlert,
  );
}
