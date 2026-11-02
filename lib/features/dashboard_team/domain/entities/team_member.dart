import 'package:equatable/equatable.dart';

/// A HASEEN staff member and their current workload.
class TeamMember extends Equatable {
  /// Workload strictly above this percentage counts as overloaded.
  static const overloadThreshold = 80;

  /// Engineer title stripped before taking the avatar initial.
  static const engineerPrefix = 'م. ';

  static bool isValidCount(int value) => value >= 0;

  static bool isValidWorkload(int percent) => percent >= 0 && percent <= 100;

  /// Stable key, independent of list position.
  final String id;
  final String name;
  final String role;
  final int facilities;
  final int monthlyVisits;
  final int lateVisits;

  /// Share of capacity in use, 0–100.
  final int workload;

  /// Invited but has not signed in yet.
  final bool isPendingActivation;

  /// The password the account was created with, kept so the admin can hand
  /// it to the employee; null for members created elsewhere.
  final String? temporaryPassword;

  const TeamMember({
    required this.id,
    required this.name,
    required this.role,
    required this.facilities,
    required this.monthlyVisits,
    required this.lateVisits,
    required this.workload,
    this.isPendingActivation = false,
    this.temporaryPassword,
  }) : assert(facilities >= 0, 'facilities cannot be negative'),
       assert(monthlyVisits >= 0, 'visits cannot be negative'),
       assert(lateVisits >= 0, 'late visits cannot be negative'),
       assert(workload >= 0 && workload <= 100, 'workload must be 0–100');

  /// First letter of the name without the engineer title (single code point:
  /// Arabic letters are never composed, so no grapheme package is needed).
  String get initial {
    final bare = name.startsWith(engineerPrefix)
        ? name.substring(engineerPrefix.length)
        : name;
    return bare.isEmpty ? '' : String.fromCharCode(bare.runes.first);
  }

  bool get isOverloaded => workload > overloadThreshold;

  bool get hasLateVisits => lateVisits > 0;

  @override
  List<Object?> get props => [
    id,
    name,
    role,
    facilities,
    monthlyVisits,
    lateVisits,
    workload,
    isPendingActivation,
    temporaryPassword,
  ];
}
