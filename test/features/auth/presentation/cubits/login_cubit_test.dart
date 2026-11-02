import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/features/auth/domain/failures/auth_failures.dart';
import 'package:hassen_dashboard/features/auth/domain/usecases/sign_in.dart';
import 'package:hassen_dashboard/features/auth/presentation/config/login_messages.dart';
import 'package:hassen_dashboard/features/auth/presentation/cubits/login_cubit.dart';
import 'package:hassen_dashboard/features/auth/presentation/cubits/login_state.dart';

import '../../helpers/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repository;
  late LoginCubit cubit;

  setUp(() {
    repository = FakeAuthRepository();
    cubit = LoginCubit(SignIn(repository));
  });
  tearDown(() => cubit.close());

  test('starts idle with the password hidden and "remember me" on', () {
    expect(cubit.state, const LoginState());
    expect(
      (cubit.state.status, cubit.state.obscurePassword, cubit.state.rememberMe),
      (LoginStatus.idle, true, true),
    );
  });

  test('toggles password visibility and remember-me', () {
    cubit.togglePasswordVisibility();
    expect(cubit.state.obscurePassword, isFalse);
    cubit.togglePasswordVisibility();
    expect(cubit.state.obscurePassword, isTrue);

    cubit.setRememberMe(false);
    expect(cubit.state.rememberMe, isFalse);
  });

  test('a failed sign-in goes through loading and keeps the failure', () async {
    repository.gate = Completer<void>();
    final pending = cubit.signIn(
      email: '  name@haseen.ps ',
      password: '12345678',
    );
    expect(cubit.state.isSubmitting, isTrue);
    repository.gate!.complete();
    await pending;

    expect(cubit.state.status, LoginStatus.failure);
    expect(cubit.state.failure, const UnknownFailure());
    expect(repository.calls, [
      const SignInParams(
        email: 'name@haseen.ps',
        password: '12345678',
        rememberMe: true,
      ),
    ]);
  });

  test('passes the current remember-me choice', () async {
    cubit.setRememberMe(false);
    await cubit.signIn(email: 'name@haseen.ps', password: '12345678');

    expect(repository.calls.single.rememberMe, isFalse);
  });

  test('ignores a second request while one is in flight', () async {
    repository.gate = Completer<void>();
    final first = cubit.signIn(email: 'name@haseen.ps', password: '12345678');
    await cubit.signIn(email: 'name@haseen.ps', password: '12345678');
    repository.gate!.complete();
    await first;

    expect(repository.calls, hasLength(1));
  });

  test(
    'never calls the use case with input that breaks the form rules',
    () async {
      await cubit.signIn(email: '', password: '12345678');
      await cubit.signIn(email: 'bad', password: '12345678');
      await cubit.signIn(email: 'name@haseen.ps', password: 'short');

      expect(repository.calls, isEmpty);
      expect(cubit.state, const LoginState());
    },
  );

  test('clearFailure hides the last error and keeps the toggles', () async {
    cubit.togglePasswordVisibility();
    await cubit.signIn(email: 'name@haseen.ps', password: '12345678');

    cubit.clearFailure();

    expect(cubit.state, const LoginState(obscurePassword: false));
  });

  test('a successful sign-in exposes the user', () async {
    repository.result = const Right(adminUser);

    await cubit.signIn(email: 'name@haseen.ps', password: '12345678');

    expect(
      (cubit.state.status, cubit.state.user, cubit.state.failure),
      (LoginStatus.success, adminUser, null),
    );
  });

  test('closing mid-request does not emit afterwards', () async {
    repository.gate = Completer<void>();
    final pending = cubit.signIn(email: 'name@haseen.ps', password: '12345678');
    await cubit.close();
    repository.gate!.complete();

    await expectLater(pending, completes);
  });

  test(
    'each failure maps to its Arabic message; others to the generic one',
    () {
      expect(
        {
          for (final f in const <Failure>[
            InvalidCredentialsFailure(),
            AccessDeniedFailure(),
            UserDisabledFailure(),
            TooManyAttemptsFailure(),
            NetworkFailure(),
            ProfileUnavailableFailure(),
            UnknownFailure(),
          ])
            f.runtimeType: LoginMessages.forFailure(f),
        },
        {
          InvalidCredentialsFailure:
              'البريد الإلكتروني أو كلمة المرور غير صحيحة.',
          AccessDeniedFailure:
              'هذا الحساب لا يملك صلاحية الدخول إلى لوحة التحكم.',
          UserDisabledFailure: 'تم تعطيل هذا الحساب. تواصل مع مدير النظام.',
          TooManyAttemptsFailure:
              'محاولات كثيرة متتالية. انتظر قليلاً ثم حاول مرة أخرى.',
          NetworkFailure:
              'تعذّر الاتصال بالخادم. تحقق من الإنترنت وحاول مرة أخرى.',
          ProfileUnavailableFailure:
              'تعذّر التحقق من صلاحيات الحساب. حاول مرة أخرى.',
          UnknownFailure: 'تعذّر تسجيل الدخول. حاول مرة أخرى.',
        },
      );
    },
  );
}
