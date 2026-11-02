import 'package:equatable/equatable.dart';

/// An inspection checklist the inspector runs on site.
class InspectionTemplate extends Equatable {
  final String name;
  final int itemCount;

  const InspectionTemplate({required this.name, required this.itemCount});

  @override
  List<Object> get props => [name, itemCount];
}
