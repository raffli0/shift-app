import 'package:shift/features/auth/models/user_model.dart';

class AuthService {
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    if (email == "admin@example.com" && password == "password123") {
      return UserModel(id: "1", fullName: "John Doe", email: email);
    } else {
      throw Exception("Invalid email or password");
    }
  }

  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    // For mock purposes, just return a new user
    return UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fullName: fullName,
      email: email,
    );
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
