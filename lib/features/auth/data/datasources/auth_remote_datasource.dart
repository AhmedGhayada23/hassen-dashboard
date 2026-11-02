import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/auth_user_model.dart';

/// Signs in against the authentication service and reads the account's
/// profile. Throws the service's own exceptions (mapped by the repository)
/// and [AuthProfileNotFoundException].
abstract interface class AuthRemoteDataSource {
  Future<AuthUserModel> signIn({
    required String email,
    required String password,
    required bool rememberMe,
  });

  /// Null when nobody is signed in on this device.
  Future<AuthUserModel?> currentUser();

  Future<void> signOut();
}

/// Firebase Authentication for the account, Firestore `users` for the
/// profile: the document whose id is the account uid, or else the one whose
/// `email` matches the account.
class FirebaseAuthDataSource implements AuthRemoteDataSource {
  static const usersCollection = 'users';

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseAuthDataSource(this._auth, this._firestore);

  @override
  Future<AuthUserModel> signIn({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    // "Remember me" decides whether the browser keeps the session after the
    // tab closes; desktop and mobile always keep it.
    if (kIsWeb) {
      await _auth.setPersistence(
        rememberMe ? Persistence.LOCAL : Persistence.SESSION,
      );
    }
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _profileOrSignOut(credential.user!);
  }

  @override
  Future<AuthUserModel?> currentUser() async {
    // The first event arrives once a remembered session has been restored.
    final user = await _auth.authStateChanges().first;
    return user == null ? null : _profileOrSignOut(user);
  }

  @override
  Future<void> signOut() => _auth.signOut();

  /// Never leaves an account signed in without a readable profile.
  Future<AuthUserModel> _profileOrSignOut(User user) async {
    try {
      return await _profile(user);
    } catch (_) {
      await _auth.signOut();
      rethrow;
    }
  }

  Future<AuthUserModel> _profile(User user) async {
    final users = _firestore.collection(usersCollection);
    var data = (await users.doc(user.uid).get()).data();
    if (data == null && user.email != null) {
      final matches = await users
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();
      data = matches.docs.firstOrNull?.data();
    }
    if (data == null) throw AuthProfileNotFoundException();
    return AuthUserModel.fromProfile(
      id: user.uid,
      accountEmail: user.email ?? '',
      json: data,
    );
  }
}

/// The account has no document in the `users` collection.
class AuthProfileNotFoundException extends AppException {
  AuthProfileNotFoundException()
    : super(message: 'No profile in the users collection for this account.');
}
