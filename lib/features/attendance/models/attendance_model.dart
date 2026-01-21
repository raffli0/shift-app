import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final String id;
  final String userId;
  final String userName;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final String checkInLocation;
  final String? checkOutLocation;
  final String checkInImageUrl;
  final String? checkOutImageUrl;
  final String? companyId;
  final String status; // On Time, Late, etc.
  final List<Map<String, dynamic>>? breaks;

  AttendanceModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.companyId,
    required this.checkInTime,
    this.checkOutTime,
    required this.checkInLocation,
    this.checkOutLocation,
    required this.checkInImageUrl,
    this.checkOutImageUrl,
    required this.status,
    this.breaks,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json, String docId) {
    return AttendanceModel(
      id: docId,
      userId: json['user_id'],
      userName: json['user_name'],
      companyId: json['company_id'],
      checkInTime: (json['check_in_time'] as Timestamp).toDate(),
      checkOutTime: json['check_out_time'] != null
          ? (json['check_out_time'] as Timestamp).toDate()
          : null,
      checkInLocation: json['check_in_location'],
      checkOutLocation: json['check_out_location'],
      checkInImageUrl: json['check_in_image_url'],
      checkOutImageUrl: json['check_out_image_url'],
      status: json['status'],
      breaks: json['breaks'] != null
          ? List<Map<String, dynamic>>.from(json['breaks'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'company_id': companyId,
      'check_in_time': Timestamp.fromDate(checkInTime),
      'check_out_time': checkOutTime != null
          ? Timestamp.fromDate(checkOutTime!)
          : null,
      'check_in_location': checkInLocation,
      'check_out_location': checkOutLocation,
      'check_in_image_url': checkInImageUrl,
      'check_out_image_url': checkOutImageUrl,
      'status': status,
      'breaks': breaks,
    };
  }
}
