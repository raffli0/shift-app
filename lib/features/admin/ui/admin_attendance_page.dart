import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_state.dart';
import '../../../shared/widgets/app_header.dart';
import 'admin_attendance_detail_page.dart';

import 'package:intl/intl.dart';

class AdminAttendancePage extends StatefulWidget {
  const AdminAttendancePage({super.key});

  @override
  State<AdminAttendancePage> createState() => _AdminAttendancePageState();
}

class _AdminAttendancePageState extends State<AdminAttendancePage> {
  final DateTime _selectedDate = DateTime.now();
  String _selectedFilter = 'All'; // All, On Time, Late, Absent

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0F13), // Match new dark theme
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
                  // Filter logic
                  var filteredList = state.attendanceList.where((item) {
                    if (_selectedFilter == 'All') return true;
                    return item.status.toLowerCase() ==
                        _selectedFilter.toLowerCase();
                  }).toList();

                  // Sort logic
                  filteredList.sort((a, b) {
                    final priorityA = _getStatusPriority(a.status);
                    final priorityB = _getStatusPriority(b.status);
                    return priorityB.compareTo(priorityA);
                  });

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('EEEE, d MMM').format(_selectedDate),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            FButton(
                              onPress: () => _showFilterSheet(context),
                              child: Row(
                                children: [
                                  const Icon(Icons.filter_list, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    _selectedFilter == 'All'
                                        ? "Filter"
                                        : _selectedFilter,
                                  ),
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
                              color: const Color(0xff151821), // Dark surface
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
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: filteredList.isEmpty
                                      ? const Center(
                                          child: Text(
                                            "No records found",
                                            style: TextStyle(
                                              color: Colors.white54,
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          itemCount: filteredList.length,
                                          itemBuilder: (context, index) {
                                            final item = filteredList[index];
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

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF151821),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Filter by Status",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...['All', 'On Time', 'Late', 'Absent'].map((status) {
                final isSelected = _selectedFilter == status;
                return ListTile(
                  title: Text(
                    status,
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xff7C7FFF)
                          : Colors.white70,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: Color(0xff7C7FFF))
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedFilter = status;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  int _getStatusPriority(String status) {
    switch (status.toLowerCase()) {
      case 'absent':
        return 3;
      case 'late':
        return 2;
      case 'on time':
        return 1;
      default:
        return 0;
    }
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
        color: const Color(0xFF0E0F13), // Distinct dark card
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFFEDEDED),
                  ),
                ),
                Text(
                  location,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9AA0AA),
                  ),
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
                  color: Color(0xFFEDEDED),
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
                    color: statusColor,
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
