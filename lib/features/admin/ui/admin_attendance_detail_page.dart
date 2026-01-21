
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import '../models/admin_models.dart';
import '../../../shared/widgets/app_header.dart';

class AdminAttendanceDetailPage extends StatelessWidget {
  final AdminAttendance attendance;

  const AdminAttendanceDetailPage({super.key, required this.attendance});

  // Design Constants (Synced with AdminHomePage)
  static const kBgColor = Color(0xFF0E0F13);
  static const kSurfaceColor = Color(0xFF151821);
  static const kAccentColor = Color(0xFF7C7FFF);
  static const kTextPrimary = Color(0xFFEDEDED);
  static const kTextSecondary = Color(0xFF9AA0AA);
  static const kIconPrimary = Color(0xFF8A8F98);

  @override
  Widget build(BuildContext context) {
    // Only show map if valid coordinates are present
    final hasValidCoordinates =
        attendance.latitude != 0.0 && attendance.longitude != 0.0;
    final center = LatLng(attendance.latitude, attendance.longitude);

    return Scaffold(
      backgroundColor: kBgColor,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: "Attendance Details",
              showAvatar: false,
              showBell: false,
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    // Profile Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: kSurfaceColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Column(
                        children: [
                          FAvatar(
                            fallback: Text(
                              attendance.name.substring(0, 2).toUpperCase(),
                              style: const TextStyle(color: kTextPrimary),
                            ),
                            image: attendance.imageUrl.isNotEmpty
                                ? NetworkImage(attendance.imageUrl)
                                : const NetworkImage(
                                    'https://i.pravatar.cc/300',
                                  ), // Fallback placeholder if empty
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            attendance.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: kTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            attendance.role,
                            style: const TextStyle(
                              color: kTextSecondary,
                              fontSize: 14,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _StatusBadge(
                            status: attendance.status,
                            color: attendance.statusColor,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Details Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: kSurfaceColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Check-in Information",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: kTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _DetailRow(
                            icon: Icons.access_time_rounded,
                            label: "Log Time",
                            value: attendance.time,
                          ),
                          const SizedBox(height: 20),
                          Divider(color: Colors.white.withValues(alpha: 0.05)),
                          const SizedBox(height: 20),
                          _DetailRow(
                            icon: Icons.location_on_rounded,
                            label: "Work Location",
                            value: attendance.location,
                          ),
                          const SizedBox(height: 20),
                          Divider(color: Colors.white.withValues(alpha: 0.05)),
                          const SizedBox(height: 20),
                          _DetailRow(
                            icon: Icons.calendar_today_rounded,
                            label: "Entry Date",
                            value: DateFormat(
                              'MMMM dd, yyyy',
                            ).format(DateTime.now()),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Map Section
                    if (hasValidCoordinates) ...[
                      Container(
                        width: double.infinity,
                        height: 280,
                        decoration: BoxDecoration(
                          color: kSurfaceColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: center,
                            initialZoom: 15.0,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.shift.app',
                              tileBuilder: (context, widget, tile) {
                                return ColorFiltered(
                                  colorFilter: const ColorFilter.mode(
                                    Colors.grey,
                                    BlendMode.saturation,
                                  ),
                                  child: Opacity(opacity: 0.7, child: widget),
                                );
                              },
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: center,
                                  width: 48,
                                  height: 48,
                                  child: const Icon(
                                    Icons.location_pin,
                                    color: kAccentColor,
                                    size: 40,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Face Verification Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: kSurfaceColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Verification Proof",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: kTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (attendance.imageUrl.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                children: [
                                  Image.network(
                                    attendance.imageUrl,
                                    height: 240,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            Colors.black.withValues(alpha: 0.8),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                      child: Row(
                                        children: const [
                                          Icon(
                                            Icons.verified_user_rounded,
                                            color: Colors.greenAccent,
                                            size: 16,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            "Biometric Verified",
                                            style: TextStyle(
                                              color: Colors.greenAccent,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Container(
                              height: 100,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.02),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Text(
                                  "No image proof available",
                                  style: TextStyle(color: kTextSecondary),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusBadge({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(
            top: 2,
          ), // Align icon with the first line of text
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AdminAttendanceDetailPage.kIconPrimary,
            size: 18,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AdminAttendanceDetailPage.kTextSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AdminAttendanceDetailPage.kTextPrimary,
                  height: 1.4,
                ),
                maxLines: 3, // Allow up to 3 lines for long addresses
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
