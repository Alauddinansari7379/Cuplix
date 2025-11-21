import 'package:flutter/material.dart';

import 'package:cuplix/utils/SharedPreferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

 import '../apiInterface/ApiInterface.dart';
 import '../apiInterface/ApIHelper.dart';
import '../login/Login.dart';
import '../login/OnboardingRoleSelection.dart';
import '../login/ProfileCompletionPage.dart';

class ProfileChecker {
  /// Fetch user profile. If session expired (401/Unauthorized),
  /// shows a toast, clears session, and redirects to Login.
  static Future<Map<String, dynamic>?> fetchProfile({
    required BuildContext context,
    bool showLoader = false,
    bool showErrorsToUser = true,
  }) async {
    try {
      final token = await SharedPrefs.getAccessToken();
      debugPrint(
        'ProfileChecker.fetchProfile -> token: ${token ?? 'null'}',
      );

      if (token == null || token.isEmpty) {
        _showToast('Not authenticated — please sign in.');
        _redirectToLogin(context);
        return null;
      }

      final result = await ApiHelper.getWithAuth(
        url: ApiInterface.profiles,
        token: token,
        context: context,
        showLoader: showLoader,
      );

      debugPrint('ProfileChecker.fetchProfile -> api result: $result');

      if (result == null) {
        _showToast('No response from server.');
        return null;
      }

      if (result['success'] != true) {
        final err = (result['error'] ?? '').toString();
        debugPrint('ProfileChecker.fetchProfile -> API returned error: $err');

        // Check for Unauthorized / Session expired
        final errLower = err.toLowerCase();
        if (errLower.contains('unauthorized') ||
            errLower.contains('401') ||
            errLower.contains('please log in')) {
          await SharedPrefs.clearAll();

          _showToast('Session expired. Please sign in again.');

          // Redirect user to login
          _redirectToLogin(context);
          return null;
        }

        if (showErrorsToUser) {
          _showToast('Failed to fetch profile: $err');
        }
        return null;
      }

      final data = result['data'];

      // Parsing logic
      if (data is Map && data['data'] != null) {
        final inner = data['data'];
        if (inner is Map<String, dynamic>) return Map<String, dynamic>.from(inner);
        if (inner is List && inner.isNotEmpty && inner.first is Map) {
          return Map<String, dynamic>.from(inner.first as Map);
        }
      }

      if (data is List && data.isNotEmpty && data.first is Map) {
        return Map<String, dynamic>.from(data.first as Map);
      }

      if (data is Map<String, dynamic>) {
        return Map<String, dynamic>.from(data);
      }

      _showToast('Unexpected profile format from server.');
      return null;
    } catch (e, st) {
      debugPrint('ProfileChecker.fetchProfile exception: $e\n$st');
      _showToast('Error fetching profile: $e');
      return null;
    }
  }


  /// Checks for incomplete profile and optionally prompts user.
  static Future<bool?> checkAndPrompt({
    required BuildContext context,
    required Map<String, dynamic> profile,
    bool checkAll = false,
  }) async {
    try {
      final avatar = (profile['avatarUrl'] ?? '').toString().trim();
      final name = (profile['name'] ?? '').toString().trim();
      final dateOfBirth = (profile['dateOfBirth'] ?? '').toString().trim();
      final mobile = (profile['mobile'] ?? '').toString().trim();

      await SharedPrefs.setName(name);
      await SharedPrefs.setNumber(mobile);

      bool missing = avatar.isEmpty || avatar.toLowerCase() == 'null';
      if (checkAll) {
        missing = missing ||
            name.isEmpty ||
            dateOfBirth.isEmpty ||
            mobile.isEmpty;
      }

      if (!missing) {
        debugPrint('ProfileChecker.checkAndPrompt -> Profile complete ✅');
        return null;
      }

      // Show popup
      final action = await showDialog<String?>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Complete Your Profile'),
            content: const Text(
              'Your profile appears incomplete. Please update your avatar and details to continue.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop('later'),
                child: const Text('Later'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop('update'),
                child: const Text('Update Now'),
              ),
            ],
          );
        },
      );

      if (action == 'update') {
        final updated = await Navigator.push<bool?>(
          context,
          MaterialPageRoute(
            builder: (_) => OnboardingRoleSelection(
              userEmail: profile['email'] ?? '',
            ),
          ),
        );

        debugPrint('Profile updated? $updated');
        return updated ?? false;
      }


      else {
        debugPrint('ProfileChecker.checkAndPrompt -> user chose Later');
        return false;
      }
    } catch (e, st) {
      debugPrint('ProfileChecker.checkAndPrompt exception: $e\n$st');
      return null;
    }
  }

  /// Shows a short toast message
  static void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  /// Redirects to login and clears the navigation stack
  static void _redirectToLogin(BuildContext context) {
    try {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Login()),
            (route) => false,
      );
    } catch (e) {
      debugPrint('ProfileChecker._redirectToLogin error: $e');
    }
  }
}
