// lib/api/api_helper.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiHelper {
  /// Generic POST Request
  static Future<Map<String, dynamic>> post({
    required String url,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': decoded};
      } else {
        return {
          'success': false,
          'error': decoded['message'] ?? 'Something went wrong'
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Generic GET Request
  static Future<Map<String, dynamic>> get({
    required String url,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': decoded};
      } else {
        return {
          'success': false,
          'error': decoded['message'] ?? 'Something went wrong'
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
