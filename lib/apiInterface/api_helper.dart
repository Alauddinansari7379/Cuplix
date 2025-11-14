import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'ApiLoader.dart';

class ApiHelper {
  /// Generic POST Request with optional loader
  static Future<Map<String, dynamic>> post({
    required String url,
    required Map<String, dynamic> body,
    BuildContext? context,
    bool showLoader = false, // 👈 new parameter added
  }) async {
    try {
      if (showLoader && context != null) ApiLoader.show(context);

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (showLoader && context != null) ApiLoader.hide();

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
      if (showLoader && context != null) ApiLoader.hide();
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Generic GET Request with optional loader
  static Future<Map<String, dynamic>> get({
    required String url,
    BuildContext? context,
    bool showLoader = false, // 👈 new parameter added
  }) async {
    try {
      if (showLoader && context != null) ApiLoader.show(context);

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (showLoader && context != null) ApiLoader.hide();

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
      if (showLoader && context != null) ApiLoader.hide();
      return {'success': false, 'error': e.toString()};
    }
  }
}
