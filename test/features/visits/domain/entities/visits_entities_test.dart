import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/inspector.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/visit_day.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/visit_status.dart';

import '../../fixtures/visits_fixture.dart';

void main() {
  test('VisitStatus keeps the four original states in order', () {
    expect(VisitStatus.values, [
      VisitStatus.done,
      VisitStatus.inProgress,
      VisitStatus.planned,
      VisitStatus.preContract,
    ]);
  });

  test('Inspector and VisitDay compare by value', () {
    expect(const Inspector(id: 'uid-ahmad', name: 'م. أحمد'), ahmad);
    expect(
      const VisitDay(order: 4, label: 'الأربعاء 28', date: '2026-10-28'),
      wed,
    );
    expect(const Inspector(id: 'uid-other', name: 'م. أحمد'), isNot(ahmad));
  });

  group('VisitSchedule', () {
    final schedule = expectedSchedule;

    test('returns the visits of one cell in schedule order', () {
      expect(schedule.visitsFor(ahmad, wed).map((v) => v.time), [
        '09:00',
        '11:30',
      ]);
      expect(
        schedule.visitsFor(sara, thu).single.status,
        VisitStatus.preContract,
      );
      expect(schedule.visitsFor(layla, wed), isEmpty);
    });

    test('counts visits per inspector', () {
      expect(
        [for (final i in schedule.inspectors) schedule.visitCountFor(i)],
        [4, 4, 3, 2],
      );
      expect(
        schedule.visitCountFor(
          const Inspector(id: 'uid-missing', name: 'غير موجود'),
        ),
        0,
      );
    });

    test('marks only today (index 4)', () {
      expect(schedule.today?.order, 4);
      expect(
        [for (final d in schedule.days) schedule.isToday(d)],
        [false, false, false, false, true, false],
      );
    });

    test('every visit falls inside the grid', () {
      for (final v in schedule.visits) {
        expect(schedule.inspectors, contains(v.inspector));
        expect(schedule.days, contains(v.day));
      }
      final cells = [
        for (final i in schedule.inspectors)
          for (final d in schedule.days) ...schedule.visitsFor(i, d),
      ];
      expect(cells, hasLength(13));
    });
  });
}
