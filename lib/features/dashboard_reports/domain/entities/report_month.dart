import 'package:equatable/equatable.dart';

/// A month reports are issued for.
class ReportMonth extends Equatable {
  /// As `yyyy-MM`.
  final String id;
  final String label;

  const ReportMonth({required this.id, required this.label});

  @override
  List<Object> get props => [id, label];
}
