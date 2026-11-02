import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/sign_in.dart';
import '../validation/login_validator.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final SignIn _signIn;

  LoginCubit(this._signIn) : super(const LoginState());

  void togglePasswordVisibility() =>
      emit(state.copyWith(obscurePassword: !state.obscurePassword));

  void setRememberMe(bool value) => emit(state.copyWith(rememberMe: value));

  /// Hides the last error, as the original did at the start of every submit.
  void clearFailure() {
    if (state.status == LoginStatus.failure) {
      emit(state.withStatus(LoginStatus.idle));
    }
  }

  /// Ignored while a request is in flight or when the input breaks the form
  /// rules, so the use case only ever sees one valid request at a time.
  Future<void> signIn({required String email, required String password}) async {
    if (state.isSubmitting) return;
    if (!LoginValidator.isValid(email: email, password: password)) return;
    emit(state.withStatus(LoginStatus.submitting));

    final result = await _signIn(
      SignInParams(
        email: email.trim(),
        password: password,
        rememberMe: state.rememberMe,
      ),
    );
    if (isClosed) return;
    emit(
      result.fold(
        (failure) => state.withStatus(LoginStatus.failure, failure: failure),
        (user) => state.withStatus(LoginStatus.success, user: user),
      ),
    );
  }
}
