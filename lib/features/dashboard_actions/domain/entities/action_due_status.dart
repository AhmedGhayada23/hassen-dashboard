/// Deadline standing of an action, independent of its workflow [ActionStatus].
enum ActionDueStatus {
  late,
  soon,
  ok,
  done;

  /// Overdue or close to it — what the red sidebar counter tracks.
  bool get needsAttention => this == late || this == soon;
}
