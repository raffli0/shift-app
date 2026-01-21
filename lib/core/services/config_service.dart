import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class ConfigService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'settings';

  // Default fallback values
  static const double _defaultLat = -6.93586;
  static const double _defaultLng = 107.63932;
  static const double _defaultRadius = 50.0;

  Future<Map<String, dynamic>> getOfficeConfig(String companyId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(companyId).get();
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

  Future<void> updateOfficeConfig(
    String companyId,
    double lat,
    double lng,
    double radius,
  ) async {
    await _firestore.collection(_collection).doc(companyId).set({
      'latitude': lat,
      'longitude': lng,
      'radius': radius,
    });
  }

  // Helper to get LatLng object directly
  Future<LatLng> getOfficeLocation(String companyId) async {
    final data = await getOfficeConfig(companyId);
    return LatLng(
      (data['latitude'] as num).toDouble(),
      (data['longitude'] as num).toDouble(),
    );
  }

  // Helper to get radius directly
  Future<double> getOfficeRadius(String companyId) async {
    final data = await getOfficeConfig(companyId);
    return (data['radius'] as num).toDouble();
  }

  // Shift Configuration
  Future<Map<String, String>> getShiftConfig(String companyId) async {
    final data = await getOfficeConfig(companyId);
    return {
      'start_time': data['start_time'] as String? ?? '09:00',
      'end_time': data['end_time'] as String? ?? '17:00',
    };
  }

  Future<void> updateShiftConfig(
    String companyId,
    String startTime,
    String endTime,
  ) async {
    await _firestore.collection(_collection).doc(companyId).update({
      'start_time': startTime,
      'end_time': endTime,
    });
  }
}
