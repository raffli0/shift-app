import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leave_request_model.dart';
import '../../auth/models/user_model.dart';

class LeaveService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitLeaveRequest({
    required UserModel user,
    required String type,
    required String reason,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final leave = LeaveRequestModel(
      id: '',
      userId: user.id,
      userName: user.fullName,
      userImageUrl: "https://i.pravatar.cc/150?u=${user.id}", // Fallback/logic
      type: type,
      reason: reason,
      startDate: startDate,
      endDate: endDate,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    await _firestore.collection('leave_requests').add(leave.toMap());
  }

  Future<List<LeaveRequestModel>> getAllLeaveRequests() async {
    final snapshot = await _firestore
        .collection('leave_requests')
        .orderBy('created_at', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => LeaveRequestModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> updateLeaveStatus(String leaveId, String status) async {
    await _firestore.collection('leave_requests').doc(leaveId).update({
      'status': status,
    });
  }
}
