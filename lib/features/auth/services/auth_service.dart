import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shift/features/auth/models/user_model.dart';

class AuthService {
  static const String _userKey = 'user_session';

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    UserModel? user;
    if (email == "admin@example.com" && password == "password123") {
      user = UserModel(
        id: "1",
        fullName: "Admin User",
        email: email,
        role: "admin",
      );
    } else if (email == "user@example.com" && password == "password123") {
      user = UserModel(
        id: "2",
        fullName: "Regular User",
        email: email,
        role: "user",
      );
    } else {
      throw Exception("Invalid email or password");
    }

    // Persist user session
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));

    return user;
  }

  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    // For mock purposes, just return a new user
    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fullName: fullName,
      email: email,
    );
    // Persist user session
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));

    return user;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  Future<UserModel> updateProfile({
    required String fullName,
    required String email,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);

    if (userJson != null) {
      final currentUser = UserModel.fromJson(jsonDecode(userJson));
      final updatedUser = currentUser.copyWith(
        fullName: fullName,
        email: email,
      );

      await prefs.setString(_userKey, jsonEncode(updatedUser.toJson()));
      return updatedUser;
    } else {
      throw Exception("User not found");
    }
  }

  Future<UserModel?> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      try {
        return UserModel.fromJson(jsonDecode(userJson));
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
