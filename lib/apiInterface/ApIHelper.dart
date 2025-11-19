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
  /// Generic DELETE request – sends ONLY Bearer token in header
  static Future<Map<String, dynamic>> delete({
    required String url,
    required String token,
    BuildContext? context,
    bool showLoader = false,
  }) async {
    try {
      if (showLoader && context != null) ApiLoader.show(context);

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',   // ✅ Only header needed
        },
      );

      if (showLoader && context != null) ApiLoader.hide();

      Map<String, dynamic>? decoded;
      if (response.body.isNotEmpty) {
        try {
          decoded = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (_) {
          decoded = null;
        }
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': decoded};
      } else {
        return {
          'success': false,
          'error': decoded?['message'] ?? 'Something went wrong'
        };
      }
    } catch (e) {
      if (showLoader && context != null) ApiLoader.hide();
      return {'success': false, 'error': e.toString()};
    }
  }
  /// Generic GET Request with Bearer token & optional loader
  static Future<Map<String, dynamic>> getWithAuth({
    required String url,
    required String token,
    BuildContext? context,
    bool showLoader = false,
  }) async {
    try {
      if (showLoader && context != null) ApiLoader.show(context);

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (showLoader && context != null) ApiLoader.hide();

      final decoded = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': decoded};
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'error': 'Unauthorized. Please log in again.',
        };
      } else {
        return {
          'success': false,
          'error': decoded['message'] ?? 'Something went wrong',
        };
      }
    } catch (e) {
      if (showLoader && context != null) ApiLoader.hide();
      return {'success': false, 'error': e.toString()};
    }
  }

}
