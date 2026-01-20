import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_state.dart';
import '../../../shared/widgets/app_header.dart';
import 'admin_attendance_detail_page.dart';

class AdminAttendancePage extends StatelessWidget {
  const AdminAttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0c202e),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              title: "Attendance",
              showAvatar: true,
              showBell: true,
            ),
            Expanded(
              child: BlocBuilder<AdminBloc, AdminState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      // Filters
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Today, 26 Oct", // Could be dynamic
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            FButton(
                              onPress: () {},
                              child: const Row(
                                children: [
                                  Icon(Icons.filter_list, size: 16),
                                  SizedBox(width: 8),
                                  Text("Filter"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xfff1f1f6),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                                  child: Text(
                                    "Attendance History",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    itemCount: state.attendanceList.length,
                                    itemBuilder: (context, index) {
                                      final item = state.attendanceList[index];
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AdminAttendanceDetailPage(
                                                    attendance: item,
                                                  ),
                                            ),
                                          );
                                        },
                                        child: _AttendanceItem(
                                          name: item.name,
                                          time: item.time,
                                          status: item.status,
                                          statusColor: item.statusColor,
                                          location: item.location,
                                          imageUrl: item.imageUrl,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceItem extends StatelessWidget {
  final String name;
  final String time;
  final String status;
  final Color statusColor;
  final String location;
  final String imageUrl;

  const _AttendanceItem({
    required this.name,
    required this.time,
    required this.status,
    required this.statusColor,
    required this.location,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xfffbfbff),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          FAvatar(
            fallback: Text(name.substring(0, 2).toUpperCase()),
            image: NetworkImage(imageUrl),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  location,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color:
                        statusColor.withValues(alpha: 1.0) == Colors.greenAccent
                        ? Colors.green[700]
                        : (statusColor == Colors.orangeAccent
                              ? Colors.orange[800]
                              : Colors.red[700]),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
