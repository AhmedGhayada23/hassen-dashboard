import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/dashboard_overview.dart';

sealed class DashboardOverviewState extends Equatable {
  const DashboardOverviewState();

  @override
  List<Object> get props => [];
}

final class DashboardOverviewInitial extends DashboardOverviewState {
  const DashboardOverviewInitial();
}

final class DashboardOverviewLoading extends DashboardOverviewState {
  const DashboardOverviewLoading();
}

final class DashboardOverviewLoaded extends DashboardOverviewState {
  final DashboardOverview overview;

  const DashboardOverviewLoaded(this.overview);

  @override
  List<Object> get props => [overview];
}

final class DashboardOverviewFailure extends DashboardOverviewState {
  final Failure failure;

  const DashboardOverviewFailure(this.failure);

  @override
  List<Object> get props => [failure];
}
