import 'package:equatable/equatable.dart';

/// How a KPI should be read: neutral, needs attention, or problematic.
enum KpiTone { neutral, warning, danger }

class DashboardKpi extends Equatable {
  final String label;
  final int value;
  final String subtitle;
  final KpiTone tone;

  const DashboardKpi({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.tone,
  });

  @override
  List<Object> get props => [label, value, subtitle, tone];
}
