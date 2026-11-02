import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/contract_plan.dart';
import '../../domain/entities/deal.dart';

sealed class DashboardContractsState extends Equatable {
  const DashboardContractsState();

  @override
  List<Object?> get props => [];
}

final class DashboardContractsInitial extends DashboardContractsState {
  const DashboardContractsInitial();
}

final class DashboardContractsLoading extends DashboardContractsState {
  const DashboardContractsLoading();
}

final class DashboardContractsFailure extends DashboardContractsState {
  final Failure failure;

  const DashboardContractsFailure(this.failure);

  @override
  List<Object?> get props => [failure];
}

final class DashboardContractsLoaded extends DashboardContractsState {
  final List<Deal> deals;
  final List<ContractPlan> plans;

  /// Ids of the deals whose change is being saved.
  final Set<String> savingIds;

  /// The deal just accepted or rejected, for a one-off confirmation; cleared
  /// by the next change.
  final Deal? lastDecided;

  /// Set when the last decision or contract length couldn't be saved;
  /// cleared by the next change.
  final Failure? actionFailure;

  const DashboardContractsLoaded({
    required this.deals,
    required this.plans,
    this.savingIds = const {},
    this.lastDecided,
    this.actionFailure,
  });

  bool isSaving(Deal deal) => savingIds.contains(deal.id);

  @override
  List<Object?> get props => [
    deals,
    plans,
    savingIds,
    lastDecided,
    actionFailure,
  ];
}
