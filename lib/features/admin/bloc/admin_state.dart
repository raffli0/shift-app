import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import '../models/admin_models.dart';

enum AdminStatus { initial, loading, success, failure }

class AdminState extends Equatable {
  final AdminStatus status;
  final List<AdminMetric> metrics;
  final List<AdminActivity> activities;
  final List<AdminAttendance> attendanceList;
  final List<AdminLeave> leaveRequests;
  final List<AdminUser> users;
  final String? errorMessage;

  const AdminState({
    this.status = AdminStatus.initial,
    this.metrics = const [],
    this.activities = const [],
    this.attendanceList = const [],
    this.leaveRequests = const [],
    this.users = const [],
    this.officeLocation,
    this.allowedRadius = 100.0, // Default 100 meters
    this.errorMessage,
  });

  final LatLng? officeLocation;
  final double allowedRadius;

  AdminState copyWith({
    AdminStatus? status,
    List<AdminMetric>? metrics,
    List<AdminActivity>? activities,
    List<AdminAttendance>? attendanceList,
    List<AdminLeave>? leaveRequests,
    List<AdminUser>? users,
    LatLng? officeLocation,
    double? allowedRadius,
    String? errorMessage,
  }) {
    return AdminState(
      status: status ?? this.status,
      metrics: metrics ?? this.metrics,
      activities: activities ?? this.activities,
      attendanceList: attendanceList ?? this.attendanceList,
      leaveRequests: leaveRequests ?? this.leaveRequests,
      users: users ?? this.users,
      officeLocation: officeLocation ?? this.officeLocation,
      allowedRadius: allowedRadius ?? this.allowedRadius,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    metrics,
    activities,
    attendanceList,
    leaveRequests,
    users,
    officeLocation,
    allowedRadius,
    errorMessage,
  ];
}
