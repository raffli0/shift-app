import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:forui/forui.dart';
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

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
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
        const SnackBar(
          content: Text("Office settings updated successfully"),
          backgroundColor: Colors.green,
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
        if (_selectedLocation == null && state.officeLocation != null) {
          setState(() {
            _selectedLocation = state.officeLocation;
            _radius = state.allowedRadius;
          });
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0c202e),
        body: SafeArea(
          child: Column(
            children: [
              AppHeader(
                title: "Setup Office Location",
                showAvatar: false,
                showBell: false,
                onBack: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Location Section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xfffbfbff),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Office Location",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Tap on the map to set the office coordinates.",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 300,
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
                                              Icons.location_pin,
                                              color: Colors.red,
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
                                            color: Colors.blue.withValues(
                                              alpha: 0.2,
                                            ),
                                            borderColor: Colors.blue,
                                            borderStrokeWidth: 2,
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              "Attendance Radius: ${_radius.toInt()} meters",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Slider(
                              value: _radius,
                              min: 10,
                              max: 1000,
                              divisions: 99,
                              label: "${_radius.toInt()}m",
                              activeColor: const Color(0xff5a64d6),
                              onChanged: (value) {
                                setState(() {
                                  _radius = value;
                                  _hasChanges = true;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Save Button
                      FButton(
                        onPress: _hasChanges ? _onSave : null,
                        child: const Text("Save Settings"),
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
