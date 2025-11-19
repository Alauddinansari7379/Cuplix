// lib/auth/google_auth_client.dart
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cuplix/utils/SharedPreferences.dart';
import 'package:cuplix/dashboard/dashboard.dart';

import '../apiInterface/APIHelper.dart';
import '../apiInterface/ApiInterface.dart';

class GoogleAuthClient {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email','profile']);
  static const _secureKey = 'access_token';
  static final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Sign in with Google, then send idToken to server (/auth/google).
  static Future<void> signInWithGoogleAndBackend(BuildContext context) async {
    try {
      // 1) Google interactive sign in
      final account = await _googleSignIn.signIn();
      if (account == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Google sign-in canceled')));
        return;
      }

      // 2) Get tokens from Google
      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to get Google id token')));
        return;
      }

      // 3) Send idToken to your backend
      final payload = {'idToken': idToken};
      final res = await ApiHelper.post(
        url: ApiInterface.authGoogle,
        body: payload,
        context: context,
        showLoader: true,
      );

      if (res['success'] == true) {
        final data = res['data'] ?? {};
        // adapt to what backend returns:
        final appToken = (data['access_token'] ?? data['token'] ?? '').toString();
        final user = data['user'] ?? data;

        if (appToken.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No app token returned from server')));
          return;
        }

        // 4) Save token securely
        await _secureStorage.write(key: _secureKey, value: appToken);
        await SharedPrefs.setAccessToken(appToken); // optional duplicate storage

        // save user info locally if present
        final name = (user['name'] ?? account.displayName ?? '').toString();
        final email = (user['email'] ?? account.email ?? '').toString();
        final avatar = (user['avatarUrl'] ?? account.photoUrl ?? '').toString();
        if (name.isNotEmpty) await SharedPrefs.setName(name);
        if (email.isNotEmpty) await SharedPrefs.setEmail(email);
        if (avatar.isNotEmpty) await SharedPrefs.setAvatar(avatar);

        // 5) Optional: call verify endpoint to confirm session (see method below)
        // await verifyServerToken(appToken);

        // 6) Navigate to dashboard
        if (!context.mounted) return;
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const Dashboard()), (r) => false);
      } else {
        final err = res['error'] ?? 'Login with Google failed';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.toString())));
      }
    } catch (e, st) {
      debugPrint('signInWithGoogleAndBackend error: $e\n$st');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign-in failed: $e')));
      }
    }
  }

  /// Optional: verify the app token with backend (/auth/verify).
  /// Adjust to server's expected format (header vs body).
  static Future<bool> verifyServerToken(String token) async {
    try {
      // If your ApiHelper has an authorized GET/POST helper, use that.
      // Example: POST { token: "<token>" } to auth/verify
      final res = await ApiHelper.post(
        url: ApiInterface.authVerify,
        body: {'token': token},
        // no context here - silent verify; or pass context to show loader
      );

      if (res['success'] == true) {
        // server responded OK; you can process res['data'] if needed
        return true;
      } else {
        debugPrint('verifyServerToken failed: ${res['error']}');
        return false;
      }
    } catch (e) {
      debugPrint('verifyServerToken exception: $e');
      return false;
    }
  }

  /// Sign out both locally and from Google
  static Future<void> signOut(BuildContext context) async {
    try {
      await _googleSignIn.signOut();
      await _secureStorage.delete(key: _secureKey);
      await SharedPrefs.clearAll();
      if (!context.mounted) return;
      Navigator.pushReplacementNamed(context, '/login'); // adapt to your login route
    } catch (e) {
      debugPrint('GoogleAuthClient.signOut error: $e');
    }
  }
}
