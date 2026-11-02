/// Workflow stage of a corrective action (one Kanban column each).
enum ActionStatus {
  /// Raised and waiting on the facility.
  open,
  inProgress,

  /// Evidence uploaded; waiting for HASEEN to approve closure.
  pendingClosure,
  closed,
}
