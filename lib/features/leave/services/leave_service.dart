import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leave_request_model.dart';
import '../../auth/models/user_model.dart';

class LeaveService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ------------------------------------
  // EMPLOYEE FLOW
  // ------------------------------------

  /// 1. Create Leave Request
  /// Rules:
  /// - User must be active (Handled by Auth)
  /// - Start date <= end date
  /// - Initial status = pending
  Future<void> submitLeaveRequest({
    required UserModel user,
    required String type,
    required String reason,
    required DateTime startDate,
    required DateTime endDate,
    String? companyId,
  }) async {
    // Validation: Start date <= end date
    if (startDate.isAfter(endDate)) {
      throw Exception("Start date must be before or equal to end date.");
    }

    // TODO: Ideally check for overlap here, but complex in Firestore.

    final leave = LeaveRequestModel(
      id: '',
      userId: user.id,
      userName: user.fullName,
      userImageUrl: "https://i.pravatar.cc/150?u=${user.id}",
      companyId: companyId ?? 'default_company',
      type: type,
      reason: reason,
      startDate: startDate,
      endDate: endDate,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    await _firestore.collection('leave_requests').add(leave.toMap());
  }

  /// 2. View My Leave Requests
  /// - Return list sorted by newest
  Future<List<LeaveRequestModel>> getMyRequests(String userId) async {
    final snapshot = await _firestore
        .collection('leave_requests')
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => LeaveRequestModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// 3. View Leave Detail
  /// - Employee can only access their own leave
  Future<LeaveRequestModel?> getLeaveDetail(String id) async {
    final doc = await _firestore.collection('leave_requests').doc(id).get();
    if (doc.exists) {
      return LeaveRequestModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // ------------------------------------
  // ADMIN FLOW
  // ------------------------------------

  /// 1. View Pending Leave Requests
  /// - Filter by company (optional)
  /// - Sort by submission date
  Future<List<LeaveRequestModel>> getPendingRequests({
    String? companyId,
  }) async {
    Query query = _firestore
        .collection('leave_requests')
        .where('status', isEqualTo: 'pending');

    if (companyId != null) {
      query = query.where('company_id', isEqualTo: companyId);
    }

    // Note: ensure composite index exists for status + created_at
    final snapshot = await query.orderBy('created_at', descending: true).get();

    return snapshot.docs
        .map(
          (doc) => LeaveRequestModel.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id,
          ),
        )
        .toList();
  }

  /// 2. Approve Leave
  /// - Only admin role (Enforced by caller/Security Rules)
  /// - Leave must be pending
  Future<void> approveLeave(String leaveId, {String? adminNote}) async {
    await _updateStatus(leaveId, 'approved', adminNote);
  }

  /// 3. Reject Leave
  /// - Only admin role
  /// - Leave must be pending
  Future<void> rejectLeave(String leaveId, {String? adminNote}) async {
    await _updateStatus(leaveId, 'rejected', adminNote);
  }

  /// 4. View All Requests (Admin History)
  Future<List<LeaveRequestModel>> getAllLeaveRequests({
    String? companyId,
  }) async {
    Query query = _firestore.collection('leave_requests');

    if (companyId != null) {
      query = query.where('company_id', isEqualTo: companyId);
    }

    final snapshot = await query.orderBy('created_at', descending: true).get();

    return snapshot.docs
        .map(
          (doc) => LeaveRequestModel.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id,
          ),
        )
        .toList();
  }

  Future<void> _updateStatus(
    String leaveId,
    String status,
    String? note,
  ) async {
    final data = {'status': status, 'updated_at': Timestamp.now()};
    if (note != null && note.isNotEmpty) {
      data['admin_note'] = note;
    }

    await _firestore.collection('leave_requests').doc(leaveId).update(data);
  }
}
