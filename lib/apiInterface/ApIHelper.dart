import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'ApiLoader.dart';

class ApiHelper {
  /// ---------------- LOG REQUEST / RESPONSE ---------------- ///
  static void _logRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    dynamic body,
  }) {
    debugPrint("⬆️ REQUEST [$method]");
    debugPrint("URL: $url");
    debugPrint("Headers: ${jsonEncode(headers)}");
    if (body != null) debugPrint("Body: ${jsonEncode(body)}");
  }

  static void _logResponse(http.Response response) {
    debugPrint("⬇️ RESPONSE");
    debugPrint("Status Code: ${response.statusCode}");
    debugPrint("Body: ${response.body}");
  }

  /// ------------------- POST --------------------- ///
  static Future<Map<String, dynamic>> post({
    required String url,
    required Map<String, dynamic> body,
    BuildContext? context,
    bool showLoader = false,
  }) async {
    try {
      if (showLoader && context != null) ApiLoader.show(context);

      _logRequest(method: "POST", url: url, headers: {"Content-Type": "application/json"}, body: body);

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      _logResponse(response);

      if (showLoader && context != null) ApiLoader.hide();

      final decoded = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {"success": true, "data": decoded};
      } else {
        return {"success": false, "error": decoded["message"] ?? "Something went wrong"};
      }
    } on SocketException {
      if (showLoader && context != null) ApiLoader.hide();
      return {"success": false, "error": "No internet connection"};
    } catch (e) {
      if (showLoader && context != null) ApiLoader.hide();
      return {"success": false, "error": e.toString()};
    }
  }

  /// ------------------- GET --------------------- ///
  static Future<Map<String, dynamic>> get({
    required String url,
    BuildContext? context,
    bool showLoader = false,
  }) async {
    try {
      if (showLoader && context != null) ApiLoader.show(context);

      _logRequest(method: "GET", url: url, headers: {"Content-Type": "application/json"});

      final response = await http.get(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
      );

      _logResponse(response);

      if (showLoader && context != null) ApiLoader.hide();

      final decoded = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {"success": true, "data": decoded};
      } else {
        return {"success": false, "error": decoded["message"] ?? "Something went wrong"};
      }
    } on SocketException {
      if (showLoader && context != null) ApiLoader.hide();
      return {"success": false, "error": "No internet connection"};
    } catch (e) {
      if (showLoader && context != null) ApiLoader.hide();
      return {"success": false, "error": e.toString()};
    }
  }

  /// ------------------- DELETE --------------------- ///
  static Future<Map<String, dynamic>> delete({
    required String url,
    required String token,
    BuildContext? context,
    bool showLoader = false,
  }) async {
    try {
      if (showLoader && context != null) ApiLoader.show(context);

      final headers = {"Authorization": "Bearer $token"};

      _logRequest(method: "DELETE", url: url, headers: headers);

      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );

      _logResponse(response);

      if (showLoader && context != null) ApiLoader.hide();

      Map<String, dynamic>? decoded;
      if (response.body.isNotEmpty) {
        decoded = jsonDecode(response.body) as Map<String, dynamic>?;
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {"success": true, "data": decoded};
      } else {
        return {"success": false, "error": decoded?["message"] ?? "Something went wrong"};
      }
    } on SocketException {
      if (showLoader && context != null) ApiLoader.hide();
      return {"success": false, "error": "No internet connection"};
    } catch (e) {
      if (showLoader && context != null) ApiLoader.hide();
      return {"success": false, "error": e.toString()};
    }
  }

  /// ------------------- GET WITH AUTH --------------------- ///
  static Future<Map<String, dynamic>> getWithAuth({
    required String url,
    required String token,
    BuildContext? context,
    bool showLoader = false,
  }) async {
    try {
      if (showLoader && context != null) ApiLoader.show(context);

      final headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token"
      };

      _logRequest(method: "GET", url: url, headers: headers);

      final response = await http.get(Uri.parse(url), headers: headers);

      _logResponse(response);

      if (showLoader && context != null) ApiLoader.hide();

      final decoded = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {"success": true, "data": decoded};
      } else if (response.statusCode == 401) {
        return {"success": false, "error": "Unauthorized. Please log in again."};
      } else {
        return {"success": false, "error": decoded["message"] ?? "Something went wrong"};
      }
    } on SocketException {
      if (showLoader && context != null) ApiLoader.hide();
      return {"success": false, "error": "No internet connection"};
    } catch (e) {
      if (showLoader && context != null) ApiLoader.hide();
      return {"success": false, "error": e.toString()};
    }
  }

  /// ------------------- PUT WITH AUTH --------------------- ///
  static Future<Map<String, dynamic>> putWithAuth({
    required String url,
    required String token,
    required Map<String, dynamic> body,
    BuildContext? context,
    bool showLoader = false,
  }) async {
    try {
      if (showLoader && context != null) ApiLoader.show(context);

      final headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token"
      };

      _logRequest(method: "PUT", url: url, headers: headers, body: body);

      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      _logResponse(response);

      if (showLoader && context != null) ApiLoader.hide();

      final decoded = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {"success": true, "data": decoded};
      } else if (response.statusCode == 401) {
        return {"success": false, "error": "Unauthorized. Please log in again."};
      } else {
        return {"success": false, "error": decoded["message"] ?? "Something went wrong"};
      }
    } on SocketException {
      if (showLoader && context != null) ApiLoader.hide();
      return {"success": false, "error": "No internet connection"};
    } catch (e) {
      if (showLoader && context != null) ApiLoader.hide();
      return {"success": false, "error": e.toString()};
    }
  }

  /// ------------------- POST WITH AUTH --------------------- ///
  static Future<Map<String, dynamic>> postWithAuth({
    required String url,
    required String token,
    required Map<String, dynamic> body,
    BuildContext? context,
    bool showLoader = false,
  }) async {
    try {
      if (showLoader && context != null) ApiLoader.show(context);

      final headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token"
      };

      _logRequest(method: "POST", url: url, headers: headers, body: body);

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      _logResponse(response);

      if (showLoader && context != null) ApiLoader.hide();

      final decoded = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {"success": true, "data": decoded};
      } else if (response.statusCode == 401) {
        return {"success": false, "error": "Unauthorized. Please log in again."};
      } else {
        return {"success": false, "error": decoded["message"] ?? "Something went wrong"};
      }
    } on SocketException {
      if (showLoader && context != null) ApiLoader.hide();
      return {"success": false, "error": "No internet connection"};
    } catch (e) {
      if (showLoader && context != null) ApiLoader.hide();
      return {'success': false, 'error': e.toString()};
    }
  }
  /// Convenience wrapper so you can call `ApiHelper.deleteWithAuth(...)`
  /// (used by Dashboard disconnect) while still using the same core delete logic.
  static Future<Map<String, dynamic>> deleteWithAuth({
    required String url,
    required String token,
    BuildContext? context,
    bool showLoader = false,
  }) {
    return delete(
      url: url,
      token: token,
      context: context,
      showLoader: showLoader,
    );
  }

}
