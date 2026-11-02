import 'package:equatable/equatable.dart';

/// Where a report is emailed: the facility's address, and an optional copy.
class ReportDelivery extends Equatable {
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// A plausible single email address.
  static bool isValidEmail(String value) => _email.hasMatch(value.trim());

  final String to;

  /// Empty for no copy.
  final String cc;

  const ReportDelivery({required this.to, this.cc = ''});

  bool get isValid =>
      isValidEmail(to) && (cc.trim().isEmpty || isValidEmail(cc));

  @override
  List<Object> get props => [to, cc];
}
