import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:shift/features/auth/bloc/auth_state.dart';
import '../../auth/bloc/auth_bloc.dart';
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
            const AppHeader(title: "", showAvatar: true, showBell: true),
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
                          child: BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, authState) {
                              return _buildGreeting(authState.user?.fullName);
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildOverviewCard(state),
                        const SizedBox(height: 20),
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
  Widget _buildGreeting(String? name) {
    final firstName = name?.split(' ').first ?? 'Admin';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat('EEEE, MMM dd').format(DateTime.now()),
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          "Welcome back, $firstName!",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
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

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _OverviewBox(
                        cupertinoIcon: CupertinoIcons.person_2,
                        label: "Present",
                        time: state.metrics.isNotEmpty
                            ? state.metrics[0].value
                            : "0",
                        badge: state.metrics.isNotEmpty
                            ? state.metrics[0].label
                            : "Staff",
                        badgeColor: Colors.green,
                        subtitle: "Staff present",
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _OverviewBox(
                        cupertinoIcon: CupertinoIcons.clock,
                        label: "Late",
                        time: state.metrics.length > 1
                            ? state.metrics[1].value
                            : "0",
                        badge: state.metrics.length > 1
                            ? state.metrics[1].label
                            : "Today",
                        badgeColor: Colors.orange,
                        subtitle: "Staff late",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _OverviewBox(
                        cupertinoIcon: CupertinoIcons.airplane,
                        label: "Leave",
                        time: state.metrics.length > 2
                            ? state.metrics[2].value
                            : "0",
                        badge: state.metrics.length > 2
                            ? state.metrics[2].label
                            : "Today",
                        badgeColor: Colors.purple,
                        subtitle: "On leave",
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _OverviewBox(
                        cupertinoIcon: CupertinoIcons.doc_text,
                        label: "Requests",
                        time: state.metrics.length > 3
                            ? state.metrics[3].value
                            : "0",
                        badge: state.metrics.length > 3
                            ? state.metrics[3].label
                            : "Pending",
                        badgeColor: Colors.red,
                        subtitle: "Pending actions",
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
                      onTap: () {},
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
  const _OverviewBox({
    this.cupertinoIcon,
    required this.label,
    required this.time,
    required this.badge,
    required this.badgeColor,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            time,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              badge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: badgeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
