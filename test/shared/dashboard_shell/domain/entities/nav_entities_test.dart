import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/domain/entities/nav_destination.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/domain/entities/nav_group.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/domain/entities/nav_item.dart';

void main() {
  group('NavItem', () {
    test('holds its destination and label', () {
      const item = NavItem(destination: NavDestination.team, label: 'الفريق');

      expect(item.destination, NavDestination.team);
      expect(item.label, 'الفريق');
    });
  });

  group('NavGroup', () {
    test('holds its title and items in order', () {
      const group = NavGroup(
        title: 'الإدارة',
        items: [
          NavItem(destination: NavDestination.team, label: 'الفريق'),
          NavItem(destination: NavDestination.settings, label: 'الإعدادات'),
        ],
      );

      expect(group.title, 'الإدارة');
      expect(group.items.map((i) => i.destination), [
        NavDestination.team,
        NavDestination.settings,
      ]);
    });

    group('withBadgeCounts', () {
      const operations = NavGroup(
        title: 'التشغيل',
        items: [
          NavItem(destination: NavDestination.overview, label: 'نظرة عامة'),
          NavItem(
            destination: NavDestination.inspectionReview,
            label: 'مراجعة التفتيش',
            badgeCount: 4,
          ),
          NavItem(
            destination: NavDestination.correctiveActions,
            label: 'الإجراءات التصحيحية',
            badgeCount: 3,
            isAlert: true,
          ),
        ],
      );

      (int, bool) badgeOf(NavGroup g, NavDestination d) {
        final item = g.items.firstWhere((i) => i.destination == d);
        return (item.badgeCount, item.isAlert);
      }

      test('replaces only the given counters and keeps the alert flag', () {
        final live = operations.withBadgeCounts({
          NavDestination.inspectionReview: 2,
          NavDestination.correctiveActions: 5,
        });

        expect(badgeOf(live, NavDestination.inspectionReview), (2, false));
        expect(badgeOf(live, NavDestination.correctiveActions), (5, true));
        expect(badgeOf(live, NavDestination.overview), (0, false));
        expect(
          live.items.map((i) => i.label),
          operations.items.map((i) => i.label),
        );
      });

      test('a zero count hides the badge', () {
        final live = operations.withBadgeCounts({
          NavDestination.inspectionReview: 0,
        });

        expect(live.items[1].hasBadge, isFalse);
      });

      test('no overrides returns the same group', () {
        expect(
          identical(operations.withBadgeCounts(const {}), operations),
          isTrue,
        );
      });
    });
  });
}
