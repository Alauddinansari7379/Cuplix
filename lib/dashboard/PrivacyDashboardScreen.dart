// lib/privacy/PrivacyDashboardScreen.dart
import 'package:flutter/material.dart';

import '../apiInterface/api_helper.dart';
import '../apiInterface/api_interface.dart';
import '../login/login.dart';
import '../utils/SharedPreferences.dart';

class PrivacyDashboardScreen extends StatefulWidget {
  const PrivacyDashboardScreen({Key? key}) : super(key: key);

  @override
  State<PrivacyDashboardScreen> createState() => _PrivacyDashboardScreenState();
}

class _PrivacyDashboardScreenState extends State<PrivacyDashboardScreen> {
  bool _voiceAnalysis = true;
  bool _locationContext = true;
  bool _usageAnalytics = false;

  Future<void> _handleDeleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This will permanently delete your personality profile. '
              'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    ) ??
        false;

    if (!confirm) return;

    final token = await SharedPrefs.getAccessToken();
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No token found. Please sign in again.')),
      );
      return;
    }

    final result = await ApiHelper.delete(
      url: ApiInterface.deletePersonalityProfile,
      token: token,
      context: context,
      showLoader: true,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      // Clear local auth info (best effort)
      await SharedPrefs.setAccessToken('');
      await SharedPrefs.setRefreshToken('');
      await SharedPrefs.setEmail('');
      await SharedPrefs.setName('');
      await SharedPrefs.setNumber('');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account deleted successfully')),
      );

      // Go back to login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const Login()),
            (route) => false,
      );
    } else {
      final err = result['error']?.toString() ?? 'Failed to delete account';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2C2139);
    const muted = Color(0xFF9A8EA0);
    const gradient = LinearGradient(
      colors: [Color(0xFFb640ef), Color(0xFFe46791)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Privacy Dashboard',
          style: TextStyle(
            color: primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Control your data and privacy settings',
                style: TextStyle(color: muted),
              ),
              const SizedBox(height: 18),

              // ---------- Security Status ----------
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.shield_outlined,
                            color: Color(0xFFb640ef)),
                        SizedBox(width: 8),
                        Text(
                          'Security Status',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.circle,
                            color: Colors.green, size: 10),
                        SizedBox(width: 6),
                        Text(
                          'Secure',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.lock_outline,
                            color: primary, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('End-to-End Encryption',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600)),
                              SizedBox(height: 2),
                              Text(
                                'All data encrypted',
                                style: TextStyle(color: muted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.storage_rounded,
                            color: primary, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('GDPR Compliant',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600)),
                              SizedBox(height: 2),
                              Text(
                                'Data protection standards',
                                style: TextStyle(color: muted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ---------- Data Collection ----------
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.graphic_eq,
                            color: Color(0xFFb640ef)),
                        SizedBox(width: 8),
                        Text(
                          'Data Collection',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Voice
                    _toggleRow(
                      icon: Icons.mic_none_outlined,
                      title: 'Voice Analysis',
                      subtitle:
                      'Analyze tone and emotion in your voice (no content recorded)',
                      value: _voiceAnalysis,
                      onChanged: (v) => setState(() => _voiceAnalysis = v),
                    ),
                    const SizedBox(height: 14),

                    // Location
                    _toggleRow(
                      icon: Icons.location_on_outlined,
                      title: 'Location Context',
                      subtitle:
                      'Use location to understand emotional context',
                      value: _locationContext,
                      onChanged: (v) => setState(() => _locationContext = v),
                    ),
                    const SizedBox(height: 14),

                    // Usage
                    _toggleRow(
                      icon: Icons.visibility_outlined,
                      title: 'Usage Analytics',
                      subtitle:
                      'Help improve Cuplix with anonymous usage data',
                      value: _usageAnalytics,
                      onChanged: (v) => setState(() => _usageAnalytics = v),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ---------- Data Access & Portability ----------
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.download_outlined,
                            color: Color(0xFFb640ef)),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Data Access & Portability',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 44,
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: trigger download data API
                        },
                        icon: const Icon(Icons.download_rounded),
                        label: const Text('Download Data'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 44,
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: trigger request data transfer API
                        },
                        icon: const Icon(Icons.swap_horiz_rounded),
                        label: const Text('Request Data Transfer'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'We will process your request within 7 working days',
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ---------- Account Controls ----------
              _card(
                color: const Color(0xFFFFF3F3),
                borderColor: const Color(0xFFFFD0D0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.delete_forever_outlined,
                            color: Color(0xFFE53935)),
                        SizedBox(width: 8),
                        Text(
                          'Account Controls',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'You can permanently delete your account and all associated data. '
                          'This action cannot be undone.',
                      style: TextStyle(color: muted),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 44,
                      width: double.infinity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: gradient,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _handleDeleteAccount,
                          icon: const Icon(Icons.delete,color: Colors.white,),
                          label: const Text('Delete Account',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------- Helpers -------

  Widget _card({
    required Widget child,
    Color color = Colors.white,
    Color borderColor = const Color(0xFFEEE6F0),
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _toggleRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    const muted = Color(0xFF9A8EA0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.purple, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: muted, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: const Color(0xFFb640ef),
        ),
      ],
    );
  }
}
