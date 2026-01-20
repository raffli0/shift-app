import 'package:latlong2/latlong.dart';

import 'package:shared_preferences/shared_preferences.dart';

class OfficeConfig {
  static const String _latKey = 'office_lat';
  static const String _lngKey = 'office_lng';
  static const String _radiusKey = 'office_radius';

  // Default values
  static LatLng officeLocation = const LatLng(-6.93586, 107.63932);
  static double officeRadius = 50.0;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(_latKey);
    final lng = prefs.getDouble(_lngKey);
    final radius = prefs.getDouble(_radiusKey);

    if (lat != null && lng != null) {
      officeLocation = LatLng(lat, lng);
    }
    if (radius != null) {
      officeRadius = radius;
    }
  }

  static Future<void> save(LatLng location, double radius) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_latKey, location.latitude);
    await prefs.setDouble(_lngKey, location.longitude);
    await prefs.setDouble(_radiusKey, radius);

    officeLocation = location;
    officeRadius = radius;
  }
}
