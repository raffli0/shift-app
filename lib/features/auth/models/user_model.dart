class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final String? phone;
  final String? department;
  final String? employeeId;
  final String? manager;
  final String? companyId;
  final String? shiftStart;
  final String? shiftEnd;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.role = 'admin',
    this.phone,
    this.department,
    this.employeeId,
    this.manager,
    this.companyId,
    this.shiftStart,
    this.shiftEnd,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? 'Unknown User',
      email: json['email'] ?? '',
      role: json['role'] ?? 'admin',
      phone: json['phone'],
      department: json['department'],
      employeeId: json['employee_id'],
      manager: json['manager'],
      companyId: json['company_id'],
      shiftStart: json['shift_start'],
      shiftEnd: json['shift_end'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'role': role,
      'phone': phone,
      'department': department,
      'employee_id': employeeId,
      'manager': manager,
      'company_id': companyId,
      'shift_start': shiftStart,
      'shift_end': shiftEnd,
    };
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? role,
    String? phone,
    String? department,
    String? employeeId,
    String? manager,
    String? companyId,
    String? shiftStart,
    String? shiftEnd,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      employeeId: employeeId ?? this.employeeId,
      manager: manager ?? this.manager,
      companyId: companyId ?? this.companyId,
      shiftStart: shiftStart ?? this.shiftStart,
      shiftEnd: shiftEnd ?? this.shiftEnd,
    );
  }
}
