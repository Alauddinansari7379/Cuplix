import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';

class GoogleWebAuth {
  static const _loginUrl = "https://api.cuplix.in/api/auth/google?source=app";
  static const _storage = FlutterSecureStorage();

  static late AppLinks _appLinks;
  static StreamSubscription<Uri>? _sub;

  /// 1) Call this in initState of LoginPage (or root screen) ONCE
  static Future<void> initDeepLinks(BuildContext context) async {
    _appLinks = AppLinks();

    // Cold start (app opened from deep link when not running)
    final initialUri = await _appLinks.getInitialAppLink();
    if (initialUri != null) {
      _handleIncomingUri(context, initialUri);
    }

    // Warm start (app already running, then deep link arrives)
    _sub = _appLinks.uriLinkStream.listen(
          (uri) => _handleIncomingUri(context, uri),
      onError: (e) => debugPrint("❌ URI stream error: $e"),
    );
  }

  /// 2) Start login: opens browser
  static Future<void> startLogin() async {
    final uri = Uri.parse(_loginUrl);
    debugPrint("🌍 Launching Google login: $_loginUrl");

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not launch $_loginUrl");
    }
  }

  /// 3) Handle deep link back from browser
  static Future<void> _handleIncomingUri(
      BuildContext context,
      Uri uri,
      ) async {
    debugPrint("🔗 Deep link received: $uri");

    // Expect: cuplix://auth/callback?token=...&refreshToken=...
    if (uri.scheme == "cuplix" &&
        uri.host == "auth" &&
        uri.path == "/callback") {
      final token = uri.queryParameters["token"];
      final refresh = uri.queryParameters["refreshToken"];

      debugPrint("✔ token = $token");
      debugPrint("✔ refreshToken = $refresh");

     // if (token != null && refresh != null) {
        await _storage.write(key: "accessToken", value: token);
        await _storage.write(key: "refreshToken", value: refresh);

        debugPrint("🔐 Tokens saved. navigating to /home");

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login successful")),
          );
          Navigator.pushReplacementNamed(context, "/Dashboard");
        }
      // } else {
      //   if (context.mounted) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       const SnackBar(content: Text("Callback missing token data")),
      //     );
      //   }
   //   }
    }
  }

  /// 4) Clean up
  static void dispose() {
    _sub?.cancel();
  }

  /// Helper: read tokens anywhere
  static Future<Map<String, String?>> getTokens() async {
    return {
      "accessToken": await _storage.read(key: "accessToken"),
      "refreshToken": await _storage.read(key: "refreshToken"),
    };
  }

  /// Helper: logout
  static Future<void> signOut() async {
    await _storage.delete(key: "accessToken");
    await _storage.delete(key: "refreshToken");
  }
}
