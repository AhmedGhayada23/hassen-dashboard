import 'package:equatable/equatable.dart';

/// A contract length a client can sign up for.
class ContractPlan extends Equatable {
  final String id;
  final String name;
  final int months;

  const ContractPlan({
    required this.id,
    required this.name,
    required this.months,
  });

  /// The last day covered when the contract starts on [start]: the day before
  /// the same date [months] later.
  DateTime endFor(DateTime start) => DateTime(
    start.year,
    start.month + months,
    start.day,
  ).subtract(const Duration(days: 1));

  @override
  List<Object> get props => [id, name, months];
}
