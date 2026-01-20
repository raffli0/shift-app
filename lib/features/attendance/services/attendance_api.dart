import 'dart:convert';
import 'package:http/http.dart' as http;

class AttendanceApi {
  static const String baseUrl = 'https://api.yourdomain.com';

  static Future<bool> checkIn({
    required String employeeId,
    required double latitude,
    required double longitude,
    required String address,
    required bool insideOffice,
  }) async {
    final payload = {
      "employee_id": employeeId,
      "type": "check_in",
      "timestamp": DateTime.now().toUtc().toIso8601String(),
      "latitude": latitude,
      "longitude": longitude,
      "address": address,
      "inside_office": insideOffice,
      "device": "mobile",
      "app_version": "1.0.0",
    };

    final response = await http.post(
      Uri.parse('$baseUrl/attendance'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    return response.statusCode == 200;
  }
}
