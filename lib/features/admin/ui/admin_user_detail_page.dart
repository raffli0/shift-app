import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_state.dart';
import '../models/admin_models.dart';
import '../../../shared/widgets/app_header.dart';
import 'admin_attendance_detail_page.dart';

class AdminUserDetailPage extends StatelessWidget {
  final AdminUser user;

  const AdminUserDetailPage({super.key, required this.user});

  static const kBgColor = Color(0xFF0E0F13);
  static const kSurfaceColor = Color(0xFF151821);
  static const kAccentColor = Color(0xFF7C7FFF);
  static const kTextPrimary = Color(0xFFEDEDED);
  static const kTextSecondary = Color(0xFF9AA0AA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: "User Profile",
              showAvatar: false,
              showBell: false,
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 24),
                    _buildInfoSection(),
                    const SizedBox(height: 24),
                    _buildRecentActivity(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: kAccentColor, width: 2),
              ),
              child: CircleAvatar(
                radius: 48,
                backgroundImage: NetworkImage(user.imageUrl),
                onBackgroundImageError: (_, __) {},
                child: user.imageUrl.isEmpty
                    ? Text(
                        user.name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: kAccentColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, size: 14, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          user.name,
          style: const TextStyle(
            color: kTextPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: user.status == "Active"
                ? const Color(0xFF4CAF50).withOpacity(0.15)
                : const Color(0xFFE57373).withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "${user.role.toUpperCase()} • ${user.status.toUpperCase()}",
            style: TextStyle(
              color: user.status == "Active"
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFE57373),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kSurfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.email_outlined, "Email", user.email),
          _buildDivider(),
          _buildInfoRow(Icons.work_outline, "Department", user.department),
          _buildDivider(),
          _buildInfoRow(
            Icons.badge_outlined,
            "Employee ID",
            user.id.substring(0, 8).toUpperCase(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: kBgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: kAccentColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: kTextSecondary, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                value.isEmpty ? "Not set" : value,
                style: const TextStyle(
                  color: kTextPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Divider(height: 1, color: Colors.white.withOpacity(0.05)),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "RECENT ACTIVITY",
          style: TextStyle(
            color: kTextSecondary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        BlocBuilder<AdminBloc, AdminState>(
          builder: (context, state) {
            // Filter attendance for this user
            // Note: Currently AdminAttendance doesn't have userId.
            // Matching by name is risky but acceptable for MVP until we add userId to AdminAttendance
            final userActivities = state.attendanceList
                .where((att) => att.name == user.name)
                .take(5)
                .toList();

            if (userActivities.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: kSurfaceColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.history, size: 48, color: kTextSecondary),
                    SizedBox(height: 12),
                    Text(
                      "No recent activity",
                      style: TextStyle(color: kTextSecondary),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: userActivities.map((attendance) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: kSurfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminAttendanceDetailPage(
                              attendance: attendance,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: attendance.statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.access_time_filled,
                                color: attendance.statusColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    attendance.status,
                                    style: const TextStyle(
                                      color: kTextPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    attendance.time,
                                    style: const TextStyle(
                                      color: kTextSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: kTextSecondary,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
