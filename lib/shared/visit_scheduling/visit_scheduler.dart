import 'package:flutter/widgets.dart';

/// Lets any page book a visit at one facility through the visit schedule's
/// own booking form, without depending on the visits feature (which
/// implements it).
abstract interface class VisitScheduler {
  /// Opens the booking form with [facility] fixed, then books the visit and
  /// confirms it — or explains why it couldn't. Completes once the form is
  /// closed and the outcome shown.
  Future<void> scheduleAt(BuildContext context, {required String facility});
}
