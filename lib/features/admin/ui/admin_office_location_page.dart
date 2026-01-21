import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../../../shared/widgets/app_header.dart';

class AdminOfficeLocationPage extends StatefulWidget {
  const AdminOfficeLocationPage({super.key});

  @override
  State<AdminOfficeLocationPage> createState() =>
      _AdminOfficeLocationPageState();
}

class _AdminOfficeLocationPageState extends State<AdminOfficeLocationPage> {
  LatLng? _selectedLocation;
  double _radius = 100.0;
  bool _hasChanges = false;
  late final MapController _mapController;

  // Design Constants
  static const kBgColor = Color(0xFF0E0F13);
  static const kSurfaceColor = Color(0xFF151821);
  static const kAccentColor = Color(0xFF7C7FFF);
  static const kTextPrimary = Color(0xFFEDEDED);
  static const kTextSecondary = Color(0xFF9AA0AA);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    // Safe to read state in initState for initial values
    final state = context.read<AdminBloc>().state;
    _selectedLocation = state.officeLocation;
    _radius = state.allowedRadius;
  }

  void _onSave() {
    if (_selectedLocation != null) {
      context.read<AdminBloc>().add(
        AdminUpdateOfficeSettings(
          location: _selectedLocation!,
          radius: _radius,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Office settings updated successfully"),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      setState(() {
        _hasChanges = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminBloc, AdminState>(
      listener: (context, state) {
        if (!mounted) return;
        // If we haven't selected anything locally yet, sync with state
        if (_selectedLocation == null && state.officeLocation != null) {
          setState(() {
            _selectedLocation = state.officeLocation;
            _radius = state.allowedRadius;
          });
        }
      },
      child: Scaffold(
        backgroundColor: kBgColor,
        body: SafeArea(
          child: Column(
            children: [
              AppHeader(
                title: "Office Location",
                showAvatar: false,
                showBell: false,
                onBack: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Map Container
                      Container(
                        padding: const EdgeInsets.all(16),
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
                              "Set Location",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: kTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Tap on the map to set the office coordinates.",
                              style: TextStyle(
                                fontSize: 14,
                                color: kTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 350,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: FlutterMap(
                                  mapController: _mapController,
                                  options: MapOptions(
                                    initialCenter:
                                        _selectedLocation ??
                                        const LatLng(37.7749, -122.4194),
                                    initialZoom: 15.0,
                                    onTap: (tapPosition, point) {
                                      setState(() {
                                        _selectedLocation = point;
                                        _hasChanges = true;
                                      });
                                    },
                                    interactionOptions:
                                        const InteractionOptions(
                                          flags: InteractiveFlag.all,
                                        ),
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate:
                                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                      userAgentPackageName: 'com.shift.app',
                                    ),
                                    if (_selectedLocation != null)
                                      MarkerLayer(
                                        markers: [
                                          Marker(
                                            point: _selectedLocation!,
                                            width: 40,
                                            height: 40,
                                            child: const Icon(
                                              Icons.location_on,
                                              color: kAccentColor,
                                              size: 40,
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (_selectedLocation != null)
                                      CircleLayer(
                                        circles: [
                                          CircleMarker(
                                            point: _selectedLocation!,
                                            radius: _radius,
                                            useRadiusInMeter: true,
                                            color: kAccentColor.withValues(
                                              alpha: 0.2,
                                            ),
                                            borderColor: kAccentColor,
                                            borderStrokeWidth: 2,
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Attendance Radius",
                                  style: TextStyle(
                                    color: kTextPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "${_radius.toInt()}m",
                                  style: const TextStyle(
                                    color: kAccentColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove,
                                    color: kTextSecondary,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _radius = (_radius - 10).clamp(10, 1000);
                                      _hasChanges = true;
                                    });
                                  },
                                ),
                                Expanded(
                                  child: SliderTheme(
                                    data: SliderThemeData(
                                      activeTrackColor: kAccentColor,
                                      inactiveTrackColor: kAccentColor
                                          .withValues(alpha: 0.2),
                                      thumbColor: kAccentColor,
                                      overlayColor: kAccentColor.withValues(
                                        alpha: 0.1,
                                      ),
                                      trackHeight: 4,
                                    ),
                                    child: Slider(
                                      value: _radius,
                                      min: 10,
                                      max: 1000,
                                      divisions: 99,
                                      label: "${_radius.toInt()}m",
                                      onChanged: (value) {
                                        setState(() {
                                          _radius = value;
                                          _hasChanges = true;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add,
                                    color: kTextSecondary,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _radius = (_radius + 10).clamp(10, 1000);
                                      _hasChanges = true;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _hasChanges ? _onSave : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kAccentColor,
                            disabledBackgroundColor: kAccentColor.withValues(
                              alpha: 0.5,
                            ),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Save Changes",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
