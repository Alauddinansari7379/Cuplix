// lib/auth/google_auth_client.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uni_links/uni_links.dart';
import 'package:cuplix/utils/SharedPreferences.dart';
import 'package:cuplix/dashboard/Dashboard.dart';
import '../apiInterface/ApiInterface.dart';
import '../apiInterface/ApIHelper.dart';
import '../login/Login.dart';

class GoogleAuthClient {
  static final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _accessKey = 'access_token';
  static const String _refreshKey = 'refresh_token';

  /// Open backend auth URL in external browser.
  /// Backend must perform Google OAuth and then redirect to a deep link like:
  ///   myapp://auth-callback?access_token=...&refresh_token=...&email=...
  ///
  /// After launching the URL we listen for an incoming link (uni_links).
  static Future<void> signInWithGoogleViaBrowser(BuildContext context) async {
    final scaffold = ScaffoldMessenger.of(context);
    final authUrl = ApiInterface.authGoogle;

    scaffold.showSnackBar(const SnackBar(content: Text('Opening Google sign-in...')));

    try {
      final uri = Uri.parse(authUrl);

      if (!await canLaunchUrl(uri)) {
        scaffold.showSnackBar(const SnackBar(content: Text('Unable to open browser for Google sign-in')));
        return;
      }

      // setup one-shot listener BEFORE launching browser so we don't miss the callback
      StreamSubscription<Uri?>? sub;
      sub = uriLinkStream.listen(
            (Uri? incomingUri) {
          // sync listener -> call async handler
          _handleIncomingLink(incomingUri, context, scaffold, sub);
        },
        onError: (err) {
          debugPrint('uni_links error: $err');
          scaffold.showSnackBar(SnackBar(content: Text('Error receiving auth callback: $err')));
        },
      );

      // Now open the external browser
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e, st) {
      debugPrint('signInWithGoogleViaBrowser error: $e\n$st');
      if (context.mounted) {
        scaffold.showSnackBar(SnackBar(content: Text('Failed to start Google sign-in: $e')));
      }
    }
  }

  /// Async handler for incoming deep links (one-shot)
  static Future<void> _handleIncomingLink(
      Uri? uri,
      BuildContext context,
      ScaffoldMessengerState scaffold,
      StreamSubscription<Uri?>? sub,
      ) async {
    if (uri == null) return;

    debugPrint('Incoming link: $uri');

    try {
      final access = uri.queryParameters['access_token'] ?? uri.queryParameters['token'];
      final refresh = uri.queryParameters['refresh_token'];
      final email = uri.queryParameters['email'];
      final name = uri.queryParameters['name'];

      if (access != null && access.isNotEmpty) {
        // Save tokens
        await _secureStorage.write(key: _accessKey, value: access);
        await SharedPrefs.setAccessToken(access);

        if (refresh != null && refresh.isNotEmpty) {
          await _secureStorage.write(key: _refreshKey, value: refresh);
          await SharedPrefs.setRefreshToken(refresh);
        }

        if (email != null && email.isNotEmpty) await SharedPrefs.setEmail(email);
        if (name != null && name.isNotEmpty) await SharedPrefs.setName(name);

        // Optionally verify token with backend:
        // await verifyServerToken(access);

        // Navigate to Dashboard and clear stack
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const Dashboard()),
                (route) => false,
          );
        }
      } else {
        debugPrint('Callback received but no access token present');
        if (context.mounted) {
          scaffold.showSnackBar(const SnackBar(content: Text('Sign-in callback received but no token')));
        }
      }
    } catch (e, st) {
      debugPrint('Error processing deep link: $e\n$st');
      if (context.mounted) {
        scaffold.showSnackBar(SnackBar(content: Text('Error processing sign-in callback: $e')));
      }
    } finally {
      // cancel subscription (one-shot)
      try {
        await sub?.cancel();
      } catch (e) {
        debugPrint('Error cancelling deep link subscription: $e');
      }
    }
  }

  /// Optional: verify the app token with backend (/auth/verify).
  static Future<bool> verifyServerToken(String token) async {
    try {
      final res = await ApiHelper.post(
        url: ApiInterface.authVerify,
        body: {'token': token},
      );
      return res['success'] == true;
    } catch (e) {
      debugPrint('verifyServerToken exception: $e');
      return false;
    }
  }

  /// Sign out both locally and inform backend optionally.
  /// This clears secure storage and SharedPrefs then navigates to Login.
  static Future<void> signOut(BuildContext context) async {
    try {
      final scaffold = ScaffoldMessenger.of(context);
      scaffold.showSnackBar(const SnackBar(content: Text('Signing out...')));

      final refresh = await _secureStorage.read(key: _refreshKey) ?? await SharedPrefs.getRefreshToken();
      final access = await _secureStorage.read(key: _accessKey) ?? await SharedPrefs.getAccessToken();

      if (refresh != null && refresh.isNotEmpty) {
        try {
          if (access != null && access.isNotEmpty) {
            await ApiHelper.postWithAuth(
              url: ApiInterface.logout,
              token: access,
              body: {'refreshToken': refresh},
              context: context,
              showLoader: false,
            );
          } else {
            await ApiHelper.post(
              url: ApiInterface.logout,
              body: {'refreshToken': refresh},
              context: context,
              showLoader: false,
            );
          }
        } catch (e) {
          debugPrint('Backend logout failed: $e');
        }
      }

      // Clear local storage
      await _secureStorage.deleteAll();
      await SharedPrefs.clearAll();

      // Navigate to Login (clear stack)
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const Login()), (r) => false);
      }
    } catch (e) {
      debugPrint('signOut error: $e');
    }
  }
}
