/// Risk band for a likelihood × severity score (1–25).
enum RiskLevel {
  critical,
  high,
  medium,
  low;

  /// 15–25 critical · 10–14 high · 5–9 medium · 1–4 low.
  static RiskLevel fromScore(int score) => switch (score) {
    >= 15 => RiskLevel.critical,
    >= 10 => RiskLevel.high,
    >= 5 => RiskLevel.medium,
    _ => RiskLevel.low,
  };
}
