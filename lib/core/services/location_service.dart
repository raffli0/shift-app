import 'dart:async';
import 'package:shift/core/services/office_location.dart';
import 'package:shift/utils/reverse_geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  StreamSubscription<Position>? _positionStream;

  Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    );
  }

  bool isInsideOffice(LatLng userLoc) {
    final distance = const Distance().as(
      LengthUnit.Meter,
      userLoc,
      OfficeConfig.officeLocation,
    );
    return distance <= OfficeConfig.officeRadius;
  }

  Future<String> getAddress(double lat, double lng) async {
    return await ReverseGeocoding.getAddress(lat, lng);
  }

  Future<void> dispose() async {
    await _positionStream?.cancel();
  }
}
