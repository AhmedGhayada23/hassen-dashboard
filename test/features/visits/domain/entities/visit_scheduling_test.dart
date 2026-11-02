import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/visit.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/visit_facility.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/visit_schedule.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/visit_status.dart';

import '../../fixtures/visits_fixture.dart';

VisitSchedule _with(List<Visit> extra) => VisitSchedule(
  weekLabel: expectedSchedule.weekLabel,
  inspectors: expectedSchedule.inspectors,
  days: expectedSchedule.days,
  today: expectedSchedule.today,
  visits: [...expectedSchedule.visits, ...extra],
);

void main() {
  group('clash detection', () {
    test(
      'an inspector is busy only at an exact day and time they already have',
      () {
        expect(expectedSchedule.hasClash(ahmad, mon, '10:00'), isTrue);
        expect(expectedSchedule.hasClash(ahmad, mon, '10:30'), isFalse);
        expect(expectedSchedule.hasClash(ahmad, tue, '10:00'), isFalse);
        expect(expectedSchedule.hasClash(layla, mon, '10:00'), isFalse);
      },
    );
  });

  group('suggested inspector', () {
    test(
      'is the least-loaded inspector (Layla has 2 visits) when everyone is free',
      () {
        expect(
          [
            for (final i in expectedSchedule.inspectors)
              expectedSchedule.visitCountFor(i),
          ],
          [4, 4, 3, 2],
        );
        expect(expectedSchedule.suggestedInspector(wed, '10:00'), layla);
      },
    );

    test('skips an inspector who is busy at that slot', () {
      // Layla already has Thursday 09:00, so the next lightest (Khaled, 3) is suggested.
      expect(expectedSchedule.suggestedInspector(thu, '09:00'), khaled);
    });

    test('a tie goes to the first inspector in roster order', () {
      final empty = VisitSchedule(
        weekLabel: 'w',
        inspectors: const [ahmad, sara],
        days: const [sat],
        today: sat,
        visits: const [],
      );
      expect(empty.suggestedInspector(sat, '10:00'), ahmad);
    });

    test('suggests a busy inspector only if everyone is busy', () {
      final allBusy = VisitSchedule(
        weekLabel: 'w',
        inspectors: const [ahmad, sara],
        days: const [sat],
        today: sat,
        visits: [
          for (final i in const [ahmad, sara])
            Visit(
              inspector: i,
              day: sat,
              time: '10:00',
              facility: 'f',
              type: 't',
              status: VisitStatus.planned,
            ),
        ],
      );
      expect(allBusy.suggestedInspector(sat, '10:00'), ahmad);
    });
  });

  test('cells list visits earliest first, wherever the new one was stored', () {
    const added = Visit(
      inspector: ahmad,
      day: wed,
      time: '10:00',
      facility: 'بلدية غزة',
      type: 'تفتيش دوري',
      status: VisitStatus.planned,
    );

    expect(_with([added]).visitsFor(ahmad, wed).map((v) => v.time), [
      '09:00',
      '10:00',
      '11:30',
    ]);
    expect(_with([added]).visitCountFor(ahmad), 5);
  });

  group('scheduling options', () {
    test(
      'contracted facilities default to a routine inspection, others to a pre-contract check',
      () {
        expect(
          expectedOptions.defaultTypeFor(expectedOptions.facilities.first),
          'تفتيش دوري',
        );
        expect(
          expectedOptions.defaultTypeFor(
            const VisitFacility(name: 'مدرسة خاصة — غزة', isContracted: false),
          ),
          'فحص أولي',
        );
      },
    );

    test(
      'only the pre-contract type is booked as pre-contract; the rest are planned',
      () {
        expect(
          {
            for (final t in expectedOptions.visitTypes)
              t: expectedOptions.statusFor(t),
          },
          {
            'تفتيش دوري': VisitStatus.planned,
            'متابعة ملاحظات': VisitStatus.planned,
            'فحص أولي': VisitStatus.preContract,
          },
        );
      },
    );

    test(
      'buildVisit records the facility name and the status for the type',
      () {
        final visit = expectedOptions.buildVisit(
          inspector: khaled,
          day: thu,
          time: '12:15',
          facility: expectedOptions.facilities[6],
          type: 'فحص أولي',
        );

        expect(
          visit,
          const Visit(
            inspector: khaled,
            day: thu,
            time: '12:15',
            facility: 'مدرسة خاصة — غزة',
            type: 'فحص أولي',
            status: VisitStatus.preContract,
          ),
        );
      },
    );
  });
}
