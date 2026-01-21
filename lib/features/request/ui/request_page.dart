import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shift/features/leave/ui/leave_detail_page.dart';
import 'package:shift/features/leave/ui/new_leave_form_page.dart';
import 'package:shift/shared/widgets/app_header.dart';
import '../../leave/services/leave_service.dart';
import '../../leave/models/leave_request_model.dart';
import '../../auth/services/auth_service.dart';

class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  int filterIndex = 0;
  final filters = ['All', 'Pending', 'Approved', 'Rejected'];

  // Design Constants
  static const kBgColor = Color(0xFF0E0F13);
  static const kSurfaceColor = Color(0xFF151821);
  static const kAccentColor = Color(0xFF7C7FFF);
  static const kTextPrimary = Color(0xFFEDEDED);
  static const kTextSecondary = Color(0xFF9AA0AA);

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
          _errorMessage = "Failed to load requests";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
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
      return Center(
        child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
      );
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
        color: kTextSecondary,
        fontWeight: FontWeight.w600,
        fontSize: 12,
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
        color: kSurfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
                  color: selected ? kAccentColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  filters[i],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : kTextSecondary,
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
          color: _RequestsPageState.kAccentColor,
          borderRadius: BorderRadius.circular(16),
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
          color: _RequestsPageState.kSurfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RequestActionTile(
              icon: Icons.flight_takeoff,
              title: 'Leave',
              onTap: () {
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
      leading: Icon(icon, color: _RequestsPageState.kAccentColor, size: 28),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: _RequestsPageState.kTextPrimary,
        ),
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
        color: _RequestsPageState.kSurfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.02)),
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
                        color: _RequestsPageState.kTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _RequestsPageState.kTextSecondary,
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
                style: TextStyle(
                  color: _RequestsPageState.kTextSecondary.withValues(
                    alpha: 0.6,
                  ),
                  fontSize: 12,
                ),
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
