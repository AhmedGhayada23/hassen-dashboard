import '../../domain/entities/team_member.dart';

/// An employee as stored in the Firestore `users` collection, keyed by
/// account uid.
class TeamMemberModel {
  final String id;
  final String name;
  final String role;
  final int facilities;
  final int monthlyVisits;
  final int lateVisits;
  final int workload;
  final bool pendingActivation;
  final String? temporaryPassword;

  const TeamMemberModel({
    required this.id,
    required this.name,
    required this.role,
    required this.facilities,
    required this.monthlyVisits,
    required this.lateVisits,
    required this.workload,
    this.pendingActivation = false,
    this.temporaryPassword,
  });

  /// Shows `role_name` (falling back to the `role` code). The figures
  /// (`facilities`, `monthly_visits`, `late_visits`, `workload`) are optional:
  /// missing ones read as 0, and values typed out of range are clamped
  /// (counts to ≥ 0, workload to 0–100) so one bad document never breaks
  /// the page.
  factory TeamMemberModel.fromUserDocument(
    String uid,
    Map<String, Object?> json,
  ) {
    int count(String key) {
      final value = (json[key] as num?)?.toInt() ?? 0;
      return value < 0 ? 0 : value;
    }

    return TeamMemberModel(
      id: uid,
      name: json['name'] as String? ?? '',
      role: json['role_name'] as String? ?? json['role'] as String? ?? '',
      facilities: count('facilities'),
      monthlyVisits: count('monthly_visits'),
      lateVisits: count('late_visits'),
      workload: count('workload').clamp(0, 100),
      pendingActivation: json['pending_activation'] as bool? ?? false,
      temporaryPassword: json['temporary_password'] as String?,
    );
  }

  TeamMember toEntity() => TeamMember(
    id: id,
    name: name,
    role: role,
    facilities: facilities,
    monthlyVisits: monthlyVisits,
    lateVisits: lateVisits,
    workload: workload,
    isPendingActivation: pendingActivation,
    temporaryPassword: temporaryPassword,
  );
}
