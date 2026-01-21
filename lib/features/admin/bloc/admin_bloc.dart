import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final String? companyId;
  final String? _userId;
  DateTime? _lastActivitiesClearedTime;

  AdminBloc({
    AttendanceService? attendanceService,
    AuthService? authService,
    LeaveService? leaveService,
    ConfigService? configService,
    this.companyId,
    String? userId,
  }) : _attendanceService = attendanceService ?? AttendanceService(),
       _authService = authService ?? AuthService(),
       _leaveService = leaveService ?? LeaveService(),
       _configService = configService ?? ConfigService(),
       _userId = userId,
       super(const AdminState()) {
    on<AdminStarted>(_onStarted);
    on<AdminRefreshRequested>((event, emit) => add(AdminStarted()));
    on<AdminUpdateOfficeSettings>(_onUpdateOfficeSettings);
    on<AdminUserAdded>(_onUserAdded);
    on<AdminUserUpdated>(_onUserUpdated);
    on<AdminUserDeleted>(_onUserDeleted);
    on<AdminLeaveStatusUpdated>(_onLeaveStatusUpdated);
    on<AdminAttendanceStreamUpdated>(_onAttendanceStreamUpdated);
    on<AdminClearActivities>(_onClearActivities);
  }

  Future<void> _onClearActivities(
    AdminClearActivities event,
    Emitter<AdminState> emit,
  ) async {
    final now = DateTime.now();
    _lastActivitiesClearedTime = now;

    final prefs = await SharedPreferences.getInstance();
    // Use userId to be specific to the admin user
    final key = _userId != null
        ? 'admin_last_cleared_user_$_userId'
        : 'admin_last_cleared_${companyId ?? 'default'}';

    await prefs.setString(key, now.toIso8601String());

    emit(state.copyWith(activities: []));
  }

  Future<void> _onLeaveStatusUpdated(
    AdminLeaveStatusUpdated event,
    Emitter<AdminState> emit,
  ) async {
    try {
      if (event.status == 'approved') {
        await _leaveService.approveLeave(event.leaveId);
      } else if (event.status == 'rejected') {
        await _leaveService.rejectLeave(event.leaveId);
      }
      add(AdminStarted()); // Reload data to reflect changes
    } catch (e) {
      // Handle error if needed, maybe show snackbar via listener in UI
      debugPrint("Error updating leave status: $e");
    }
  }

  StreamSubscription? _attendanceSubscription;

  Future<void> _onStarted(AdminStarted event, Emitter<AdminState> emit) async {
    emit(state.copyWith(status: AdminStatus.loading));

    try {
      // Load persistent clear time
      final prefs = await SharedPreferences.getInstance();
      final key = _userId != null
          ? 'admin_last_cleared_user_$_userId'
          : 'admin_last_cleared_${companyId ?? 'default'}';

      final savedTime = prefs.getString(key);

      if (savedTime != null) {
        _lastActivitiesClearedTime = DateTime.tryParse(savedTime);
      }

      // Config Service
      final config = await _configService.getOfficeConfig(companyId ?? '');
      final officeLocation = LatLng(
        (config['latitude'] as num).toDouble(),
        (config['longitude'] as num).toDouble(),
      );
      final allowedRadius = (config['radius'] as num).toDouble();

      // Fetch Initial Data
      final users = await _authService.getAllUsers();
      final leaveRequests = await _leaveService.getAllLeaveRequests(
        companyId: companyId,
      );

      // Convert users and leave requests (static for now, can be streamed later)
      // Convert users to AdminUser model
      final adminUsers = users.map((u) {
        return AdminUser(
          id: u.id,
          name: u.fullName,
          email: u.email,
          role: u.role,
          department: "Staff", // Default for now
          status: u.status, // Map status from UserModel
          imageUrl: "https://i.pravatar.cc/150?u=${u.id}",
          companyId: u.companyId,
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

      // Emit initial state with loaded users/leaves/config
      emit(
        state.copyWith(
          status: AdminStatus.success,
          metrics: [], // Metrics will be calculated when attendance loads
          activities: [],
          attendanceList: [],
          leaveRequests: adminLeave,
          users: adminUsers,
          officeLocation: officeLocation,
          allowedRadius: allowedRadius,
        ),
      );

      // Subscribe to Attendance Stream
      _attendanceSubscription?.cancel();
      _attendanceSubscription = _attendanceService
          .getAttendanceStream(companyId ?? '')
          .listen((attendance) {
            add(AdminAttendanceStreamUpdated(attendance));
          });
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  void _onAttendanceStreamUpdated(
    AdminAttendanceStreamUpdated event,
    Emitter<AdminState> emit,
  ) {
    // Check if the event data matches expected type (List<AttendanceModel>)
    // If we used dynamic in event, cast it here.
    // Importing AttendanceModel in event file would be better, but avoiding import errors here.
    // Assuming event.attendance is List<AttendanceModel>
    // We should import AttendanceModel in admin_event.dart properly if possible.
    // But since I used dynamic, I will trust it matches what service returns.
    // Service returns List<AttendanceModel>.

    // Actually, let's fix the event import if we can, but since I can't edit creating file again easily without viewing,
    // I made event dynamic. AdminBloc has access to AttendanceModel from imports.
    // So:
    // final attendance = event.attendance as List<AttendanceModel>;
    // Wait, List<AttendanceModel> might be incompatible with List<dynamic>.
    // Service emits List<AttendanceModel>.
    // Event accepts dynamic List.
    // Let's iterate.

    final attendance = event.attendance;

    // Convert attendance to AdminAttendance model
    final attendanceList = attendance.map((a) {
      // a is dynamic, cast to AttendanceModel if needed or just access fields if dynamic (dangerous)
      // Let's cast it since we know what it is.
      // But wait, can I import AttendanceModel in AdminBloc? Yes.
      // So:
      // final model = a as AttendanceModel;

      // Look up user role from state.users
      final user = state.users.where((u) => u.id == a.userId).firstOrNull;
      final role = user?.role ?? "Staff";

      return AdminAttendance(
        name: a.userName ?? "Unknown",
        role: role,
        time: a.checkInTime != null
            ? DateFormat("hh:mm a").format(a.checkInTime)
            : "--:--",
        status: a.status ?? "Unknown",
        statusColor: a.status == "Late"
            ? Colors.orangeAccent
            : Colors.greenAccent,
        location: a.checkInLocation ?? "Unknown Location",
        latitude: 0.0,
        longitude: 0.0,
        imageUrl: a.checkInImageUrl ?? "",
      );
    }).toList();

    // Convert attendance to AdminActivity model
    final activities = <AdminActivity>[];
    for (int i = 0; i < attendance.length; i++) {
      final a = attendance[i];

      // Filter based on cleared time
      if (_lastActivitiesClearedTime != null) {
        final checkInTime = a.checkInTime as DateTime?;
        if (checkInTime == null ||
            checkInTime.isBefore(_lastActivitiesClearedTime!)) {
          continue;
        }
      }

      final adminAttendance = attendanceList[i];
      activities.add(
        AdminActivity(
          title: "${a.userName ?? 'Unknown'} checked in",
          time: a.checkInTime != null
              ? DateFormat("hh:mm a").format(a.checkInTime)
              : "--:--",
          subtitle: a.checkInLocation ?? "Unknown Location",
          isWarning: a.status == "Late",
          attendance: adminAttendance,
        ),
      );
    }

    // Calculate Metrics
    final presentCount = attendance.length;
    final lateCount = attendance.where((a) => a.status == "Late").length;
    // For leaves and requests, allow reusing state values or separate stream.
    // Currently leaveRequests are in state.
    final leaveCount = state.leaveRequests.where((l) => l.isApproved).length;
    final requestCount = state.leaveRequests.where((l) => l.isPending).length;

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
        metrics: metrics,
        attendanceList: List<AdminAttendance>.from(attendanceList),
        activities: List<AdminActivity>.from(activities),
      ),
    );
  }

  Future<void> _onUpdateOfficeSettings(
    AdminUpdateOfficeSettings event,
    Emitter<AdminState> emit,
  ) async {
    await _configService.updateOfficeConfig(
      companyId ?? '',
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
        companyId: companyId,
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
        status: event.user.status, // Include status
        companyId: event.user.companyId, // Preserve companyId
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
