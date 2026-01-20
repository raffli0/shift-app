import 'package:geocoding/geocoding.dart';

class ReverseGeocoding {
  static Future<String> getAddress(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isEmpty) return "Alamat tidak ditemukan";

      final p = placemarks.first;

      return "${p.street}, ${p.subLocality}, ${p.locality}";
    } catch (e) {
      return "Alamat tidak ditemukan";
    }
  }
}
