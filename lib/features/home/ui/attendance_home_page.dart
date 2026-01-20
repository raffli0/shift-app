import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shift/shared/widgets/app_header.dart';

import 'package:forui/forui.dart';

class RecentActivity {
  final String time;
  final String location;
  final String imageUrl;
  final String description;

  RecentActivity({
    required this.time,
    required this.location,
    required this.imageUrl,
    required this.description,
  });
}

class AttendanceHomePage extends StatefulWidget {
  const AttendanceHomePage({super.key});

  @override
  State<AttendanceHomePage> createState() => _AttendanceHomePageState();
}

class _AttendanceHomePageState extends State<AttendanceHomePage> {
  DateTime selectedDate = DateTime.now();

  final List<RecentActivity> activities = [
    RecentActivity(
      time: "09:10 AM",
      location: "Main Office - Entrance Gate",
      imageUrl: "https://picsum.photos/200?1",
      description: "Checked in successfully",
    ),
    RecentActivity(
      time: "12:00 PM",
      location: "Cafeteria",
      imageUrl: "https://picsum.photos/200?2",
      description: "Lunch break started",
    ),
    RecentActivity(
      time: "17:45 PM",
      location: "Main Office - Exit Gate",
      imageUrl: "https://picsum.photos/200?3",
      description: "Checked out successfully",
    ),
    RecentActivity(
      time: "17:45 PM",
      location: "Main Office - Exit Gate",
      imageUrl: "https://picsum.photos/200?3",
      description: "Checked out successfully",
    ),
    RecentActivity(
      time: "17:45 PM",
      location: "Main Office - Exit Gate",
      imageUrl: "https://picsum.photos/200?3",
      description: "Checked out successfully",
    ),
    RecentActivity(
      time: "17:45 PM",
      location: "Main Office - Exit Gate",
      imageUrl: "https://picsum.photos/200?3",
      description: "Checked out successfully",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0c202e),
      body: SafeArea(
        child: Column(
          children: [
            // Sticky HEADER
            AppHeader(title: "Humana", showAvatar: true, showBell: true),
            SizedBox(height: 5),
            // SCROLL AREA
            Expanded(
              child: SingleChildScrollView(
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
                      child: _buildGreeting(),
                    ),
                    // const SizedBox(height: 5),
                    const SizedBox(height: 10),
                    _buildOverviewCard(),
                    // const SizedBox(height: 20),
                    // _buildRecentActivity(),
                    // const SizedBox(height: 30),
                    // _buildRecentActivity(),
                    // const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
            // AREA BACKGROUND BLUR (TAP TO CLOSE)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(color: Colors.black.withValues(alpha: 0.1)),
                ),
              ),
            ),

            // POP-UP CALENDAR DI TENGAH
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
  Widget _buildGreeting() {
    return const Text(
      "What's Up, John!",
      style: TextStyle(
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
          "Lorem ipsum dolor sit amet",
          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // OVERVIEW CARD
  Widget _buildOverviewCard() {
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
                  dateText: DateFormat("EEE, MMM dd yyyy").format(selectedDate),
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
                        time: "09:10 AM",
                        badge: "On time",
                        badgeColor: Colors.green,
                        subtitle: "Checked in success",
                        onTap: () => Navigator.pushNamed(context, '/check-in'),
                      ),
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: _OverviewBox(
                        cupertinoIcon: CupertinoIcons.arrow_right_circle,
                        label: "Check out",
                        time: "--:--",
                        badge: "n/a",
                        badgeColor: Colors.grey,
                        subtitle: "It's not time yet",
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _OverviewBox(
                        cupertinoIcon: CupertinoIcons.stopwatch,
                        label: "Break",
                        time: "09:10 AM",
                        badge: "On going",
                        badgeColor: Colors.red,
                        subtitle: "Break On going",
                      ),
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: _OverviewBox(
                        cupertinoIcon: CupertinoIcons.clock,
                        label: "Overtime",
                        time: "09:10 AM",
                        badge: "Late entry",
                        badgeColor: Colors.red,
                        subtitle: "Update, Nov 25 2025",
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

          const SizedBox(height: 12),

          /// RECENT ACTIVITY (INSIDE OVERVIEW)
          /// RECENT ACTIVITY (MULTIPLE)
          Padding(
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
                  children: List.generate(
                    activities.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _RecentActivityItem(activity: activities[index]),
                    ),
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

class _OverviewBox extends StatelessWidget {
  final IconData? cupertinoIcon; // jika pakai Cupertino
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
            // soft iOS shadow
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
  final RecentActivity activity;

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
                  activity.time,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  activity.location,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Text(
                  activity.description,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              activity.imageUrl,
              width: 64,
              height: 52,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
