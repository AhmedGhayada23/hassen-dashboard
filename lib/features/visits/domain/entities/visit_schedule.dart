import 'package:equatable/equatable.dart';

import 'inspector.dart';
import 'visit.dart';
import 'visit_day.dart';

/// One week of visits laid out as inspectors × days.
class VisitSchedule extends Equatable {
  /// Added to an inspector's load when booked at the requested slot, so a free
  /// inspector is always suggested before a busy one.
  static const _busyPenalty = 1000;

  final String weekLabel;
  final List<Inspector> inspectors;
  final List<VisitDay> days;

  /// The column for the current day; null when it is not a working day
  /// (Friday), so no column is highlighted.
  final VisitDay? today;
  final List<Visit> visits;

  const VisitSchedule({
    required this.weekLabel,
    required this.inspectors,
    required this.days,
    this.today,
    required this.visits,
  });

  /// Visits in one grid cell, earliest first; equal times keep their order.
  List<Visit> visitsFor(Inspector inspector, VisitDay day) {
    final cell =
        visits
            .where((v) => v.inspector == inspector && v.day == day)
            .indexed
            .toList()
          ..sort((a, b) {
            final byTime = a.$2.time.compareTo(b.$2.time);
            return byTime != 0 ? byTime : a.$1.compareTo(b.$1);
          });
    return [for (final (_, visit) in cell) visit];
  }

  int visitCountFor(Inspector inspector) =>
      visits.where((v) => v.inspector == inspector).length;

  bool isToday(VisitDay day) => day == today;

  /// Whether [inspector] already has a visit on [day] at [time].
  bool hasClash(Inspector inspector, VisitDay day, String time) => visits.any(
    (v) => v.inspector == inspector && v.day == day && v.time == time,
  );

  /// The inspector with the fewest visits this week who is free on [day] at
  /// [time]; the first in roster order wins a tie.
  Inspector suggestedInspector(VisitDay day, String time) {
    int load(Inspector i) =>
        visitCountFor(i) + (hasClash(i, day, time) ? _busyPenalty : 0);
    return inspectors.reduce((best, i) => load(i) < load(best) ? i : best);
  }

  @override
  List<Object?> get props => [weekLabel, inspectors, days, today, visits];
}
