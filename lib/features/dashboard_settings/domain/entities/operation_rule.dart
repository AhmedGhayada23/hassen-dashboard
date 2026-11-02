import 'package:equatable/equatable.dart';

/// An operating rule and its current setting, e.g. a deadline.
class OperationRule extends Equatable {
  final String title;
  final String value;

  const OperationRule({required this.title, required this.value});

  @override
  List<Object> get props => [title, value];
}
