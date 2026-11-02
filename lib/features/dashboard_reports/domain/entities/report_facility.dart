import 'package:equatable/equatable.dart';

/// A contracted facility, which gets a report every month.
class ReportFacility extends Equatable {
  /// The client's id.
  final String id;
  final String name;
  final String sector;

  /// The contract's span, e.g. "2026-03-01 ← 2027-02-28".
  final String contractPeriod;

  const ReportFacility({
    required this.id,
    required this.name,
    required this.sector,
    required this.contractPeriod,
  });

  @override
  List<Object> get props => [id, name, sector, contractPeriod];
}
