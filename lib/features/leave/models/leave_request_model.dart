import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveRequestModel {
  final String id;
  final String userId;
  final String userName;
  final String userImageUrl;
  final String companyId;
  final String type;
  final String reason;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final DateTime createdAt;
  final String? adminNote;
  final DateTime? updatedAt;

  LeaveRequestModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userImageUrl,
    this.companyId =
        'default_company', // Default for now since UserModel lacks it
    required this.type,
    required this.reason,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.createdAt,
    this.adminNote,
    this.updatedAt,
  });

  factory LeaveRequestModel.fromMap(Map<String, dynamic> map, String id) {
    return LeaveRequestModel(
      id: id,
      userId: map['user_id'] ?? '',
      userName: map['user_name'] ?? 'Unknown',
      userImageUrl: map['user_image_url'] ?? '',
      companyId: map['company_id'] ?? 'default_company',
      type: map['type'] ?? 'General',
      reason: map['reason'] ?? '',
      startDate: (map['start_date'] as Timestamp).toDate(),
      endDate: (map['end_date'] as Timestamp).toDate(),
      status: map['status'] ?? 'pending',
      createdAt: (map['created_at'] as Timestamp).toDate(),
      adminNote: map['admin_note'],
      updatedAt: map['updated_at'] != null
          ? (map['updated_at'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'user_name': userName,
      'user_image_url': userImageUrl,
      'company_id': companyId,
      'type': type,
      'reason': reason,
      'start_date': Timestamp.fromDate(startDate),
      'end_date': Timestamp.fromDate(endDate),
      'status': status,
      'created_at': Timestamp.fromDate(createdAt),
      'admin_note': adminNote,
      'updated_at': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}
