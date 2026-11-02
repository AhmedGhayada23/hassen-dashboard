import 'package:equatable/equatable.dart';

/// An inspector a new client can be assigned to, with this week's visits.
class InspectorLoad extends Equatable {
  final String name;
  final int weeklyVisits;

  const InspectorLoad({required this.name, required this.weeklyVisits});

  @override
  List<Object> get props => [name, weeklyVisits];
}

/// What the "new client" form offers: sectors and inspectors.
class ClientRegistrationOptions extends Equatable {
  final List<String> sectors;
  final List<InspectorLoad> inspectors;

  const ClientRegistrationOptions({
    required this.sectors,
    required this.inspectors,
  });

  /// The inspector with the fewest visits this week; the first wins a tie.
  /// Null when there are no inspectors.
  InspectorLoad? get suggestedInspector => inspectors.isEmpty
      ? null
      : inspectors.reduce(
          (best, i) => i.weeklyVisits < best.weeklyVisits ? i : best,
        );

  @override
  List<Object> get props => [sectors, inspectors];
}
