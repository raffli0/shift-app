import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class ConfigService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'settings';
  static const String _docId = 'office';

  // Default fallback values
  static const double _defaultLat = -6.93586;
  static const double _defaultLng = 107.63932;
  static const double _defaultRadius = 50.0;

  Future<Map<String, dynamic>> getOfficeConfig() async {
    try {
      final doc = await _firestore.collection(_collection).doc(_docId).get();
      if (doc.exists && doc.data() != null) {
        return doc.data()!;
      }
      return {
        'latitude': _defaultLat,
        'longitude': _defaultLng,
        'radius': _defaultRadius,
      };
    } catch (e) {
      // In case of error (offline, permission), return defaults
      return {
        'latitude': _defaultLat,
        'longitude': _defaultLng,
        'radius': _defaultRadius,
      };
    }
  }

  Future<void> updateOfficeConfig(double lat, double lng, double radius) async {
    await _firestore.collection(_collection).doc(_docId).set({
      'latitude': lat,
      'longitude': lng,
      'radius': radius,
    });
  }

  // Helper to get LatLng object directly
  Future<LatLng> getOfficeLocation() async {
    final data = await getOfficeConfig();
    return LatLng(
      (data['latitude'] as num).toDouble(),
      (data['longitude'] as num).toDouble(),
    );
  }

  // Helper to get radius directly
  Future<double> getOfficeRadius() async {
    final data = await getOfficeConfig();
    return (data['radius'] as num).toDouble();
  }
}
