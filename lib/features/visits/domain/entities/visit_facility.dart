import 'package:equatable/equatable.dart';

/// A client site a visit can be booked at.
class VisitFacility extends Equatable {
  final String name;

  /// Under contract; otherwise only a pre-contract assessment makes sense.
  final bool isContracted;

  /// The client's sector, which picks its inspection template.
  final String sector;

  const VisitFacility({
    required this.name,
    required this.isContracted,
    this.sector = '',
  });

  @override
  List<Object> get props => [name, isContracted, sector];
}
