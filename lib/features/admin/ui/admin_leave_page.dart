import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_state.dart';
import '../bloc/admin_event.dart';
import '../../../shared/widgets/app_header.dart';

import 'package:intl/intl.dart';

class AdminLeavePage extends StatefulWidget {
  const AdminLeavePage({super.key});

  // Design Constants matches AdminHomePage
  static const kBgColor = Color(0xFF0E0F13);
  static const kSurfaceColor = Color(0xFF151821);
  static const kAccentColor = Color(0xFF7C7FFF);
  static const kTextPrimary = Color(0xFFEDEDED);
  static const kTextSecondary = Color(0xFF9AA0AA);

  @override
  State<AdminLeavePage> createState() => _AdminLeavePageState();
}

class _AdminLeavePageState extends State<AdminLeavePage> {
  String _selectedFilter = 'All'; // All, Pending, Approved, Rejected

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminLeavePage.kBgColor,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              title: "Leave Requests",
              showAvatar: true,
              showBell: false,
            ),

            // Header with Date & Filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('EEEE, d MMM').format(DateTime.now()),
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  FButton(
                    onPress: () => _showFilterSheet(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.filter_list, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          _selectedFilter == 'All' ? "Filter" : _selectedFilter,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: AdminLeavePage.kSurfaceColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          "Leave History",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Expanded(
                        child: BlocBuilder<AdminBloc, AdminState>(
                          builder: (context, state) {
                            // Filter Logic
                            final filteredList = state.leaveRequests.where((
                              leave,
                            ) {
                              if (_selectedFilter == 'All') return true;
                              if (_selectedFilter == 'Pending')
                                return leave.isPending;
                              if (_selectedFilter == 'Approved') {
                                return !leave.isPending && leave.isApproved;
                              }
                              if (_selectedFilter == 'Rejected') {
                                return !leave.isPending && !leave.isApproved;
                              }
                              return true;
                            }).toList();

                            if (filteredList.isEmpty) {
                              return Center(
                                child: Text(
                                  _selectedFilter == 'All'
                                      ? "No leave requests found."
                                      : "No $_selectedFilter requests.",
                                  style: const TextStyle(
                                    color: AdminLeavePage.kTextSecondary,
                                  ),
                                ),
                              );
                            }
                            return ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              itemCount: filteredList.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final leave = filteredList[index];
                                return _LeaveRequestCard(
                                  id: leave.id,
                                  name: leave.name,
                                  type: leave.type,
                                  dates: leave.dates,
                                  reason: leave.reason,
                                  isPending: leave.isPending,
                                  isApproved: leave.isApproved,
                                  imageUrl: leave.imageUrl,
                                );
                              },
                            );
                          },
                        ),
                      ),
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

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AdminLeavePage.kSurfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Filter by Status",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...['All', 'Pending', 'Approved', 'Rejected'].map((status) {
                final isSelected = _selectedFilter == status;
                return ListTile(
                  title: Text(
                    status,
                    style: TextStyle(
                      color: isSelected
                          ? AdminLeavePage.kAccentColor
                          : Colors.white70,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check,
                          color: AdminLeavePage.kAccentColor,
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedFilter = status;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _LeaveRequestCard extends StatelessWidget {
  final String id;
  final String name;
  final String type;
  final String dates;
  final String reason;
  final bool isPending;
  final bool isApproved;
  final String imageUrl;

  const _LeaveRequestCard({
    required this.id,
    required this.name,
    required this.type,
    required this.dates,
    required this.reason,
    required this.isPending,
    this.isApproved = false,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminLeavePage.kBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FAvatar(
                fallback: Text(name.substring(0, 2).toUpperCase()),
                image: NetworkImage(imageUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: AdminLeavePage.kTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type,
                      style: const TextStyle(
                        color: AdminLeavePage.kAccentColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  dates,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AdminLeavePage.kTextSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            reason,
            style: const TextStyle(
              color: AdminLeavePage.kTextSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          if (isPending)
            Row(
              children: [
                Expanded(
                  child: FButton(
                    onPress: () {
                      context.read<AdminBloc>().add(
                        AdminLeaveStatusUpdated(
                          leaveId: id,
                          status: 'rejected',
                        ),
                      );
                    },
                    child: const Text(
                      'Reject',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FButton(
                    onPress: () {
                      context.read<AdminBloc>().add(
                        AdminLeaveStatusUpdated(
                          leaveId: id,
                          status: 'approved',
                        ),
                      );
                    },
                    child: const Text('Approve'),
                  ),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: (isApproved ? Colors.green : Colors.red).withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isApproved ? Icons.check_circle : Icons.cancel,
                    color: isApproved ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isApproved ? "Approved" : "Rejected",
                    style: TextStyle(
                      color: isApproved ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
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
