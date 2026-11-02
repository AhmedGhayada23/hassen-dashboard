import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/risk.dart';
import '../../domain/entities/risk_matrix.dart';

sealed class DashboardRisksState extends Equatable {
  const DashboardRisksState();

  @override
  List<Object?> get props => [];
}

final class DashboardRisksInitial extends DashboardRisksState {
  const DashboardRisksInitial();
}

final class DashboardRisksLoading extends DashboardRisksState {
  const DashboardRisksLoading();
}

final class DashboardRisksFailure extends DashboardRisksState {
  final Failure failure;

  const DashboardRisksFailure(this.failure);

  @override
  List<Object?> get props => [failure];
}

final class DashboardRisksLoaded extends DashboardRisksState {
  final List<Risk> risks;

  /// Heat map built once from [risks] when they load.
  final RiskMatrix matrix;

  /// Selection by stable id; null only when the register is empty.
  final String? selectedRiskId;

  const DashboardRisksLoaded({
    required this.risks,
    required this.matrix,
    this.selectedRiskId,
  });

  Risk? get selectedRisk =>
      risks.where((r) => r.id == selectedRiskId).firstOrNull;

  @override
  List<Object?> get props => [risks, matrix, selectedRiskId];
}
