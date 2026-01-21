import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class AttendanceApi {
  static const String baseUrl =
      'https://raffdev.my.id/api/upload_attendance.php'; //api custom

  static Future<String?> checkIn({
    required String employeeId,
    required File photo,
    required double latitude,
    required double longitude,
    required String address,
    required bool insideOffice,
  }) async {
    final uri = Uri.parse(baseUrl);

    final request = http.MultipartRequest('POST', uri);

    // ---------- FORM FIELDS ----------
    request.fields['user_id'] = employeeId;
    request.fields['type'] = 'checkin';
    request.fields['latitude'] = latitude.toString();
    request.fields['longitude'] = longitude.toString();
    request.fields['address'] = address;
    request.fields['inside_office'] = insideOffice ? '1' : '0';
    request.fields['timestamp'] = DateTime.now().toUtc().toIso8601String();
    request.fields['device'] = 'mobile';
    request.fields['app_version'] = '1.0.0';

    // ---------- FILE ----------
    request.files.add(
      await http.MultipartFile.fromPath(
        'photo', // HARUS sama dengan $_FILES['photo']
        photo.path,
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final body = await response.stream.bytesToString();
        developer.log('UPLOAD RESPONSE: $body', name: 'AttendanceApi');
        try {
          final json = jsonDecode(body);
          if (json['status'] == 'error') {
            developer.log(
              'API ERROR: ${json['message']}',
              name: 'AttendanceApi',
            );
            return null;
          }

          final path = json['path']?.toString();
          if (path != null && path.isNotEmpty) {
            return 'https://raffdev.my.id/$path';
          }
          return null;
        } catch (e) {
          developer.log('JSON PARSE ERROR: $e', name: 'AttendanceApi');
          return null; // upload success but parse failed
        }
      } else {
        developer.log(
          'UPLOAD FAILED: ${response.statusCode}',
          name: 'AttendanceApi',
        );
        return null;
      }
    } catch (e) {
      developer.log('UPLOAD ERROR: $e', name: 'AttendanceApi');
      return null;
    }
  }
}
