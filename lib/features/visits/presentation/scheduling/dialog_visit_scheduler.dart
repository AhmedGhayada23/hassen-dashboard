import 'package:flutter/material.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../shared/visit_scheduling/visit_scheduler.dart';
import '../../domain/entities/visit_schedule.dart';
import '../../domain/entities/visit_scheduling_options.dart';
import '../../domain/usecases/get_visit_schedule.dart';
import '../../domain/usecases/get_visit_scheduling_options.dart';
import '../../domain/usecases/schedule_visit.dart';
import '../config/visits_messages.dart';
import '../widgets/schedule_visit_dialog.dart';

/// Books a visit from another page with the schedule's own form, the
/// facility fixed: loads this week and the booking options, opens the form,
/// then books the visit and confirms it with a toast.
class DialogVisitScheduler implements VisitScheduler {
  final GetVisitSchedule _getSchedule;
  final GetVisitSchedulingOptions _getOptions;
  final ScheduleVisit _scheduleVisit;

  const DialogVisitScheduler(
    this._getSchedule,
    this._getOptions,
    this._scheduleVisit,
  );

  @override
  Future<void> scheduleAt(
    BuildContext context, {
    required String facility,
  }) async {
    final (schedule, options) = await _whileLoading(
      context,
      (_getSchedule(0), _getOptions(const NoParams())).wait,
    );
    if (!context.mounted) return;
    await schedule
        .flatMap((s) => options.map((o) => (s, o)))
        .fold(
          (failure) async =>
              showErrorToast(context, VisitsMessages.loadFailed(failure)),
          (loaded) => _book(context, facility, loaded.$1, loaded.$2),
        );
  }

  Future<void> _book(
    BuildContext context,
    String facility,
    VisitSchedule week,
    VisitSchedulingOptions options,
  ) async {
    final place = options.facilities
        .where((f) => f.name == facility)
        .firstOrNull;
    if (place == null) {
      showErrorToast(context, VisitsMessages.facilityNotFound(facility));
      return;
    }
    if (week.inspectors.isEmpty) {
      showErrorToast(context, VisitsMessages.noInspectors);
      return;
    }
    final visit = await showScheduleVisitDialog(
      context,
      schedule: week,
      options: options,
      facility: place,
    );
    if (visit == null || !context.mounted) return;
    final result = await _scheduleVisit(ScheduleVisitParams(visit));
    if (!context.mounted) return;
    result.fold(
      (failure) =>
          showErrorToast(context, VisitsMessages.scheduleFailed(failure)),
      (_) => showSuccessToast(context, VisitsMessages.scheduled(visit)),
    );
  }

  /// Runs [work] behind a modal spinner.
  static Future<T> _whileLoading<T>(
    BuildContext context,
    Future<T> work,
  ) async {
    final navigator = Navigator.of(context);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      return await work;
    } finally {
      navigator.pop();
    }
  }
}
