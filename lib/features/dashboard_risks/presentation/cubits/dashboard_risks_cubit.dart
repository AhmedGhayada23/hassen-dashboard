import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/risk_matrix.dart';
import '../../domain/usecases/get_risks.dart';
import 'dashboard_risks_state.dart';

/// Loads the risk register, builds its matrix, and tracks the selected risk.
class DashboardRisksCubit extends Cubit<DashboardRisksState> {
  final GetRisks _getRisks;

  DashboardRisksCubit(this._getRisks) : super(const DashboardRisksInitial());

  Future<void> load() async {
    emit(const DashboardRisksLoading());
    final result = await _getRisks(const NoParams());
    if (isClosed) return;
    emit(
      result.fold(
        DashboardRisksFailure.new,
        (risks) => DashboardRisksLoaded(
          risks: risks,
          matrix: RiskMatrix.fromRisks(risks),
          selectedRiskId: risks.firstOrNull?.id,
        ),
      ),
    );
  }

  /// Selects a risk from the register; unknown ids are ignored.
  void selectRisk(String id) {
    final current = state;
    if (current is! DashboardRisksLoaded) return;
    if (id == current.selectedRiskId) return;
    if (!current.risks.any((r) => r.id == id)) return;
    emit(
      DashboardRisksLoaded(
        risks: current.risks,
        matrix: current.matrix,
        selectedRiskId: id,
      ),
    );
  }
}
