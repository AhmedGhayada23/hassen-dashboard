import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/auth_user.dart';

enum LoginStatus { idle, submitting, success, failure }

class LoginState extends Equatable {
  final LoginStatus status;
  final bool obscurePassword;
  final bool rememberMe;

  /// Set only while [status] is [LoginStatus.failure].
  final Failure? failure;

  /// Set only while [status] is [LoginStatus.success].
  final AuthUser? user;

  const LoginState({
    this.status = LoginStatus.idle,
    this.obscurePassword = true,
    this.rememberMe = true,
    this.failure,
    this.user,
  });

  bool get isSubmitting => status == LoginStatus.submitting;

  LoginState copyWith({bool? obscurePassword, bool? rememberMe}) => LoginState(
    status: status,
    obscurePassword: obscurePassword ?? this.obscurePassword,
    rememberMe: rememberMe ?? this.rememberMe,
    failure: failure,
    user: user,
  );

  /// Moves to [status], dropping the previous outcome.
  LoginState withStatus(
    LoginStatus status, {
    Failure? failure,
    AuthUser? user,
  }) => LoginState(
    status: status,
    obscurePassword: obscurePassword,
    rememberMe: rememberMe,
    failure: failure,
    user: user,
  );

  @override
  List<Object?> get props => [
    status,
    obscurePassword,
    rememberMe,
    failure,
    user,
  ];
}
