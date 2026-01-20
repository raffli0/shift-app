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

  const AdminActivity({
    required this.title,
    required this.time,
    required this.subtitle,
    this.isWarning = false,
  });
}

class AdminAttendance {
  final String name;
  final String time;
  final String status;
  final Color statusColor;
  final String location;
  final double latitude;
  final double longitude;
  final String imageUrl;

  const AdminAttendance({
    required this.name,
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
  final String name;
  final String type;
  final String dates;
  final String reason;
  final bool isPending;
  final bool isApproved;
  final String imageUrl;

  const AdminLeave({
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
  final String name;
  final String role;
  final String department;
  final String status;
  final bool isDestructive;
  final String imageUrl;

  const AdminUser({
    required this.name,
    required this.role,
    required this.department,
    required this.status,
    this.isDestructive = false,
    required this.imageUrl,
  });
}
