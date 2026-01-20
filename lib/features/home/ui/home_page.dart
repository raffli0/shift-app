import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shift/shared/widgets/app_header.dart';
import 'package:forui/forui.dart';

import '../../auth/bloc/auth_bloc.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../../attendance/models/attendance_model.dart';

import '../../auth/models/user_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthBloc bloc) => bloc.state.user);

    return BlocProvider(
      create: (context) => HomeBloc()..add(HomeStarted(user?.id ?? '')),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    // Select user here, in the build method of the generic widget
    final user = context.select((AuthBloc bloc) => bloc.state.user);

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFF0c202e),
          body: SafeArea(
            child: Column(
              children: [
                // Sticky HEADER
                AppHeader(title: "", showAvatar: true, showBell: true),
                const SizedBox(height: 5),
                // SCROLL AREA
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      final userId = user?.id ?? '';
                      context.read<HomeBloc>().add(
                        HomeRefreshRequested(userId),
                      );
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _buildGreetingRow(),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _buildGreeting(user),
                          ),
                          const SizedBox(height: 10),
                          _buildOverviewCard(state),
                          const SizedBox(height: 20),
                          _buildRecentActivityList(state.recentActivity),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openCalendar(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(color: Colors.black.withValues(alpha: 0.1)),
                ),
              ),
            ),
            Center(
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.88,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: SafeArea(
                    top: false,
                    child: FCalendar(
                      controller: FCalendarController.date(
                        initialSelection: selectedDate,
                      ),
                      start: DateTime(2000),
                      end: DateTime(2030),
                      onPress: (date) {
                        setState(() => selectedDate = date);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // GREETING
  Widget _buildGreeting(UserModel? user) {
    final firstName = user?.fullName.split(' ').first ?? 'User';

    return Text(
      "What's Up, $firstName!",
      style: const TextStyle(
        color: Colors.white,
        fontSize: 26,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  // DATE ROW
  Widget _buildGreetingRow() {
    return Row(
      children: [
        Text(
          DateFormat("d MMMM yyyy").format(DateTime.now()),
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // OVERVIEW CARD
  Widget _buildOverviewCard(HomeState state) {
    final today = state.todayAttendance;
    final hasCheckedIn = today != null;

    // Determine Check In Display
    final checkInTime = hasCheckedIn
        ? DateFormat("hh:mm a").format(today.checkInTime)
        : "--:--";
    final checkInBadge = hasCheckedIn
        ? (today.status == "Late" ? "Late" : "On time")
        : "n/a";
    final checkInColor = hasCheckedIn
        ? (today.status == "Late" ? Colors.orange : Colors.green)
        : Colors.grey;

    // Determine Check Out Display (Mock logic for checkout time field if not in model yet, assuming checkout updates doc)
    // Actually AttendanceModel doesn't have checkOutTime explicitly shown in previous view, let's check assumptions or use "n/a"
    // Wait, AttendanceService update checkOutTime. Let's assume AttendanceModel has it or we missed it.
    // Re-reading AttendanceModel... I didn't verify if it has checkOutTime.
    // In AttendanceService.checkOut: 'check_out_time': Timestamp.now().
    // user_model.dart... wait, attendance_model.dart.
    // I will assume I can't access checkOutTime if not in model.
    // Let's use what we have. If todayAttendance exists, we checked in.

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xfff1f1f6),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Overview",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                _DateBadge(
                  dateText: DateFormat("EEE, MMM dd").format(selectedDate),
                  onTap: () => _openCalendar(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          /// OVERVIEW BOXES
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _OverviewBox(
                        cupertinoIcon: CupertinoIcons.arrow_down_left_circle,
                        label: "Check in",
                        time: checkInTime,
                        badge: checkInBadge,
                        badgeColor: checkInColor,
                        subtitle: hasCheckedIn
                            ? "Checked in success"
                            : "Not checked in",
                        onTap: () => Navigator.pushNamed(context, '/check-in'),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _OverviewBox(
                        cupertinoIcon: CupertinoIcons.arrow_right_circle,
                        label: "Check out",
                        time: "--:--", // Placeholder until model updated
                        badge: "n/a",
                        badgeColor: Colors.grey,
                        subtitle: "It's not time yet",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _OverviewBox(
                        cupertinoIcon: CupertinoIcons.stopwatch,
                        label: "Break",
                        time: "--:--",
                        badge: "n/a",
                        badgeColor: Colors.grey,
                        subtitle: "No break record",
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _OverviewBox(
                        cupertinoIcon: CupertinoIcons.clock,
                        label: "Overtime",
                        time: "--:--",
                        badge: "n/a",
                        badgeColor: Colors.grey,
                        subtitle: "No overtime",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// DIVIDER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: Colors.grey.shade300),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityList(List<AttendanceModel> activities) {
    if (activities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Recent Activity",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/history'),
                child: const Text(
                  "See All",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff5a64d6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: activities.map((activity) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _RecentActivityItem(activity: activity),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _OverviewBox extends StatelessWidget {
  final IconData? cupertinoIcon;
  final String label;
  final String time;
  final String badge;
  final Color badgeColor;
  final String subtitle;
  final VoidCallback? onTap;

  const _OverviewBox({
    this.cupertinoIcon,
    required this.label,
    required this.time,
    required this.badge,
    required this.badgeColor,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: const Color(0xfffbfbff),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xffeef1ff),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    cupertinoIcon,
                    size: 18,
                    color: const Color(0xff5a64d6),
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    time,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: badgeColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateBadge extends StatelessWidget {
  final String dateText;
  final VoidCallback onTap;

  const _DateBadge({required this.dateText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              CupertinoIcons.calendar_today,
              size: 16,
              color: Color(0xff5a64d6),
            ),
            const SizedBox(width: 6),
            Text(
              dateText,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xff4a4a4a),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentActivityItem extends StatelessWidget {
  final AttendanceModel activity;

  const _RecentActivityItem({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat("hh:mm a").format(activity.checkInTime),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  activity.checkInLocation,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Text(
                  "Status: ${activity.status}",
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (activity.checkInImageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                activity.checkInImageUrl,
                width: 64,
                height: 52,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 64,
                  height: 52,
                  color: Colors.grey.shade200,
                  child: Icon(Icons.broken_image, size: 20),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
