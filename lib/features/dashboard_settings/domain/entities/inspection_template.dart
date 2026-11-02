import 'package:equatable/equatable.dart';

/// An inspection checklist inspectors run on site.
class InspectionTemplate extends Equatable {
  final String name;

  /// e.g. `v2`.
  final String version;

  /// How many checklist items it has.
  final int items;

  const InspectionTemplate({
    required this.name,
    required this.version,
    required this.items,
  });

  @override
  List<Object> get props => [name, version, items];
}
