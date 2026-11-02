import 'package:equatable/equatable.dart';

/// A client contract approaching its end date.
class ContractAlert extends Equatable {
  final String client;
  final DateTime endDate;
  final int daysRemaining;

  const ContractAlert({
    required this.client,
    required this.endDate,
    required this.daysRemaining,
  });

  @override
  List<Object> get props => [client, endDate, daysRemaining];
}
