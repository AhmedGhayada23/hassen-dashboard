import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/monthly_report.dart';
import '../../domain/entities/report_delivery.dart';
import '../../domain/entities/report_month.dart';

sealed class DashboardReportsState extends Equatable {
  const DashboardReportsState();

  @override
  List<Object?> get props => [];
}

final class DashboardReportsInitial extends DashboardReportsState {
  const DashboardReportsInitial();
}

final class DashboardReportsLoading extends DashboardReportsState {
  const DashboardReportsLoading();
}

final class DashboardReportsFailure extends DashboardReportsState {
  final Failure failure;

  const DashboardReportsFailure(this.failure);

  @override
  List<Object?> get props => [failure];
}

final class DashboardReportsLoaded extends DashboardReportsState {
  final List<ReportMonth> months;
  final ReportMonth month;

  /// One per contracted facility, for [month].
  final List<MonthlyReport> reports;

  /// The report just sent and where to, for a one-off confirmation; cleared
  /// by the next change.
  final (MonthlyReport, ReportDelivery)? lastSent;

  /// Set when the last send failed; cleared by the next change.
  final Failure? actionFailure;

  const DashboardReportsLoaded({
    required this.months,
    required this.month,
    required this.reports,
    this.lastSent,
    this.actionFailure,
  });

  int get sentCount => reports.where((r) => r.isSent).length;

  @override
  List<Object?> get props => [months, month, reports, lastSent, actionFailure];
}
