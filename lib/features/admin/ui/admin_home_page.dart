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

  // Design Constants
  static const kBgColor = Color(0xFF0E0F13);
  static const kSurfaceColor = Color(0xFF151821);
  static const kAccentColor = Color(0xFF7C7FFF);
  static const kTextPrimary = Color(0xFFEDEDED);
  static const kTextSecondary = Color(0xFF9AA0AA);
  static const kIconPrimary = Color(0xFF8A8F98);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Sticky HEADER
            const AppHeader(title: "", showAvatar: true, showBell: true),
            const SizedBox(height: 10),
            Expanded(
              child: BlocBuilder<AdminBloc, AdminState>(
                builder: (context, state) {
                  if (state.status == AdminStatus.loading) {
                    return const Center(
                      child: CircularProgressIndicator(color: kAccentColor),
                    );
                  }
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, authState) {
                              return _buildGreeting(authState.user?.fullName);
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildOverviewSection(state),
                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Divider(
                            color: Colors.white.withValues(alpha: 0.05),
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildRecentActivity(state),
                        const SizedBox(height: 40),
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

  Widget _buildGreeting(String? name) {
    final firstName = name?.split(' ').first ?? 'Admin';
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
          "Ready for the day, $firstName.",
          style: const TextStyle(
            color: kTextPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w500, // Medium, calm
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewSection(AdminState state) {
    // Determine metrics (fallback to 0 if empty)
    final present = state.metrics.isNotEmpty ? state.metrics[0].value : "0";
    final late = state.metrics.length > 1 ? state.metrics[1].value : "0";
    final leave = state.metrics.length > 2 ? state.metrics[2].value : "0";
    final requests = state.metrics.length > 3 ? state.metrics[3].value : "0";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              _DateSelector(
                dateText: DateFormat("MMM dd, yyyy").format(selectedDate),
                onTap: () => _openCalendar(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: "Present",
                  value: present,
                  icon: CupertinoIcons.person_2,
                  trend: "On track",
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: "Late",
                  value: late,
                  icon: CupertinoIcons.clock,
                  isWarning: true,
                  trend: "Needs attention",
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: "On Leave",
                  value: leave,
                  icon: CupertinoIcons.airplane,
                  trend: "Scheduled",
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: "Requests",
                  value: requests,
                  icon: CupertinoIcons.doc_text,
                  trend: "Pending review",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(AdminState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Activity",
            style: TextStyle(
              color: kTextPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          if (state.activities.isEmpty)
            const Text(
              "No activity recorded yet today.",
              style: TextStyle(color: kTextSecondary, fontSize: 14),
            )
          else
            Column(
              children: state.activities.map((a) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ActivityTile(
                    title: a.title,
                    subtitle: a.subtitle,
                    time: a.time,
                    isWarning: a.isWarning,
                  ),
                );
              }).toList(),
            ),
        ],
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
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(color: Colors.black.withValues(alpha: 0.5)),
                ),
              ),
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kSurfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                child: FCalendar(
                  controller: FCalendarController.date(
                    initialSelection: selectedDate,
                  ),
                  start: DateTime(2020),
                  end: DateTime(2030),
                  onPress: (date) {
                    setState(() => selectedDate = date);
                    Navigator.pop(context);
                  },
                  // Note: FCalendar styling might need adjustment to fit dark mode perfectly
                  // but standard widget usually adapts or we accept default for now.
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isWarning;
  final String trend;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.isWarning = false,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _AdminHomePageState.kSurfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: _AdminHomePageState.kIconPrimary),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: _AdminHomePageState.kTextSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: _AdminHomePageState.kTextPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w400, // Light and clean
            ),
          ),
          const SizedBox(height: 4),
          Text(
            trend,
            style: TextStyle(
              color: isWarning
                  ? const Color(0xFFE06C75)
                  : _AdminHomePageState.kTextSecondary.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final bool isWarning;

  const _ActivityTile({
    required this.title,
    required this.subtitle,
    required this.time,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _AdminHomePageState.kSurfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.02)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _AdminHomePageState.kTextPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: isWarning
                      ? const Color(0xFFE06C75)
                      : _AdminHomePageState.kTextSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Text(
            time,
            style: TextStyle(
              color: _AdminHomePageState.kTextSecondary.withValues(alpha: 0.5),
              fontSize: 12,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  final String dateText;
  final VoidCallback onTap;

  const _DateSelector({required this.dateText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _AdminHomePageState.kSurfaceColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            const Icon(
              CupertinoIcons.calendar,
              size: 14,
              color: _AdminHomePageState.kIconPrimary,
            ),
            const SizedBox(width: 8),
            Text(
              dateText,
              style: const TextStyle(
                color: _AdminHomePageState.kTextSecondary,
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
