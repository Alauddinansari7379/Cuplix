import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GoogleAuthClient {
  static const _authUrl = "https://api.cuplix.in/api/auth/google";
  static const _storage = FlutterSecureStorage();

  /// Opens Google sign-in via external browser.
  static Future<void> signIn() async {
    final uri = Uri.parse("https://api.cuplix.in/api/auth/google");
    try {
      if (!await canLaunchUrl(uri)) {
        throw Exception("Cannot launch URL: $uri");
      }
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) {
        throw Exception("launchUrl returned false for $uri");
      }
    } on PlatformException catch (e) {
      // platform plugin error (this is your current case)
      debugPrint('PlatformException launching url: $e');
      rethrow;
    } catch (e, st) {
      debugPrint('Error launching url: $e\n$st');
      rethrow;
    }
  }


  /// Saves tokens after backend callback completes.
  /// Call this once you receive accessToken + refreshToken.
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: "accessToken", value: accessToken);
    await _storage.write(key: "refreshToken", value: refreshToken);
  }

  /// Reads stored tokens.
  static Future<Map<String, String?>> getTokens() async {
    final access = await _storage.read(key: "accessToken");
    final refresh = await _storage.read(key: "refreshToken");
    return {
      "accessToken": access,
      "refreshToken": refresh,
    };
  }

  /// Sign-out logic → clears tokens.
  static Future<void> signOut() async {
    await _storage.delete(key: "accessToken");
    await _storage.delete(key: "refreshToken");
  }

  /// Utility: show toast or snack message
  static void notify(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}
