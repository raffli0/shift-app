import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shift/shared/widgets/app_header.dart';
import '../../leave/ui/new_leave_form_page.dart';
import '../../leave/ui/leave_detail_page.dart';
import '../../leave/services/leave_service.dart';
import '../../leave/models/leave_request_model.dart';
import '../../auth/services/auth_service.dart';

class MyRequestsListPage extends StatefulWidget {
  const MyRequestsListPage({super.key});

  @override
  State<MyRequestsListPage> createState() => _MyRequestsListPageState();
}

class _MyRequestsListPageState extends State<MyRequestsListPage> {
  int filterIndex = 0;
  final filters = ['All', 'Pending', 'Approved', 'Rejected'];

  final _leaveService = LeaveService();
  final _authService = AuthService();
  List<LeaveRequestModel> _requests = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    try {
      final user = await _authService.checkAuthStatus();
      if (user != null) {
        final data = await _leaveService.getMyRequests(user.id);
        if (mounted) {
          setState(() {
            _requests = data;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error loading requests: $e");
      if (mounted) {
        setState(() {
          _errorMessage = "Error: $e"; // Show actual error for debugging
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0c202e),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: "Requests", showAvatar: false, showBell: false),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("CREATE NEW"),
                    const SizedBox(height: 12),
                    _buildCreateNew(),

                    const SizedBox(height: 24),
                    _buildFilter(),

                    const SizedBox(height: 24),
                    _sectionTitle("RECENT HISTORY"),
                    const SizedBox(height: 12),

                    SizedBox(
                      height:
                          500, // Explicit height for list or use shrinkWrap with physics
                      child: _buildRequestList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildRequestList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    // Filter requests
    final filtered = _requests.where((r) {
      if (filterIndex == 0) return true; // All
      if (filterIndex == 1) return r.status == 'pending';
      if (filterIndex == 2) return r.status == 'approved';
      if (filterIndex == 3) return r.status == 'rejected';
      return true;
    }).toList();

    if (filtered.isEmpty) {
      return const Center(
        child: Text(
          "No requests found",
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      physics:
          const NeverScrollableScrollPhysics(), // Handled by parent SingleChildScrollView
      shrinkWrap: true,
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final request = filtered[index];
        return _RequestHistoryCard(
          request: request, // Pass model
          icon: _getIconForType(request.type),
          title: request.type,
          subtitle: _formatDateRange(request.startDate, request.endDate),
          status: _capitalize(request.status),
          statusColor: _getColorForStatus(request.status),
          submitted: "Submitted ${_formatDate(request.createdAt)}",
        );
      },
    );
  }

  Widget _buildErrorWidget() {
    // Friendly error display
    final isNetworkError = _errorMessage!.contains("unavailable") || _errorMessage!.contains("network");
    final message = isNetworkError 
      ? "Connection failed. Please check your internet."
      : "Unable to load requests. Please try again.";

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, size: 48, color: Colors.white54),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
               setState(() {
                 _isLoading = true;
                 _errorMessage = null;
               });
               _loadRequests();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0c202e),
            ),
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  String _formatDateRange(DateTime start, DateTime end) {
    if (start.year == end.year &&
        start.month == end.month &&
        start.day == end.day) {
      return DateFormat("MMM dd").format(start);
    }
    return "${DateFormat("MMM dd").format(start)} - ${DateFormat("MMM dd").format(end)}";
  }

  String _formatDate(DateTime date) {
    // simple nice format
    // e.g. "2h ago" or actual date
    final diff = DateTime.now().difference(date);
    if (diff.inHours < 24) {
      return "${diff.inHours}h ago";
    } else if (diff.inDays < 7) {
      return "${diff.inDays}d ago";
    }
    return DateFormat("MMM dd, yyyy").format(date);
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'sick leave':
        return Icons.medical_services;
      case 'annual leave':
        return Icons.beach_access;
      case 'overtime':
        return Icons.timer;
      case 'shift swap':
        return Icons.swap_horiz;
      default:
        return Icons.event;
    }
  }

  Color _getColorForStatus(String status) {
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

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
    );
  }

  /// ================= CREATE NEW =================
  Widget _buildCreateNew() {
    return Row(
      children: [
        Expanded(
          child: _NewRequestButton(
            onTap: () {
              _showCreateRequestSheet(context);
            },
          ),
        ),
      ],
    );
  }

  /// ================= FILTER =================
  Widget _buildFilter() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: List.generate(filters.length, (i) {
          final selected = filterIndex == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => filterIndex = i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? Colors.blue : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  filters[i],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : Colors.black54,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NewRequestButton extends StatelessWidget {
  final VoidCallback onTap;

  const _NewRequestButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 96,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New Request',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Leave, Overtime, Shift Swap',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white, size: 28),
          ],
        ),
      ),
    );
  }
}

void _showCreateRequestSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RequestActionTile(
              icon: Icons.flight_takeoff,
              title: 'Leave',
              onTap: () {
                // Navigator.push(context, MaterialPageRoute(builder: (_) => LeavePage()));
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NewLeaveFormPage()),
                );
              },
            ),
            _RequestActionTile(
              icon: Icons.timer,
              title: 'Overtime',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _RequestActionTile(
              icon: Icons.swap_horiz,
              title: 'Shift Swap',
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    },
  );
}

class _RequestActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _RequestActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue, size: 28),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

/// ================= HISTORY CARD =================
class _RequestHistoryCard extends StatelessWidget {
  final LeaveRequestModel request;
  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final Color statusColor;
  final String submitted;

  const _RequestHistoryCard({
    required this.request,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusColor,
    required this.submitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: statusColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                submitted,
                style: const TextStyle(color: Colors.black45, fontSize: 12),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LeaveStatusPage(request: request),
                    ),
                  );
                },
                child: const Text(
                  "View Details ›",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
