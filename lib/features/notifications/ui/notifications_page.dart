import 'package:flutter/material.dart';
import '../../../shared/widgets/app_header.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  // Design Constants matches AdminHomePage
  static const kBgColor = Color(0xFF0E0F13);
  static const kSurfaceColor = Color(0xFF151821);
  static const kAccentColor = Color(0xFF7C7FFF);
  static const kTextPrimary = Color(0xFFEDEDED);
  static const kTextSecondary = Color(0xFF9AA0AA);

  @override
  Widget build(BuildContext context) {
    final notifications = [
      _NotifItem(
        title: "Leave Approved",
        body: "Your sick leave request for Oct 24 - 26 has been approved.",
        time: "2 hours ago",
        type: _NotifType.success,
      ),
      _NotifItem(
        title: "Check In Reminder",
        body: "Don't forget to check in before 09:15 AM.",
        time: "5 hours ago",
        type: _NotifType.info,
      ),
      _NotifItem(
        title: "Shift Update",
        body: "Your shift on Nov 01 has been swapped with Sarah J.",
        time: "1 day ago",
        type: _NotifType.warning,
      ),
      _NotifItem(
        title: "Payslip Available",
        body: "Your payslip for September 2025 is now available.",
        time: "2 days ago",
        type: _NotifType.info,
      ),
    ];

    return Scaffold(
      backgroundColor: kBgColor,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: "Notifications",
              showAvatar: false,
              showBell: false,
              onBack: () => Navigator.pop(context),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                itemCount: notifications.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return notifications[index];
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _NotifType { success, info, warning, error }

class _NotifItem extends StatelessWidget {
  final String title;
  final String body;
  final String time;
  final _NotifType type;

  const _NotifItem({
    required this.title,
    required this.body,
    required this.time,
    required this.type,
  });

  Color _getColor() {
    switch (type) {
      case _NotifType.success:
        return const Color(0xFF4ADE80); // Green
      case _NotifType.warning:
        return const Color(0xFFFACC15); // Yellow
      case _NotifType.error:
        return const Color(0xFFF87171); // Red
      case _NotifType.info:
        return NotificationPage.kAccentColor; // Purple
    }
  }

  IconData _getIcon() {
    switch (type) {
      case _NotifType.success:
        return Icons.check_circle_outline_rounded;
      case _NotifType.warning:
        return Icons.warning_amber_rounded;
      case _NotifType.error:
        return Icons.error_outline_rounded;
      case _NotifType.info:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    const surfaceColor = NotificationPage.kSurfaceColor;
    const textPrimary = NotificationPage.kTextPrimary;
    const textSecondary = NotificationPage.kTextSecondary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(_getIcon(), size: 20, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        color: textSecondary.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: const TextStyle(
                    color: textSecondary,
                    fontSize: 14,
                    height: 1.4,
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
