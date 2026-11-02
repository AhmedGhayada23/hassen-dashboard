import 'package:equatable/equatable.dart';

import 'risk.dart';
import 'risk_level.dart';

/// One likelihood × severity cell and how many risks fall in it.
class RiskMatrixCell extends Equatable {
  final int likelihood;
  final int severity;
  final int count;

  const RiskMatrixCell({
    required this.likelihood,
    required this.severity,
    required this.count,
  });

  int get score => likelihood * severity;

  RiskLevel get level => RiskLevel.fromScore(score);

  bool get isEmpty => count == 0;

  @override
  List<Object> get props => [likelihood, severity, count];
}

/// 5 × 5 heat map of risk counts, in display order: likelihood 5 → 1 top to
/// bottom, severity 1 → 5 left to right.
class RiskMatrix extends Equatable {
  final List<List<RiskMatrixCell>> rows;

  const RiskMatrix(this.rows);

  factory RiskMatrix.fromRisks(List<Risk> risks) {
    final counts = <(int, int), int>{};
    for (final r in risks) {
      counts.update(
        (r.likelihood, r.severity),
        (n) => n + 1,
        ifAbsent: () => 1,
      );
    }
    return RiskMatrix([
      for (
        var likelihood = Risk.maxRating;
        likelihood >= Risk.minRating;
        likelihood--
      )
        [
          for (
            var severity = Risk.minRating;
            severity <= Risk.maxRating;
            severity++
          )
            RiskMatrixCell(
              likelihood: likelihood,
              severity: severity,
              count: counts[(likelihood, severity)] ?? 0,
            ),
        ],
    ]);
  }

  int countAt({required int likelihood, required int severity}) => rows
      .expand((row) => row)
      .firstWhere((c) => c.likelihood == likelihood && c.severity == severity)
      .count;

  int get total => rows.expand((row) => row).fold(0, (sum, c) => sum + c.count);

  @override
  List<Object> get props => [rows];
}
