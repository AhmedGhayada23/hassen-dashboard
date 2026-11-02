import 'package:equatable/equatable.dart';

class Inspector extends Equatable {
  /// The inspector's account id (Firebase uid).
  final String id;
  final String name;

  const Inspector({required this.id, required this.name});

  @override
  List<Object> get props => [id, name];
}
