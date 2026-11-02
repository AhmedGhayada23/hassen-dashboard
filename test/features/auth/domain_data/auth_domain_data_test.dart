import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/core/usecases/usecase.dart';
import 'package:hassen_dashboard/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:hassen_dashboard/features/auth/data/models/auth_user_model.dart';
import 'package:hassen_dashboard/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:hassen_dashboard/features/auth/domain/entities/auth_user.dart';
import 'package:hassen_dashboard/features/auth/domain/failures/auth_failures.dart';
import 'package:hassen_dashboard/features/auth/domain/usecases/get_signed_in_admin.dart';
import 'package:hassen_dashboard/features/auth/domain/usecases/sign_in.dart';

import '../helpers/fake_auth_repository.dart';

/// Data source stub: answers [user], or throws [error] when set.
class _FakeRemote implements AuthRemoteDataSource {
  Object? error;
  AuthUserModel? user;
  int signOuts = 0;

  @override
  Future<AuthUserModel> signIn({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    if (error case final e?) throw e;
    return user!;
  }

  @override
  Future<AuthUserModel?> currentUser() async {
    if (error case final e?) throw e;
    return user;
  }

  @override
  Future<void> signOut() async => signOuts++;
}

const _params = SignInParams(
  email: 'ahmedghayada123@gmail.com',
  password: '12345678',
  rememberMe: true,
);

void main() {
  group('AuthUser', () {
    test('only the "admin" role may use the dashboard', () {
      expect(adminUser.isAdmin, isTrue);
      expect(inspectorUser.isAdmin, isFalse);
      expect(AuthUser.adminRole, 'admin');
    });
  });

  group('SignIn', () {
    test('admits an admin', () async {
      final repository = FakeAuthRepository()..result = const Right(adminUser);

      final result = await SignIn(repository)(_params);

      expect(result, const Right<Failure, AuthUser>(adminUser));
      expect(repository.calls, [_params]);
      expect(repository.signOuts, 0);
    });

    test('refuses anyone else and signs them back out', () async {
      final repository = FakeAuthRepository()
        ..result = const Right(inspectorUser);

      final result = await SignIn(repository)(_params);

      expect(result, const Left<Failure, AuthUser>(AccessDeniedFailure()));
      expect(repository.signOuts, 1);
    });

    test('passes sign-in failures through', () async {
      final repository = FakeAuthRepository()
        ..result = const Left(InvalidCredentialsFailure());

      expect(
        await SignIn(repository)(_params),
        const Left<Failure, AuthUser>(InvalidCredentialsFailure()),
      );
      expect(repository.signOuts, 0);
    });
  });

  group('GetSignedInAdmin', () {
    test('returns a remembered admin', () async {
      final repository = FakeAuthRepository()..current = const Right(adminUser);

      expect(
        await GetSignedInAdmin(repository)(const NoParams()),
        const Right<Failure, AuthUser?>(adminUser),
      );
    });

    test('returns null when nobody is signed in', () async {
      expect(
        await GetSignedInAdmin(FakeAuthRepository())(const NoParams()),
        const Right<Failure, AuthUser?>(null),
      );
    });

    test('signs out a remembered non-admin and returns null', () async {
      final repository = FakeAuthRepository()
        ..current = const Right(inspectorUser);

      expect(
        await GetSignedInAdmin(repository)(const NoParams()),
        const Right<Failure, AuthUser?>(null),
      );
      expect(repository.signOuts, 1);
    });
  });

  group('AuthUserModel', () {
    test('reads the users document fields', () {
      final model = AuthUserModel.fromProfile(
        id: 'uid-1',
        accountEmail: 'ignored@haseen.ps',
        json: {
          'email': 'ahmedghayada123@gmail.com',
          'name': 'مدير العمليات',
          'role': 'admin',
        },
      );

      expect(model.toEntity(), adminUser.copyWithId('uid-1'));
    });

    test('missing fields fall back safely and never make an admin', () {
      final model = AuthUserModel.fromProfile(
        id: 'uid-2',
        accountEmail: 'someone@haseen.ps',
        json: const {},
      );

      expect(
        (model.email, model.name, model.role),
        ('someone@haseen.ps', '', ''),
      );
      expect(model.toEntity().isAdmin, isFalse);
    });

    test('a role with stray spaces still reads as admin', () {
      final model = AuthUserModel.fromProfile(
        id: 'uid-3',
        accountEmail: 'a@b.c',
        json: const {'role': ' admin '},
      );

      expect(model.toEntity().isAdmin, isTrue);
    });
  });

  group('AuthRepositoryImpl', () {
    late _FakeRemote remote;
    late AuthRepositoryImpl repository;

    setUp(() {
      remote = _FakeRemote();
      repository = AuthRepositoryImpl(remote);
    });

    Future<Failure> failureFor(Object error) async {
      remote.error = error;
      final result = await repository.signIn(
        email: 'a@b.c',
        password: '12345678',
        rememberMe: true,
      );
      return result.fold((f) => f, (_) => throw StateError('expected failure'));
    }

    test('maps the account and its profile to the entity', () async {
      remote.user = const AuthUserModel(
        id: 'uid-admin',
        email: 'ahmedghayada123@gmail.com',
        name: 'مدير العمليات',
        role: 'admin',
      );

      expect(
        await repository.signIn(
          email: 'a@b.c',
          password: '12345678',
          rememberMe: true,
        ),
        const Right<Failure, AuthUser>(adminUser),
      );
    });

    test('maps Firebase Authentication errors to domain failures', () async {
      for (final (code, expected) in [
        ('invalid-credential', const InvalidCredentialsFailure()),
        ('invalid-login-credentials', const InvalidCredentialsFailure()),
        ('wrong-password', const InvalidCredentialsFailure()),
        ('user-not-found', const InvalidCredentialsFailure()),
        ('invalid-email', const InvalidCredentialsFailure()),
        ('user-disabled', const UserDisabledFailure()),
        ('too-many-requests', const TooManyAttemptsFailure()),
        ('network-request-failed', const NetworkFailure()),
      ]) {
        expect(
          await failureFor(FirebaseAuthException(code: code)),
          expected,
          reason: code,
        );
      }
      expect(
        await failureFor(FirebaseAuthException(code: 'other', message: 'm')),
        const UnknownFailure(message: 'm'),
      );
    });

    test('maps database and profile errors', () async {
      expect(
        await failureFor(
          FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
        ),
        const NetworkFailure(),
      );
      expect(
        await failureFor(
          FirebaseException(
            plugin: 'cloud_firestore',
            code: 'permission-denied',
          ),
        ),
        isA<ProfileUnavailableFailure>(),
      );
      expect(
        await failureFor(AuthProfileNotFoundException()),
        const AccessDeniedFailure(),
      );
    });

    test('current user and sign-out go through the data source', () async {
      expect(
        await repository.getCurrentUser(),
        const Right<Failure, AuthUser?>(null),
      );
      expect(await repository.signOut(), const Right<Failure, Unit>(unit));
      expect(remote.signOuts, 1);
    });
  });
}

extension on AuthUser {
  AuthUser copyWithId(String id) =>
      AuthUser(id: id, email: email, displayName: displayName, role: role);
}
