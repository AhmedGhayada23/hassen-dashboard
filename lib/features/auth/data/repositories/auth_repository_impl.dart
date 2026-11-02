import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/failures/auth_failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  const AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, AuthUser>> signIn({
    required String email,
    required String password,
    required bool rememberMe,
  }) => _guard(
    () async => (await remoteDataSource.signIn(
      email: email,
      password: password,
      rememberMe: rememberMe,
    )).toEntity(),
  );

  @override
  Future<Either<Failure, AuthUser?>> getCurrentUser() =>
      _guard(() async => (await remoteDataSource.currentUser())?.toEntity());

  @override
  Future<Either<Failure, Unit>> signOut() => _guard(() async {
    await remoteDataSource.signOut();
    return unit;
  });

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Right(await run());
    } on FirebaseAuthException catch (e) {
      return Left(_authFailure(e));
    } on FirebaseException catch (e) {
      return Left(_profileFailure(e));
    } on AuthProfileNotFoundException {
      return const Left(AccessDeniedFailure());
    } on AppException catch (e) {
      return Left(UnknownFailure(message: e.message));
    }
  }

  static Failure _authFailure(FirebaseAuthException e) => switch (e.code) {
    'invalid-credential' ||
    'invalid-login-credentials' ||
    'wrong-password' ||
    'user-not-found' ||
    'invalid-email' => const InvalidCredentialsFailure(),
    'user-disabled' => const UserDisabledFailure(),
    'too-many-requests' => const TooManyAttemptsFailure(),
    'network-request-failed' => const NetworkFailure(),
    _ => UnknownFailure(message: e.message ?? e.code),
  };

  /// Errors reading the `users` profile from the database.
  static Failure _profileFailure(FirebaseException e) => switch (e.code) {
    'unavailable' => const NetworkFailure(),
    _ => ProfileUnavailableFailure(message: e.message ?? e.code),
  };
}
