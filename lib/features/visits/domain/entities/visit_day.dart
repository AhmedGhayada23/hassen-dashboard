import 'package:equatable/equatable.dart';

/// A column of the weekly schedule; [order] is its position in the week and
/// [date] the calendar day it stands for, as `yyyy-MM-dd`.
class VisitDay extends Equatable {
  final int order;
  final String label;
  final String date;

  const VisitDay({
    required this.order,
    required this.label,
    required this.date,
  });

  @override
  List<Object> get props => [order, label, date];
}
