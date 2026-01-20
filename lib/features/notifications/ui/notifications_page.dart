import 'package:flutter/material.dart';
import 'package:shift/shared/widgets/app_header.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

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
      backgroundColor: const Color(0xFF0c202e),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              title: "Notifications",
              showAvatar: false,
              showBell: false,
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                itemCount: notifications.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 24),
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
        return Colors.green;
      case _NotifType.warning:
        return Colors.orange;
      case _NotifType.error:
        return Colors.red;
      case _NotifType.info:
        return const Color(0xff5a64d6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TIMELINE DOT
        Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            // Line could go here if we want strict timeline,
            // but for simple list, just dot is enough or standard ListView.
          ],
        ),
        const SizedBox(width: 16),

        // CONTENT
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    time,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                body,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
