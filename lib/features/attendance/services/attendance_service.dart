import 'dart:io';
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shift/features/attendance/models/attendance_model.dart';

import 'package:shift/features/attendance/services/attendance_api.dart';

class AttendanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> checkIn({
    required String userId,
    required String userName,
    required String? companyId,
    required String location,
    required String status,
    required double latitude,
    required double longitude,
    required bool insideOffice,
    File? imageFile,
  }) async {
    String imageUrl = "";

    // 1. Try Upload via Custom API
    if (imageFile != null) {
      developer.log(
        "Attempting upload to Custom API with image: ${imageFile.path}",
        name: 'AttendanceService',
      );
      try {
        final apiResult = await AttendanceApi.checkIn(
          employeeId: userId,
          photo: imageFile,
          latitude: latitude,
          longitude: longitude,
          address: location,
          insideOffice: insideOffice,
        );
        if (apiResult != null && apiResult.isNotEmpty) {
          imageUrl = apiResult;
        }
      } catch (e) {
        developer.log(
          "Custom API upload failed: $e",
          name: 'AttendanceService',
        );
      }

      // 2. Fallback to Firebase Storage if API failed
      if (imageUrl.isEmpty) {
        try {
          final fileName =
              'attendance/${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final ref = _storage.ref().child(fileName);
          await ref.putFile(imageFile);
          imageUrl = await ref.getDownloadURL();
        } catch (e) {
          developer.log(
            "Firebase upload failed: $e",
            name: 'AttendanceService',
          );
        }
      }
    }

    // 2. Save to Firestore
    final attendance = AttendanceModel(
      id: '', // Will be generated
      userId: userId,
      userName: userName,
      companyId: companyId,
      checkInTime: DateTime.now(),
      checkInLocation: location,
      checkInImageUrl: imageUrl,
      status: status,
    );

    await _firestore.collection('attendance').add(attendance.toJson());
  }

  Future<void> startBreak(String attendanceId) async {
    // We add a new break entry with just start time
    final breakEntry = {'start': Timestamp.now(), 'end': null};

    // We need to read current breaks maybe?
    // FieldValue.arrayUnion works if we treat the whole object as unique.
    // But 'end' will change later, so arrayUnion might be tricky if we want to update it.
    // Simplest reliable way: Update via transaction or simple read-modify-write.
    // Let's use arrayUnion for start since it's a new object.

    await _firestore.collection('attendance').doc(attendanceId).update({
      'breaks': FieldValue.arrayUnion([breakEntry]),
    });
  }

  Future<void> endBreak(String attendanceId) async {
    // We need to find the open break (where end is null) and close it.
    // Firestore doesn't support updating an array element by condition.
    // We must read, modify, write.

    final docRef = _firestore.collection('attendance').doc(attendanceId);
    final snapshot = await docRef.get();

    if (snapshot.exists) {
      final data = snapshot.data();
      List<dynamic> breaks = data?['breaks'] ?? [];

      // Find the last break with null end
      // We iterate backwards
      for (int i = breaks.length - 1; i >= 0; i--) {
        if (breaks[i]['end'] == null) {
          breaks[i]['end'] = Timestamp.now();
          break; // Close only one
        }
      }

      await docRef.update({'breaks': breaks});
    }
  }

  Future<void> checkOut({
    required String attendanceId,
    required String location,
    File? imageFile,
  }) async {
    String imageUrl = "";
    // 1. Upload image
    if (imageFile != null) {
      final fileName =
          'attendance/checkout_${attendanceId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(fileName);
      await ref.putFile(imageFile);
      imageUrl = await ref.getDownloadURL();
    }

    // 2. Update Firestore (Read-Modify-Write to close breaks)
    final docRef = _firestore.collection('attendance').doc(attendanceId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      List<dynamic> breaks = data['breaks'] ?? [];
      bool breaksModified = false;

      // Close any open breaks
      for (int i = 0; i < breaks.length; i++) {
        if (breaks[i]['end'] == null) {
          breaks[i]['end'] = Timestamp.now();
          breaksModified = true;
        }
      }

      final updateData = <String, dynamic>{
        'check_out_time': Timestamp.now(),
        'check_out_location': location,
        'check_out_image_url': imageUrl,
        'status': 'Checked Out', // Optional: update status if needed
      };

      if (breaksModified) {
        updateData['breaks'] = breaks;
      }

      transaction.update(docRef, updateData);
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

  Future<AttendanceModel?> getTodayAttendance(String userId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final snapshot = await _firestore
        .collection('attendance')
        .where('user_id', isEqualTo: userId)
        .where(
          'check_in_time',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where(
          'check_in_time',
          isLessThanOrEqualTo: Timestamp.fromDate(endOfDay),
        )
        .orderBy('check_in_time', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return AttendanceModel.fromJson(
        snapshot.docs.first.data(),
        snapshot.docs.first.id,
      );
    }
    return null;
  }

  Future<List<AttendanceModel>> getAllAttendance(String companyId) async {
    final snapshot = await _firestore
        .collection('attendance')
        .where('company_id', isEqualTo: companyId)
        .orderBy('check_in_time', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => AttendanceModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  Stream<List<AttendanceModel>> getAttendanceStream(String companyId) {
    return _firestore
        .collection('attendance')
        .where('company_id', isEqualTo: companyId)
        .orderBy('check_in_time', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => AttendanceModel.fromJson(doc.data(), doc.id))
              .toList();
        });
  }
}
