import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_state.dart';
import '../../../shared/widgets/app_header.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0c202e),
      body: SafeArea(
        child: Column(
          children: [
            // Sticky HEADER
            const AppHeader(
              title: "Admin Dashboard",
              showAvatar: true,
              showBell: true,
            ),
            const SizedBox(height: 5),
            Expanded(
              child: BlocBuilder<AdminBloc, AdminState>(
                builder: (context, state) {
                  if (state.status == AdminStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return SingleChildScrollView(
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
                        const SizedBox(height: 10),
                        _buildOverviewCard(state),
                      ],
                    ),
                  );
                },
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
                    color: Colors.white,
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
      "Welcome Back, Admin!",
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
          DateFormat('MMMM dd, yyyy').format(DateTime.now()),
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // OVERVIEW CARD
  Widget _buildOverviewCard(AdminState state) {
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

          /// OVERVIEW BOXES (Adapted from Metrics)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                if (state.metrics.isNotEmpty) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _OverviewBox(
                          cupertinoIcon: CupertinoIcons.person_2,
                          label: state.metrics[0].label,
                          time: state.metrics[0].value,
                          badge: "Present",
                          badgeColor: state.metrics[0].color,
                          subtitle: "Staff present",
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (state.metrics.length > 1)
                        Expanded(
                          child: _OverviewBox(
                            cupertinoIcon: CupertinoIcons.clock,
                            label: state.metrics[1].label,
                            time: state.metrics[1].value,
                            badge: "Late",
                            badgeColor: state.metrics[1].color,
                            subtitle: "Staff late",
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (state.metrics.length > 2)
                    Row(
                      children: [
                        Expanded(
                          child: _OverviewBox(
                            cupertinoIcon: CupertinoIcons.airplane,
                            label: state.metrics[2].label,
                            time: state.metrics[2].value,
                            badge: "Leave",
                            badgeColor: state.metrics[2].color,
                            subtitle: "On leave",
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (state.metrics.length > 3)
                          Expanded(
                            child: _OverviewBox(
                              cupertinoIcon: CupertinoIcons.doc_text,
                              label: state.metrics[3].label,
                              time: state.metrics[3].value,
                              badge: "Requests",
                              badgeColor: state.metrics[3].color,
                              subtitle: "Pending actions",
                            ),
                          ),
                      ],
                    ),
                ],
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

          /// RECENT ACTIVITY
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
                      onTap: () {}, // TODO: Navigate to full history if needed
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
                  children: state.activities
                      .map(
                        (a) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _AdminActivityItem(
                            title: a.title,
                            time: a.time,
                            subtitle: a.subtitle,
                            isWarning: a.isWarning,
                          ),
                        ),
                      )
                      .toList(),
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
                  decoration: const BoxDecoration(
                    color: Color(0xffeef1ff),
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

class _AdminActivityItem extends StatelessWidget {
  final String title;
  final String time;
  final String subtitle;
  final bool isWarning;

  const _AdminActivityItem({
    required this.title,
    required this.time,
    required this.subtitle,
    this.isWarning = false,
  });

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
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: isWarning ? Colors.orange[800] : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
