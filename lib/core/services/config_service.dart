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
  Future<Map<String, dynamic>> getShiftConfig(String companyId) async {
    final data = await getOfficeConfig(companyId);
    return {
      'start_time': data['start_time'] as String? ?? '09:00',
      'end_time': data['end_time'] as String? ?? '17:00',
      'tolerance_time': data['tolerance_time'] as int? ?? 0,
    };
  }

  Future<void> updateShiftConfig(
    String companyId,
    String startTime,
    String endTime,
    int toleranceTime,
  ) async {
    await _firestore.collection(_collection).doc(companyId).update({
      'start_time': startTime,
      'end_time': endTime,
      'tolerance_time': toleranceTime,
    });
  }

  // --- Multiple Shifts Implementation ---

  Stream<List<Map<String, dynamic>>> streamShifts(String companyId) {
    return _firestore
        .collection(_collection)
        .doc(companyId)
        .collection('shifts')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  Future<void> addShift(
    String companyId,
    Map<String, dynamic> shiftData,
  ) async {
    // Generate a new ID if not present
    await _firestore
        .collection(_collection)
        .doc(companyId)
        .collection('shifts')
        .add(shiftData);
  }

  Future<void> updateShift(
    String companyId,
    String shiftId,
    Map<String, dynamic> shiftData,
  ) async {
    await _firestore
        .collection(_collection)
        .doc(companyId)
        .collection('shifts')
        .doc(shiftId)
        .update(shiftData);
  }

  Future<void> deleteShift(String companyId, String shiftId) async {
    await _firestore
        .collection(_collection)
        .doc(companyId)
        .collection('shifts')
        .doc(shiftId)
        .delete();
  }
}
