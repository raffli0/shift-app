import 'package:flutter/material.dart';

class AdminMetric {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const AdminMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class AdminActivity {
  final String title;
  final String time;
  final String subtitle;
  final bool isWarning;
  final AdminAttendance? attendance; // Optional reference to attendance data

  const AdminActivity({
    required this.title,
    required this.time,
    required this.subtitle,
    this.isWarning = false,
    this.attendance,
  });
}

class AdminAttendance {
  final String name;
  final String role;
  final String time;
  final String status;
  final Color statusColor;
  final String location;
  final double latitude;
  final double longitude;
  final String imageUrl;

  const AdminAttendance({
    required this.name,
    required this.role,
    required this.time,
    required this.status,
    required this.statusColor,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
  });
}

class AdminLeave {
  final String id;
  final String name;
  final String type;
  final String dates;
  final String reason;
  final bool isPending;
  final bool isApproved;
  final String imageUrl;

  const AdminLeave({
    required this.id,
    required this.name,
    required this.type,
    required this.dates,
    required this.reason,
    required this.isPending,
    this.isApproved = false,
    required this.imageUrl,
  });
}

class AdminUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final String department;
  final String status;
  final bool isDestructive;
  final String imageUrl;
  final String? companyId; // Added companyId to preserve it

  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.department,
    required this.status,
    this.isDestructive = false,
    required this.imageUrl,
    this.companyId,
  });
}

class Shift {
  final String id;
  final String name;
  final String startTime;
  final String endTime;
  final int toleranceMinutes;

  const Shift({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.toleranceMinutes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'start_time': startTime,
      'end_time': endTime,
      'tolerance_time': toleranceMinutes,
    };
  }

  factory Shift.fromMap(Map<String, dynamic> map) {
    return Shift(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      startTime: map['start_time'] ?? '09:00',
      endTime: map['end_time'] ?? '17:00',
      toleranceMinutes: map['tolerance_time'] ?? 0,
    );
  }
}
