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
  }) async {
    // Check if user already exists in Firestore (Employee Placeholder)
    final existingUserQuery = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    final UserCredential credential = await _auth
        .createUserWithEmailAndPassword(email: email, password: password);

    if (credential.user == null) {
      throw Exception("Registration failed");
    }

    // Update display name
    await credential.user!.updateDisplayName(fullName);

    String role = "admin"; // Default for new sign-ups is Admin (Company)

    // Profile Linking Logic
    if (existingUserQuery.docs.isNotEmpty) {
      // Employee account pre-created by Admin found!
      final existingDoc = existingUserQuery.docs.first;
      final existingData = existingDoc.data();

      role = existingData['role'] ?? "employee"; // Preserve employee role

      // Delete the placeholder doc (since it has no valid UID yet)
      // or we can update it? Key issue: Doc ID needs to match Auth UID.
      // Strategy: Delete old placeholder, create NEW doc with correct UID.
      await _firestore.collection('users').doc(existingDoc.id).delete();
    }

    final user = UserModel(
      id: credential.user!.uid,
      fullName: fullName,
      email: email,
      role: role,
    );

    // Save to Firestore with correct UID
    await _firestore
        .collection('users')
        .doc(credential.user!.uid)
        .set(user.toJson());

    return user;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<UserModel> updateProfile({
    required String fullName,
    required String email,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not authenticated");

    // Note: Updating email in Firebase Auth requires re-auth usually,
    // keeping it simple for now.
    if (user.email != email) {
      // await user.verifyBeforeUpdateEmail(email);
      // We'll skip complex email update flows for this step to focus on data.
    }
    await user.updateDisplayName(fullName);

    // Update Firestore
    await _firestore.collection('users').doc(user.uid).update({
      'full_name': fullName,
      'email': email,
    });

    // Fetch updated user
    final doc = await _firestore.collection('users').doc(user.uid).get();
    return UserModel.fromJson(doc.data()!);
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
      if (doc.exists) {
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
