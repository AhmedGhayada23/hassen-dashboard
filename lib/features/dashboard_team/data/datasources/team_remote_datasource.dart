import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/employee_role_model.dart';
import '../models/team_member_model.dart';

/// Employees kept in the authentication service and the `users` collection,
/// and the roles they can get from the `roles` collection. Throws the
/// services' own exceptions; the repository maps them.
abstract interface class TeamRemoteDataSource {
  /// Every non-admin account in `users`, oldest first.
  Future<List<TeamMemberModel>> getEmployees();

  /// Every role in `roles`, by `order`; never one with the admin code.
  Future<List<EmployeeRoleModel>> getEmployeeRoles();

  /// Creates the account and stores its `users` profile; returns the member.
  Future<TeamMemberModel> addEmployee({
    required String name,
    required String email,
    required String phone,
    required String roleId,
    required String roleName,
    required String temporaryPassword,
  });
}

class FirebaseTeamDataSource implements TeamRemoteDataSource {
  static const usersCollection = 'users';
  static const rolesCollection = 'roles';
  static const adminRole = 'admin';

  /// A second Firebase app used only to create accounts: creating one signs
  /// that app in as the new user, which must not sign the admin out of the
  /// dashboard's own app.
  static const provisioningAppName = 'employee-provisioning';

  final FirebaseFirestore _firestore;

  FirebaseTeamDataSource(this._firestore);

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(usersCollection);

  @override
  Future<List<TeamMemberModel>> getEmployees() async {
    final snapshot = await _users.get();
    final employees =
        snapshot.docs.where((doc) => doc.data()['role'] != adminRole).toList()
          ..sort((a, b) => _createdAt(a).compareTo(_createdAt(b)));
    return [
      for (final doc in employees)
        TeamMemberModel.fromUserDocument(doc.id, doc.data()),
    ];
  }

  @override
  Future<List<EmployeeRoleModel>> getEmployeeRoles() async {
    final snapshot = await _firestore.collection(rolesCollection).get();
    return [
      for (final doc in snapshot.docs)
        // A role coded "admin" would let an employee open the dashboard.
        if (doc.id != adminRole)
          EmployeeRoleModel.fromDocument(doc.id, doc.data()),
    ]..sort((a, b) => a.order.compareTo(b.order));
  }

  @override
  Future<TeamMemberModel> addEmployee({
    required String name,
    required String email,
    required String phone,
    required String roleId,
    required String roleName,
    required String temporaryPassword,
  }) async {
    final auth = FirebaseAuth.instanceFor(app: await _provisioningApp());
    final credential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: temporaryPassword,
    );
    final account = credential.user!;
    final profile = <String, Object?>{
      'name': name,
      'email': email,
      'phone': phone,
      'role': roleId,
      'role_name': roleName,
      'pending_activation': true,
      'temporary_password': temporaryPassword,
      'created_at': FieldValue.serverTimestamp(),
    };
    try {
      // Written as the admin (the dashboard's own app), not as the new user.
      await _users.doc(account.uid).set(profile);
    } catch (_) {
      // No account without a profile: undo the half-made employee.
      await account.delete();
      rethrow;
    } finally {
      await auth.signOut();
    }
    return TeamMemberModel.fromUserDocument(account.uid, profile);
  }

  static Future<FirebaseApp> _provisioningApp() async {
    for (final app in Firebase.apps) {
      if (app.name == provisioningAppName) return app;
    }
    return Firebase.initializeApp(
      name: provisioningAppName,
      options: Firebase.app().options,
    );
  }

  /// Creation time in ms; documents without one yet (just written) sort last.
  static int _createdAt(QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
      (doc.data()['created_at'] as Timestamp?)?.millisecondsSinceEpoch ??
      double.maxFinite.toInt();
}
