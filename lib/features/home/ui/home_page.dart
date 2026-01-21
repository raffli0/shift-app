import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:shift/shared/widgets/app_dialog.dart';
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

  // Design Constants
  static const kBgColor = Color(0xFF0E0F13);
  static const kSurfaceColor = Color(0xFF151821);
  static const kAccentColor = Color(0xFF7C7FFF);
  static const kTextPrimary = Color(0xFFEDEDED);
  static const kTextSecondary = Color(0xFF9AA0AA);
  static const kIconPrimary = Color(0xFF8A8F98);

  @override
  Widget build(BuildContext context) {
    // Select user here, in the build method of the generic widget
    final user = context.select((AuthBloc bloc) => bloc.state.user);

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: kBgColor,
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
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _buildGreeting(user),
                          ),
                          const SizedBox(height: 10),
                          _buildOverviewCard(state, user?.id ?? ''),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat('MMMM dd, yyyy').format(DateTime.now()).toUpperCase(),
          style: const TextStyle(
            color: kTextSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "What's Up, $firstName!",
          style: const TextStyle(
            color: kTextPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  // OVERVIEW CARD
  Widget _buildOverviewCard(HomeState state, String userId) {
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Overview",
                style: TextStyle(
                  color: kTextPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              _DateBadge(
                dateText: DateFormat("MMM dd, yyyy").format(selectedDate),
                onTap: () => _openCalendar(context),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// OVERVIEW BOXES
          Column(
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
                      onTap: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          '/check-in',
                        );
                        if (mounted && userId.isNotEmpty) {
                          if (result == true) {
                            await AppDialog.showSuccess(
                              context: context,
                              title: "You're checked in",
                              message: "Attendance recorded successfully.",
                            );
                          }
                          if (!mounted) return;
                          context.read<HomeBloc>().add(
                            HomeRefreshRequested(userId),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _OverviewBox(
                      cupertinoIcon: CupertinoIcons.arrow_right_circle,
                      label: "Check out",
                      time: (hasCheckedIn && today.checkOutTime != null)
                          ? DateFormat("hh:mm a").format(today.checkOutTime!)
                          : "--:--",
                      badge: (hasCheckedIn && today.checkOutTime != null)
                          ? "Done"
                          : "n/a",
                      badgeColor: (hasCheckedIn && today.checkOutTime != null)
                          ? Colors.blue
                          : Colors.grey,
                      subtitle: (hasCheckedIn && today.checkOutTime != null)
                          ? "Checked out"
                          : "Not checked out",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        String breakTime = "--:--";
                        String breakSubtitle = "No break record";
                        String badge = "n/a";
                        Color badgeColor = Colors.grey;

                        if (hasCheckedIn &&
                            today.breaks != null &&
                            today.breaks!.isNotEmpty) {
                          final lastBreak = today.breaks!.last;
                          final startTime = (lastBreak['start'] as Timestamp)
                              .toDate();
                          final startStr = DateFormat(
                            "hh:mm a",
                          ).format(startTime);

                          if (lastBreak['end'] == null) {
                            breakTime = "$startStr - ...";
                            breakSubtitle = "Currently on break";
                            badge = "Active";
                            badgeColor = Colors.orange;
                          } else {
                            final endTime = (lastBreak['end'] as Timestamp)
                                .toDate();
                            final endStr = DateFormat(
                              "hh:mm a",
                            ).format(endTime);
                            breakTime = "$startStr - $endStr";
                            breakSubtitle = "Break finished";
                            badge = "Done";
                            badgeColor = Colors.green;
                          }
                        }

                        return _OverviewBox(
                          cupertinoIcon: CupertinoIcons.stopwatch,
                          label: "Break",
                          time: breakTime,
                          badge: badge,
                          badgeColor: badgeColor,
                          subtitle: breakSubtitle,
                          onTap: () {
                            if (!hasCheckedIn) {
                              AppDialog.showError(
                                context: context,
                                title: "Action not available",
                                message:
                                    "Please complete the previous step first.",
                              );
                              return;
                            }

                            bool isOnBreak = false;
                            if (today.breaks != null &&
                                today.breaks!.isNotEmpty) {
                              if (today.breaks!.last['end'] == null) {
                                isOnBreak = true;
                              }
                            }

                            if (isOnBreak) {
                              // End Break Popup
                              AppDialog.show(
                                context: context,
                                title: "End break?",
                                message: "Working time will resume.",
                                primaryButtonText: "End break",
                                secondaryButtonText: "Cancel",
                                onPrimary: () {
                                  context.read<HomeBloc>().add(
                                    HomeBreakToggled(today.id, false),
                                  );
                                },
                              );
                            } else {
                              // Start Break Popup
                              AppDialog.show(
                                context: context,
                                title: "Start break?",
                                message:
                                    "Working time will pause until you return.",
                                primaryButtonText: "Start break",
                                secondaryButtonText: "Cancel",
                                onPrimary: () {
                                  context.read<HomeBloc>().add(
                                    HomeBreakToggled(today.id, true),
                                  );
                                },
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        String overtimeTime = "--:--";
                        String badge = "n/a";
                        Color badgeColor = Colors.grey;
                        String subtitle = "No overtime";

                        if (hasCheckedIn) {
                          final now = DateTime.now();
                          final endTime = today.checkOutTime ?? now;
                          final totalSession = endTime.difference(
                            today.checkInTime,
                          );

                          int totalBreakMinutes = 0;
                          if (today.breaks != null) {
                            for (var b in today.breaks!) {
                              final start = (b['start'] as Timestamp).toDate();
                              final end = b['end'] != null
                                  ? (b['end'] as Timestamp).toDate()
                                  : now;
                              totalBreakMinutes += end
                                  .difference(start)
                                  .inMinutes;
                            }
                          }

                          final netWorkMinutes =
                              totalSession.inMinutes - totalBreakMinutes;

                          // Assuming 8 hour work day (480 minutes)
                          final overtimeMinutes = netWorkMinutes - 480;

                          if (overtimeMinutes > 0) {
                            final h = overtimeMinutes ~/ 60;
                            final m = overtimeMinutes % 60;
                            overtimeTime = "${h}h ${m}m";
                            badge = "Extra";
                            badgeColor = Colors.purple;
                            subtitle = "Good job!";
                          } else {
                            overtimeTime = "00:00";
                            subtitle = "Not yet";
                          }
                        }

                        return _OverviewBox(
                          cupertinoIcon: CupertinoIcons.clock,
                          label: "Overtime",
                          time: overtimeTime,
                          badge: badge,
                          badgeColor: badgeColor,
                          subtitle: subtitle,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// DIVIDER
          Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
        ],
      ),
    );
  }

  Widget _buildRecentActivityList(List<AttendanceModel> activities) {
    if (activities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                  fontWeight: FontWeight.w500,
                  color: kTextPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/history'),
                child: const Text(
                  "See All",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: kAccentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: activities.map((activity) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _HomeViewState.kSurfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  cupertinoIcon,
                  size: 16,
                  color: _HomeViewState.kIconPrimary,
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: _HomeViewState.kTextSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      time,
                      style: const TextStyle(
                        color: _HomeViewState.kTextPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 12,
                      color: badgeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: _HomeViewState.kTextSecondary.withValues(alpha: 0.6),
                fontSize: 12,
              ),
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
          color: _HomeViewState.kSurfaceColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            const Icon(
              CupertinoIcons.calendar,
              size: 14,
              color: _HomeViewState.kIconPrimary,
            ),
            const SizedBox(width: 8),
            Text(
              dateText,
              style: const TextStyle(
                color: _HomeViewState.kTextSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _HomeViewState.kSurfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.02)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat("hh:mm a").format(activity.checkInTime),
                  style: const TextStyle(
                    color: _HomeViewState.kTextPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.checkInLocation,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _HomeViewState.kTextSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.status,
                  style: TextStyle(
                    fontSize: 12,
                    color: activity.status == 'Late'
                        ? Colors.orange
                        : const Color(0xFF4ADE80),
                  ),
                ),
              ],
            ),
          ),
          if (activity.checkInImageUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  activity.checkInImageUrl,
                  width: 50,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 50,
                    height: 40,
                    color: Colors.white.withValues(alpha: 0.05),
                    child: const Icon(
                      Icons.broken_image,
                      size: 16,
                      color: _HomeViewState.kIconPrimary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
