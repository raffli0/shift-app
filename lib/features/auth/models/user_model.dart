class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String role;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.role = 'user',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullName: json['full_name'],
      email: json['email'],
      role: json['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'full_name': fullName, 'email': email, 'role': role};
  }
}
