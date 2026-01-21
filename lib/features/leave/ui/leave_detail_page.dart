import 'package:flutter/material.dart';
import 'package:shift/shared/widgets/app_header.dart';

import '../../leave/models/leave_request_model.dart';
import 'package:intl/intl.dart';

class LeaveStatusPage extends StatelessWidget {
  final LeaveRequestModel request;

  // Design Constants
  static const kBgColor = Color(0xFF0E0F13);
  static const kSurfaceColor = Color(0xFF151821);
  static const kTextPrimary = Color(0xFFEDEDED);
  static const kTextSecondary = Color(0xFF9AA0AA);

  const LeaveStatusPage({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: "Request Details", showAvatar: false),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: kSurfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // STATUS BADGE
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            request.status,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _capitalize(request.status),
                          style: TextStyle(
                            color: _getStatusColor(request.status),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        request.type,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: kTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Submitted on ${DateFormat("MMM dd, yyyy").format(request.createdAt)}",
                        style: const TextStyle(color: kTextSecondary),
                      ),
                      const SizedBox(height: 32),

                      _DetailRow(
                        label: "From",
                        value: DateFormat(
                          "MMM dd, yyyy",
                        ).format(request.startDate),
                      ),
                      const SizedBox(height: 16),
                      _DetailRow(
                        label: "To",
                        value: DateFormat(
                          "MMM dd, yyyy",
                        ).format(request.endDate),
                      ),
                      const SizedBox(height: 16),
                      _DetailRow(
                        label: "Total Days",
                        value:
                            "${request.endDate.difference(request.startDate).inDays + 1} Days",
                      ),

                      if (request.reason.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        const Text(
                          "Reason",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: kTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          request.reason,
                          style: const TextStyle(
                            color: kTextPrimary,
                            height: 1.5,
                          ),
                        ),
                      ],

                      if (request.adminNote != null &&
                          request.adminNote!.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        const Text(
                          "Admin Note",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: kTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          request.adminNote!,
                          style: const TextStyle(
                            color: kTextPrimary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _capitalize(String s) =>
      s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : '';
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: LeaveStatusPage.kTextSecondary)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: LeaveStatusPage.kTextPrimary,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
