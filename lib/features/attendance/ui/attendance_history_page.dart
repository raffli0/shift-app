import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shift/shared/widgets/app_header.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../attendance/services/attendance_service.dart';
import '../../attendance/models/attendance_model.dart';

class _ActivityItemModel {
  final String time;
  final String description;
  final String location;
  final String imageUrl;
  final bool isLate;

  _ActivityItemModel({
    required this.time,
    required this.description,
    required this.location,
    required this.imageUrl,
    this.isLate = false,
  });
}

class AttendanceHistoryPage extends StatefulWidget {
  const AttendanceHistoryPage({super.key});

  @override
  State<AttendanceHistoryPage> createState() => _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState extends State<AttendanceHistoryPage> {
  late Future<List<AttendanceModel>> _historyFuture;

  // Design Constants
  static const kBgColor = Color(0xFF0E0F13);
  static const kSurfaceColor = Color(0xFF151821);
  static const kAccentColor = Color(0xFF7C7FFF);
  static const kTextPrimary = Color(0xFFEDEDED);
  static const kTextSecondary = Color(0xFF9AA0AA);

  @override
  void initState() {
    super.initState();
    final userId = context.read<AuthBloc>().state.user?.id ?? '';
    _historyFuture = AttendanceService().getUserAttendance(userId);
  }

  Map<DateTime, List<_ActivityItemModel>> _groupActivities(
    List<AttendanceModel> list,
  ) {
    final Map<DateTime, List<_ActivityItemModel>> grouped = {};

    for (var attendance in list) {
      final dateKey = DateTime(
        attendance.checkInTime.year,
        attendance.checkInTime.month,
        attendance.checkInTime.day,
      );

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }

      // Add Check In
      grouped[dateKey]!.add(
        _ActivityItemModel(
          time: DateFormat("hh:mm a").format(attendance.checkInTime),
          description: "Check In",
          location: attendance.checkInLocation,
          imageUrl: attendance.checkInImageUrl,
          isLate: attendance.status == "Late",
        ),
      );

      // Add Check Out if exists
      if (attendance.checkOutTime != null) {
        grouped[dateKey]!.add(
          _ActivityItemModel(
            time: DateFormat("hh:mm a").format(attendance.checkOutTime!),
            description: "Check Out",
            location: attendance.checkOutLocation ?? "Unknown",
            imageUrl: attendance.checkOutImageUrl ?? "",
          ),
        );
      }
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              title: "History",
              showAvatar: false,
              showBell: false,
            ),
            Expanded(
              child: FutureBuilder<List<AttendanceModel>>(
                future: _historyFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Error loading history",
                        style: TextStyle(color: kTextPrimary),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        "No attendance history",
                        style: TextStyle(color: kTextSecondary),
                      ),
                    );
                  }

                  final groupedData = _groupActivities(snapshot.data!);
                  final dates = groupedData.keys.toList()
                    ..sort((a, b) => b.compareTo(a));

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    itemCount: dates.length,
                    itemBuilder: (context, index) {
                      final date = dates[index];
                      final activities = groupedData[date]!;

                      // Sort activities by time descending within the day if desired,
                      // but typically Check In is first then Check Out.
                      // Loop added them in order (Check In then Check Out).
                      // If we want reverse chronological (latest first), reverse the list.
                      // Let's keep chronological for the day flow (Check In -> Check Out).

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // DATE HEADER
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              DateFormat("EEEE, dd MMMM yyyy").format(date),
                              style: TextStyle(
                                color: kTextSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          // LIST ITEMS
                          ...activities.map(
                            (activity) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _HistoryItem(activity: activity),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      );
                    },
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

class _HistoryItem extends StatelessWidget {
  final _ActivityItemModel activity;

  const _HistoryItem({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: _AttendanceHistoryPageState.kSurfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.02)),
      ),
      child: Row(
        children: [
          // TIME & INDICATOR
          Column(
            children: [
              Text(
                activity.time,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: _AttendanceHistoryPageState.kTextPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: activity.isLate
                      ? Colors.orange
                      : const Color(0xff5a64d6),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          // DASHED LINE SEPARATOR
          Container(
            height: 40,
            width: 1,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          const SizedBox(width: 16),

          // DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.description + (activity.isLate ? " (Late)" : ""),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: activity.isLate
                        ? Colors.orange
                        : _AttendanceHistoryPageState.kTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.location,
                  style: TextStyle(
                    fontSize: 13,
                    color: _AttendanceHistoryPageState.kTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
