import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shift/features/auth/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final UserCredential credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user == null) {
      throw Exception("Login failed");
    }

    // Fetch extra data from Firestore
    final doc = await _firestore
        .collection('users')
        .doc(credential.user!.uid)
        .get();

    if (!doc.exists) {
      // Create a default user if somehow missing in Firestore
      final newUser = UserModel(
        id: credential.user!.uid,
        fullName: credential.user!.displayName ?? "User",
        email: email,
        role: "user",
      );
      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(newUser.toJson());
      return newUser;
    }

    return UserModel.fromJson(doc.data()!);
  }

  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
    required String companyName,
  }) async {
    // 1. Create Auth Account
    final UserCredential credential = await _auth
        .createUserWithEmailAndPassword(email: email, password: password);

    if (credential.user == null) {
      throw Exception("Registration failed");
    }

    final uid = credential.user!.uid;

    // 2. Run Firestore Transaction to create Company and User profile
    return await _firestore.runTransaction((transaction) async {
      // Create NEW company
      final companyRef = _firestore.collection('companies').doc();
      transaction.set(companyRef, {
        'name': companyName,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      final companyId = companyRef.id;

      // Update Firebase Auth display name (optional but good)
      await credential.user!.updateDisplayName(fullName);

      final user = UserModel(
        id: uid,
        fullName: fullName,
        email: email,
        role: "admin",
        companyId: companyId,
      );

      // Create Admin User Profile linked to the new company
      final userRef = _firestore.collection('users').doc(uid);
      transaction.set(userRef, user.toJson());

      return user;
    });
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<UserModel> updateProfile({
    required String fullName,
    required String email,
    String? phone,
    String? department,
    String? manager,
    String? companyName,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not authenticated");

    // Fetch current user data to get companyId
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data();
    final companyId = userData?['company_id'];

    await user.updateDisplayName(fullName);

    // Update Firestore User
    final Map<String, dynamic> updateData = {
      'full_name': fullName,
      'email': email,
    };
    if (phone != null) updateData['phone'] = phone;
    if (department != null) updateData['department'] = department;
    if (manager != null) updateData['manager'] = manager;

    await _firestore.collection('users').doc(user.uid).update(updateData);

    // Update Company Name if provided and user is admin
    if (companyName != null && companyName.isNotEmpty && companyId != null) {
      await _firestore.collection('companies').doc(companyId).update({
        'name': companyName,
        'updated_at': FieldValue.serverTimestamp(),
      });
    }

    // Fetch updated user
    final doc = await _firestore.collection('users').doc(user.uid).get();
    return UserModel.fromJson(doc.data()!);
  }

  Future<String?> getCompanyName(String companyId) async {
    final doc = await _firestore.collection('companies').doc(companyId).get();
    if (doc.exists) {
      return doc.data()?['name'] as String?;
    }
    return null;
  }

  // --- Admin Features ---

  Future<void> createEmployeeProfile(UserModel user) async {
    // Create a placeholder document.
    // Since we don't have a UID yet (user hasn't registered),
    // we use a random ID or email as key?
    // Better: Auto-generate ID. Logic in register() handles matching by email.

    await _firestore.collection('users').add({
      'full_name': user.fullName,
      'email': user.email,
      'role': 'employee',
      'id': '', // Placeholder ID
    });
  }

  Future<void> updateUser(UserModel user) async {
    // This is for Admin editing OTHER users.
    // If the user has a proper UID, update that doc.
    // If it's a placeholder (no auth yet), we need its doc ID.
    // For simplicity in this plan, we assume we have the Firestore Doc ID if possible,
    // but UserModel 'id' field maps to UID.

    // If the user was fetched from Firestore, u.id should be the doc ID (either UID or random).
    await _firestore.collection('users').doc(user.id).update(user.toJson());
  }

  Future<void> deleteUser(String uid) async {
    // Deletes the user document.
    // Note: We cannot delete the Auth account easily without Admin SDK backend.
    // We only clean up the Firestore record.
    await _firestore.collection('users').doc(uid).delete();
  }

  Future<UserModel?> checkAuthStatus() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!);
      }
    }
    return null;
  }

  Future<List<UserModel>> getAllUsers() async {
    final snapshot = await _firestore.collection('users').get();
    return snapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
  }
}
