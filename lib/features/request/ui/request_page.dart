import 'package:flutter/material.dart';
import 'package:shift/shared/widgets/app_header.dart';

class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  int filterIndex = 0;

  final filters = ['All', 'Pending', 'Approved', 'Rejected'];

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

                    _RequestHistoryCard(
                      icon: Icons.medical_services,
                      title: "Sick Leave",
                      subtitle: "Oct 24 - Oct 26 • 3 Days",
                      status: "Pending",
                      statusColor: Colors.orange,
                      submitted: "Submitted 2h ago",
                    ),
                    _RequestHistoryCard(
                      icon: Icons.timer,
                      title: "Overtime",
                      subtitle: "Oct 20 • 4 hours",
                      status: "Approved",
                      statusColor: Colors.green,
                      submitted: "Submitted 3d ago",
                    ),
                    _RequestHistoryCard(
                      icon: Icons.swap_horiz,
                      title: "Shift Swap",
                      subtitle: "Nov 01 with Sarah J.",
                      status: "Rejected",
                      statusColor: Colors.red,
                      submitted: "Submitted 1w ago",
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
                Navigator.pop(context);
                // Navigator.push(context, MaterialPageRoute(builder: (_) => LeavePage()));
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
  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final Color statusColor;
  final String submitted;

  const _RequestHistoryCard({
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
              const Text(
                "View Details ›",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
