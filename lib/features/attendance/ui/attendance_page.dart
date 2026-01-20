import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/widgets/app_header.dart';
import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_event.dart';
import '../bloc/attendance_state.dart';
import 'package:shift/core/services/location_service.dart';
import '../../face_liveness/ui/face_liveness_screen.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:forui/forui.dart';
import 'package:latlong2/latlong.dart';
import 'package:shift/core/services/office_location.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => LocationService(),
      dispose: (service) => service.dispose(),
      child: BlocProvider(
        create: (context) =>
            AttendanceBloc(locationService: context.read<LocationService>())
              ..add(AttendanceStarted()),
        child: const AttendanceView(),
      ),
    );
  }
}

class AttendanceView extends StatefulWidget {
  const AttendanceView({super.key});

  @override
  State<AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView> {
  final MapController _mapController = MapController();
  final double zoomLevel = 16.0;

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatAmPm(DateTime time) {
    return time.hour >= 12 ? 'PM' : 'AM';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AttendanceBloc, AttendanceState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFF0c202e),
          body: SafeArea(
            child: Column(
              children: [
                AppHeader(
                  title: "Attendance",
                  showAvatar: false,
                  showBell: false,
                ),
                const SizedBox(height: 5),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSegment(context, state),
                        const SizedBox(height: 20),
                        _buildClockCard(context, state),
                        const SizedBox(height: 20),
                        const SizedBox(height: 20),
                        _buildActionButton(context, state),
                      ],
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

  Widget _buildSegment(BuildContext context, AttendanceState state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _segmentButton(context, "Today's Attendance", 0, state.tabIndex == 0),
          _segmentButton(context, "Attendance List", 1, state.tabIndex == 1),
        ],
      ),
    );
  }

  Widget _segmentButton(
    BuildContext context,
    String text,
    int index,
    bool selected,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () =>
            context.read<AttendanceBloc>().add(AttendanceTabChanged(index)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClockCard(BuildContext context, AttendanceState state) {
    final LatLng center = state.userLatLng ?? OfficeConfig.officeLocation;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 220,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: center,
                      initialZoom: zoomLevel,
                      minZoom: 15,
                      maxZoom: 18.5,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://cartodb-basemaps-a.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png",
                      ),
                      CircleLayer(
                        circles: [
                          CircleMarker(
                            point: OfficeConfig.officeLocation,
                            color: Colors.blue.withValues(alpha: 0.25),
                            borderStrokeWidth: 2,
                            borderColor: Colors.blue,
                            useRadiusInMeter: true,
                            radius: OfficeConfig.officeRadius,
                          ),
                        ],
                      ),
                      if (state.userLatLng != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: state.userLatLng!,
                              width: 44,
                              height: 44,
                              child: const Icon(
                                Icons.person_pin_circle,
                                size: 44,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0x88000000)],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 240),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.greenAccent,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              state.currentAddress.isNotEmpty
                                  ? state.currentAddress
                                  : 'Detecting location...',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () {
                        if (state.userLatLng != null) {
                          _mapController.move(state.userLatLng!, zoomLevel);
                        }
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: state.isInsideOffice
                  ? Colors.green.withValues(alpha: 0.12)
                  : Colors.red.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  state.isInsideOffice ? Icons.check_circle : Icons.cancel,
                  size: 16,
                  color: state.isInsideOffice ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 6),
                Text(
                  state.isInsideOffice
                      ? 'Inside Office Area'
                      : 'Outside Office Area',
                  style: TextStyle(
                    color: state.isInsideOffice ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CURRENT STATUS',
                    style: TextStyle(color: Colors.black45, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getStatusText(state),
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    _formatTime(state.now),
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatAmPm(state.now),
                    style: const TextStyle(color: Colors.black45),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(Icons.verified_user, color: Colors.blue, size: 18),
              SizedBox(width: 8),
              Text(
                'Face ID & Location verified',
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  String _getStatusText(AttendanceState state) {
    if (state.mainStatus == AttendanceMainStatus.none) return "Clocked Out";
    if (state.breakStatus == BreakStatus.onBreak) return "On Break";
    return "Clocked In";
  }

  Widget _buildActionButton(BuildContext context, AttendanceState state) {
    final bloc = context.read<AttendanceBloc>();
    return Row(
      children: [
        Expanded(
          child: _attendanceButton(
            label: "Check In",
            disabledLabel: "Outside Area",
            icon: FIcons.logIn,
            color: Colors.green,
            active: state.mainStatus == AttendanceMainStatus.checkin,
            enabled:
                state.mainStatus == AttendanceMainStatus.none &&
                state.isInsideOffice,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FaceLivenessScreen(
                    callback: (success) {
                      if (success) {
                        bloc.add(AttendanceCheckInRequested());
                        _showSnackBar(context, true);
                      } else {
                        _showSnackBar(context, false);
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _attendanceButton(
            label: state.breakStatus == BreakStatus.onBreak
                ? "Off Break"
                : "Break",
            icon: state.breakStatus == BreakStatus.onBreak
                ? FIcons.play
                : FIcons.coffee,
            color: Colors.orange,
            active: state.breakStatus == BreakStatus.onBreak,
            enabled: state.mainStatus == AttendanceMainStatus.checkin,
            onTap: () {
              if (state.breakStatus == BreakStatus.onBreak) {
                bloc.add(AttendanceOffBreakRequested());
              } else {
                bloc.add(AttendanceBreakRequested());
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _attendanceButton(
            label: "Check Out",
            icon: FIcons.logOut,
            color: Colors.red,
            active: state.mainStatus == AttendanceMainStatus.checkout,
            enabled: state.mainStatus != AttendanceMainStatus.none,
            onTap: () => bloc.add(AttendanceCheckOutRequested()),
          ),
        ),
      ],
    );
  }

  void _showSnackBar(BuildContext context, bool success) {
    final message = success ? "Attendance Success" : "Attendance Failed";
    final color = success ? Colors.green : Colors.red;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  Widget _attendanceButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool active,
    required bool enabled,
    required VoidCallback onTap,
    String? disabledLabel,
  }) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: enabled ? 1.0 : 0.4,
      child: IgnorePointer(
        ignoring: !enabled,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: active
                ? color.withValues(alpha: 0.25)
                : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: enabled
                  ? (active ? color : color.withValues(alpha: 0.5))
                  : Colors.grey,
              width: active ? 2.2 : 1.3,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 28, color: enabled ? color : Colors.grey),
                const SizedBox(height: 8),
                Text(
                  enabled ? label : (disabledLabel ?? label),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: enabled ? color : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
