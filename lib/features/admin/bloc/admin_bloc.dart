import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../models/admin_models.dart';
import 'admin_event.dart';
import 'admin_state.dart';
import '../../../../core/services/config_service.dart';
import '../../attendance/services/attendance_service.dart';
import '../../auth/models/user_model.dart';
import '../../auth/services/auth_service.dart';
import '../../leave/services/leave_service.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AttendanceService _attendanceService;
  final AuthService _authService;
  final LeaveService _leaveService;
  final ConfigService _configService;

  AdminBloc({
    AttendanceService? attendanceService,
    AuthService? authService,
    LeaveService? leaveService,
    ConfigService? configService,
  }) : _attendanceService = attendanceService ?? AttendanceService(),
       _authService = authService ?? AuthService(),
       _leaveService = leaveService ?? LeaveService(),
       _configService = configService ?? ConfigService(),
       super(const AdminState()) {
    on<AdminStarted>(_onStarted);
    on<AdminRefreshRequested>((event, emit) => add(AdminStarted()));
    on<AdminUpdateOfficeSettings>(_onUpdateOfficeSettings);
    on<AdminUserAdded>(_onUserAdded);
    on<AdminUserUpdated>(_onUserUpdated);
    on<AdminUserDeleted>(_onUserDeleted);
    on<AdminLeaveStatusUpdated>(_onLeaveStatusUpdated);
  }

  Future<void> _onLeaveStatusUpdated(
    AdminLeaveStatusUpdated event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _leaveService.updateLeaveStatus(event.leaveId, event.status);
      add(AdminStarted()); // Reload data to reflect changes
    } catch (e) {
      // Handle error if needed, maybe show snackbar via listener in UI
      debugPrint("Error updating leave status: $e");
    }
  }

  Future<void> _onStarted(AdminStarted event, Emitter<AdminState> emit) async {
    emit(state.copyWith(status: AdminStatus.loading));

    try {
      // Config Service
      final config = await _configService.getOfficeConfig();
      final officeLocation = LatLng(
        (config['latitude'] as num).toDouble(),
        (config['longitude'] as num).toDouble(),
      );
      final allowedRadius = (config['radius'] as num).toDouble();

      // Fetch All Data from Firebase
      final attendance = await _attendanceService.getAllAttendance();
      final users = await _authService.getAllUsers();
      final leaveRequests = await _leaveService.getAllLeaveRequests();

      // Convert attendance to AdminAttendance model
      final attendanceList = attendance.map((a) {
        return AdminAttendance(
          name: a.userName,
          time: DateFormat("hh:mm a").format(a.checkInTime),
          status: a.status,
          statusColor: a.status == "Late"
              ? Colors.orangeAccent
              : Colors.greenAccent,
          location: a.checkInLocation,
          latitude: 0.0, // Should be stored in model later if needed
          longitude: 0.0,
          imageUrl: a.checkInImageUrl,
        );
      }).toList();

      // Convert attendance to AdminActivity model
      final activities = attendance.map((a) {
        return AdminActivity(
          title: "${a.userName} checked in",
          time: DateFormat("hh:mm a").format(a.checkInTime),
          subtitle: a.checkInLocation,
          isWarning: a.status == "Late",
        );
      }).toList();

      // Convert users to AdminUser model
      final adminUsers = users.map((u) {
        return AdminUser(
          id: u.id,
          name: u.fullName,
          email: u.email,
          role: u.role,
          department: "Staff", // Default for now
          status: "Active",
          imageUrl: "https://i.pravatar.cc/150?u=${u.id}",
        );
      }).toList();

      // Convert LeaveRequests to AdminLeave
      final adminLeave = leaveRequests.map((l) {
        final dates = l.startDate.day == l.endDate.day
            ? DateFormat("MMM dd").format(l.startDate)
            : "${DateFormat("MMM dd").format(l.startDate)} - ${DateFormat("MMM dd").format(l.endDate)}";

        return AdminLeave(
          id: l.id,
          name: l.userName,
          type: l.type,
          dates: dates,
          reason: l.reason,
          isPending: l.status == "pending",
          isApproved: l.status == "approved",
          imageUrl: l.userImageUrl,
        );
      }).toList();

      // Calculate Metrics
      final presentCount = attendance.length;
      final lateCount = attendance.where((a) => a.status == "Late").length;
      final leaveCount = adminLeave
          .where((l) => l.isApproved)
          .length; // Approved leaves count
      final requestCount = adminLeave.where((l) => l.isPending).length;

      final metrics = [
        AdminMetric(
          label: "Present",
          value: presentCount.toString(),
          icon: Icons.check_circle_outline,
          color: Colors.greenAccent,
        ),
        AdminMetric(
          label: "Late",
          value: lateCount.toString(),
          icon: Icons.access_time,
          color: Colors.orangeAccent,
        ),
        AdminMetric(
          label: "On Leave",
          value: leaveCount.toString(),
          icon: Icons.beach_access,
          color: Colors.blueAccent,
        ),
        AdminMetric(
          label: "Requests",
          value: requestCount.toString(),
          icon: Icons.assignment,
          color: Color(0xff5a64d6),
        ),
      ];

      emit(
        state.copyWith(
          status: AdminStatus.success,
          metrics: metrics,
          activities: activities,
          attendanceList: attendanceList,
          leaveRequests: adminLeave, // Updated with real data
          users: adminUsers,
          officeLocation: officeLocation,
          allowedRadius: allowedRadius,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onUpdateOfficeSettings(
    AdminUpdateOfficeSettings event,
    Emitter<AdminState> emit,
  ) async {
    await _configService.updateOfficeConfig(
      event.location.latitude,
      event.location.longitude,
      event.radius,
    );
    emit(
      state.copyWith(
        officeLocation: event.location,
        allowedRadius: event.radius,
      ),
    );
  }

  Future<void> _onUserAdded(
    AdminUserAdded event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      // Create user in Firestore via AuthService
      final newUserModel = UserModel(
        id: '', // Placeholder, will be generated by Firestore
        fullName: event.user.name,
        email: event.user.email,
        role: event.user.role,
      );

      await _authService.createEmployeeProfile(newUserModel);

      // Refresh list
      add(AdminStarted());
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onUserUpdated(
    AdminUserUpdated event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      // Map AdminUser back to UserModel
      final updatedUserModel = UserModel(
        id: event.user.id,
        fullName: event.user.name,
        email: event.user.email,
        role: event.user.role,
      );

      await _authService.updateUser(updatedUserModel);

      // Refresh list
      add(AdminStarted());
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onUserDeleted(
    AdminUserDeleted event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      await _authService.deleteUser(event.user.id);
      add(AdminStarted());
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.failure, errorMessage: e.toString()),
      );
    }
  }
}
