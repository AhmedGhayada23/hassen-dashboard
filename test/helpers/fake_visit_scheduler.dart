import 'package:flutter/widgets.dart';
import 'package:hassen_dashboard/shared/visit_scheduling/visit_scheduler.dart';

/// Records the facilities a visit was asked to be booked at.
class FakeVisitScheduler implements VisitScheduler {
  final facilities = <String>[];

  @override
  Future<void> scheduleAt(
    BuildContext context, {
    required String facility,
  }) async => facilities.add(facility);
}
