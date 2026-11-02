import '../../domain/entities/facility_open_action.dart';

/// The corrective actions still open at client facilities, which a visit
/// follows up. They belong to the corrective-actions board; the app's
/// composition root supplies the implementation, so this feature doesn't
/// depend on that one.
abstract interface class OpenActionsDataSource {
  Future<List<FacilityOpenAction>> getOpenActions();
}
