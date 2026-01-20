import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shift/features/attendance/models/attendance_model.dart';

class AttendanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> checkIn({
    required String userId,
    required String userName,
    required String location,
    required File imageFile,
    required String status,
  }) async {
    // 1. Upload Image to Firebase Storage
    final fileName =
        'attendance/${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child(fileName);
    await ref.putFile(imageFile);
    final imageUrl = await ref.getDownloadURL();

    // 2. Save to Firestore
    final attendance = AttendanceModel(
      id: '', // Will be generated
      userId: userId,
      userName: userName,
      checkInTime: DateTime.now(),
      checkInLocation: location,
      checkInImageUrl: imageUrl,
      status: status,
    );

    await _firestore.collection('attendance').add(attendance.toJson());
  }

  Future<void> checkOut({
    required String attendanceId,
    required String location,
    required File imageFile,
  }) async {
    // 1. Upload image
    final fileName =
        'attendance/checkout_${attendanceId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child(fileName);
    await ref.putFile(imageFile);
    final imageUrl = await ref.getDownloadURL();

    // 2. Update Firestore
    await _firestore.collection('attendance').doc(attendanceId).update({
      'check_out_time': Timestamp.now(),
      'check_out_location': location,
      'check_out_image_url': imageUrl,
    });
  }

  Future<List<AttendanceModel>> getUserAttendance(String userId) async {
    final snapshot = await _firestore
        .collection('attendance')
        .where('user_id', isEqualTo: userId)
        .orderBy('check_in_time', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => AttendanceModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  Future<List<AttendanceModel>> getAllAttendance() async {
    final snapshot = await _firestore
        .collection('attendance')
        .orderBy('check_in_time', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => AttendanceModel.fromJson(doc.data(), doc.id))
        .toList();
  }
}
