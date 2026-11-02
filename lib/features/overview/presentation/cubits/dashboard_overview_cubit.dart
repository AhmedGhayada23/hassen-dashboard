import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_dashboard_overview.dart';
import 'dashboard_overview_state.dart';

/// Loads the overview snapshot and exposes loading / success / failure.
class DashboardOverviewCubit extends Cubit<DashboardOverviewState> {
  final GetDashboardOverview _getOverview;

  DashboardOverviewCubit(this._getOverview)
    : super(const DashboardOverviewInitial());

  Future<void> load() async {
    emit(const DashboardOverviewLoading());
    final result = await _getOverview(const NoParams());
    if (isClosed) return;
    emit(
      result.fold(DashboardOverviewFailure.new, DashboardOverviewLoaded.new),
    );
  }
}
