import 'package:equatable/equatable.dart';

/// An open risk rated critical on the risk matrix.
class CriticalRisk extends Equatable {
  final int score;
  final String title;
  final String facility;
  final String owner;

  const CriticalRisk({
    required this.score,
    required this.title,
    required this.facility,
    required this.owner,
  });

  @override
  List<Object> get props => [score, title, facility, owner];
}
