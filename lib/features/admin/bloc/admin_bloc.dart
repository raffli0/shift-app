import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import '../models/admin_models.dart';
import 'admin_event.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  AdminBloc() : super(const AdminState()) {
    on<AdminStarted>(_onStarted);
    on<AdminRefreshRequested>(_onRefresh);
    on<AdminUpdateOfficeSettings>(_onUpdateOfficeSettings);
  }

  Future<void> _onStarted(AdminStarted event, Emitter<AdminState> emit) async {
    emit(state.copyWith(status: AdminStatus.loading));
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call

    try {
      emit(
        state.copyWith(
          status: AdminStatus.success,
          metrics: _mockMetrics,
          activities: _mockActivities,
          attendanceList: _mockAttendance,

          leaveRequests: _mockLeaves,
          users: _mockUsers,
          officeLocation: const LatLng(37.7749, -122.4194), // Mock SF location
          allowedRadius: 150.0,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onRefresh(
    AdminRefreshRequested event,
    Emitter<AdminState> emit,
  ) async {
    // Re-fetch logic
    add(AdminStarted());
  }

  void _onUpdateOfficeSettings(
    AdminUpdateOfficeSettings event,
    Emitter<AdminState> emit,
  ) {
    emit(
      state.copyWith(
        officeLocation: event.location,
        allowedRadius: event.radius,
      ),
    );
  }

  // --- MOCK DATA ---
  final List<AdminMetric> _mockMetrics = [
    const AdminMetric(
      label: "Present",
      value: "42",
      icon: Icons.check_circle_outline,
      color: Colors.greenAccent,
    ),
    const AdminMetric(
      label: "Late",
      value: "5",
      icon: Icons.access_time,
      color: Colors.orangeAccent,
    ),
    const AdminMetric(
      label: "On Leave",
      value: "3",
      icon: Icons.beach_access,
      color: Colors.blueAccent,
    ),
    const AdminMetric(
      label: "Requests",
      value: "8",
      icon: Icons.assignment,
      color: Color(0xff5a64d6),
    ),
  ];

  final List<AdminActivity> _mockActivities = [
    const AdminActivity(
      title: "John Doe checked in",
      time: "08:58 AM",
      subtitle: "Headquarters",
    ),
    const AdminActivity(
      title: "Sarah Smith requested leave",
      time: "09:15 AM",
      subtitle: "Sick Leave • Pending",
    ),
    const AdminActivity(
      title: "Mike Ross checked in",
      time: "09:30 AM",
      subtitle: "Branch Office • Late",
      isWarning: true,
    ),
  ];

  final List<AdminAttendance> _mockAttendance = [
    const AdminAttendance(
      name: "John Doe",
      time: "08:58 AM",
      status: "On Time",
      statusColor: Colors.greenAccent,
      location: "Headquarters",
      latitude: 37.7749,
      longitude: -122.4194,
      imageUrl: "https://i.pravatar.cc/150?img=1",
    ),
    const AdminAttendance(
      name: "Mike Ross",
      time: "09:30 AM",
      status: "Late",
      statusColor: Colors.orangeAccent,
      location: "Branch Office",
      latitude: 40.7128,
      longitude: -74.0060,
      imageUrl: "https://i.pravatar.cc/150?img=2",
    ),
    const AdminAttendance(
      name: "Jane Smith",
      time: "--:--",
      status: "Absent",
      statusColor: Colors.redAccent,
      location: "-",
      latitude: 0.0,
      longitude: 0.0,
      imageUrl: "https://i.pravatar.cc/150?img=3",
    ),
    const AdminAttendance(
      name: "Alice Johnson",
      time: "08:45 AM",
      status: "On Time",
      statusColor: Colors.greenAccent,
      location: "Remote",
      latitude: 51.5074,
      longitude: -0.1278,
      imageUrl: "https://i.pravatar.cc/150?img=4",
    ),
    const AdminAttendance(
      name: "Bob Brown",
      time: "09:05 AM",
      status: "Late",
      statusColor: Colors.orangeAccent,
      location: "Headquarters",
      latitude: 37.7749,
      longitude: -122.4194,
      imageUrl: "https://i.pravatar.cc/150?img=5",
    ),
  ];

  final List<AdminLeave> _mockLeaves = [
    const AdminLeave(
      name: "Sarah Smith",
      type: "Sick Leave",
      dates: "26 Oct - 27 Oct",
      reason: "Feeling unwell, high fever.",
      isPending: true,
      imageUrl: "https://i.pravatar.cc/150?img=5",
    ),
    const AdminLeave(
      name: "David Wilson",
      type: "Annual Leave",
      dates: "1 Nov - 5 Nov",
      reason: "Family vacation.",
      isPending: true,
      imageUrl: "https://i.pravatar.cc/150?img=6",
    ),
    const AdminLeave(
      name: "John Doe",
      type: "Casual Leave",
      dates: "20 Oct",
      reason: "Personal errand.",
      isPending: false,
      isApproved: true,
      imageUrl: "https://i.pravatar.cc/150?img=1",
    ),
    const AdminLeave(
      name: "Emily Clark",
      type: "Sick Leave",
      dates: "15 Oct",
      reason: "Migraine.",
      isPending: false,
      isApproved: false,
      imageUrl: "https://i.pravatar.cc/150?img=7",
    ),
  ];

  final List<AdminUser> _mockUsers = [
    const AdminUser(
      name: "John Doe",
      role: "Software Engineer",
      department: "Engineering",
      status: "Active",
      imageUrl: "https://i.pravatar.cc/150?img=1",
    ),
    const AdminUser(
      name: "Sarah Smith",
      role: "Product Manager",
      department: "Product",
      status: "Active",
      imageUrl: "https://i.pravatar.cc/150?img=5",
    ),
    const AdminUser(
      name: "Mike Ross",
      role: "Intern",
      department: "Engineering",
      status: "Inactive",
      isDestructive: true,
      imageUrl: "https://i.pravatar.cc/150?img=2",
    ),
    const AdminUser(
      name: "Jane Smith",
      role: "Designer",
      department: "Design",
      status: "Active",
      imageUrl: "https://i.pravatar.cc/150?img=3",
    ),
  ];
}
