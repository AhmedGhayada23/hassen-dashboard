import 'package:equatable/equatable.dart';

import 'deal_status.dart';

/// A client's quote and the decision on it: once accepted, the contract runs
/// from [startDate] for the plan picked ([planId]).
class Deal extends Equatable {
  /// The client's id; a deal is one per client.
  final String id;

  /// The quote number shown, e.g. `Q-2026-031`.
  final String number;
  final String client;

  /// When the quote was issued, as `yyyy-MM-dd`.
  final String date;
  final DealStatus status;

  /// The contract length chosen; null until one is picked.
  final String? planId;

  /// The day the contract starts; set on acceptance.
  final DateTime? startDate;

  const Deal({
    required this.id,
    required this.number,
    required this.client,
    required this.date,
    required this.status,
    this.planId,
    this.startDate,
  });

  bool get isPending => status == DealStatus.pending;

  bool get isAccepted => status == DealStatus.accepted;

  bool get isRejected => status == DealStatus.rejected;

  @override
  List<Object?> get props => [
    id,
    number,
    client,
    date,
    status,
    planId,
    startDate,
  ];
}
