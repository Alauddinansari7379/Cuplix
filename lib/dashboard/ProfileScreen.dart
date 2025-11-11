// lib/profile/profile_screen.dart
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  // Example — replace with real values from your auth/profile store
  final String _name = 'Alauddin Ansari';
  final String _email = 'alauddeenansari7379@gmail.com';
  final String _bio = 'No bio available';

  @override
  Widget build(BuildContext context) {
    const primaryText = Color(0xFF2C2139);
    const mutedText = Color(0xFF9A8EA0);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Your Profile',
          style: TextStyle(color: primaryText, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 4),
              const Text(
                'Manage your account and access all relationship tools',
                style: TextStyle(color: mutedText),
              ),
              const SizedBox(height: 18),

              // ---------- User card ----------
              _roundedCard(
                child: Row(
                  children: [
                    Container(
                      height: 64,
                      width: 64,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFaf57db), Color(0xFFe46791)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          _initials(_name),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_name,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryText)),
                          const SizedBox(height: 6),
                          Text(_email, style: const TextStyle(color: mutedText)),
                          const SizedBox(height: 8),
                          Text(_bio, style: const TextStyle(color: mutedText)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // edit profile quick action (open edit page)
                      },
                      icon: const Icon(Icons.edit, color: Color(0xFF9A8EA0)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ---------- Free trial / upgrade card ----------
              _roundedCard(
                child: Row(
                  children: [
                    Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6EEFF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(child: Icon(Icons.emoji_events, color: Color(0xFFaf57db))),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Free Trial', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('10 days remaining', style: TextStyle(color: mutedText)),
                        ],
                      ),
                    ),
                    Container(
                      height: 40,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xffb640ef), Color(0xFFe46791)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          // go to upgrade / subscription screen
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('Upgrade Now', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ---------- Profile Management header ----------
              const Text('Profile Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              _roundedCard(
                child: Column(
                  children: [
                    _FeatureTile(
                      iconGradient: const LinearGradient(colors: [Color(0xFFF6E9FF), Color(
                          0xFF8E50E6)]),
                      icon: Icons.edit_outlined,
                      title: 'Edit Profile & Preferences',
                      subtitle: 'Update your personal information and relationship preferences',
                      onTap: () {
                        // navigate to edit profile page
                      },
                    ),
                    const SizedBox(height: 10),
                    _FeatureTile(
                      iconGradient: const LinearGradient(colors: [Color(0xFFF6E9FF), Color(0xFF8E50E6)]),
                      icon: Icons.person_add_alt_1,
                      title: 'Invite Partner',
                      subtitle: 'Connect with your significant other to sync your relationship data',
                      onTap: () {
                        // invite partner flow
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

// Health & Wellness header (inline)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  Text(
                    'Health & Wellness',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                ],
              ),

              const SizedBox(height: 12),

// Grouped tiles
              _roundedCard(
                child: Column(
                  children: [
                    _FeatureTile(
                      iconGradient: const LinearGradient(colors: [Color(0xFFF6E7F9), Color(
                          0xFFD697EC)]),
                      icon: Icons.water_drop_outlined,
                      title: 'Cycle Tracker',
                      subtitle: 'Track your menstrual cycle and hormonal mood patterns',
                      onTap: () {
                        // navigate to Cycle Tracker
                      },
                    ),
                    const SizedBox(height: 10),
                    _FeatureTile(
                      iconGradient: const LinearGradient(colors: [Color(0xFFEEF4FF), Color(
                          0xFF7599E6)]),
                      icon: Icons.nightlight_round,
                      title: 'Sleep & Stress',
                      subtitle: 'Monitor your sleep quality and stress levels',
                      onTap: () {
                        // navigate to Sleep & Stress
                      },
                    ),
                    const SizedBox(height: 10),
                    _FeatureTile(
                      iconGradient: const LinearGradient(colors: [Color(0xFFE7FFFA), Color(
                          0xFF7EEACC)]),
                      icon: Icons.monitor_heart,
                      title: 'Sensor Tracking',
                      subtitle: 'Real-time emotional and conflict detection',
                      onTap: () {
                        // navigate to Sensor Tracking
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

// ---------- Relationship Tools header ----------
              const Text('Relationship Tools', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

// Relationship Tools grouped card
              _roundedCard(
                child: Column(
                  children: [
                    _FeatureTile(
                      iconGradient: const LinearGradient(colors: [Color(0xFFF6E7F9), Color(0xFFC437F3)]),
                      icon: Icons.calendar_today,
                      title: 'Couple Calendar',
                      subtitle: 'AI-managed scheduling for relationship events',
                      onTap: () {
                        // navigate to Couple Calendar
                      },
                    ),
                    const SizedBox(height: 10),
                    _FeatureTile(
                      iconGradient: const LinearGradient(colors: [Color(0xFFF6E7F9), Color(0xFFC437F3)]),
                      icon: Icons.show_chart,
                      title: 'Compatibility Map',
                      subtitle: 'Deep emotional interaction visualization',
                      onTap: () {
                        // navigate to Compatibility Map
                      },
                    ),
                    const SizedBox(height: 10),
                    _FeatureTile(
                      iconGradient: const LinearGradient(colors: [Color(0xFFF6E7F9), Color(0xFFC437F3)]),
                      icon: Icons.music_note,
                      title: 'Mood Music',
                      subtitle: 'Personalized playlists for emotional regulation',
                      onTap: () {
                        // navigate to Mood Music
                      },
                    ),
                    const SizedBox(height: 10),
                    _FeatureTile(
                      iconGradient: const LinearGradient(colors: [Color(0xFFF6E7F9), Color(0xFFC437F3)]),
                      icon: Icons.headset,
                      title: 'Therapist Mode',
                      subtitle: 'Conflict analysis with improvement suggestions',
                      onTap: () {
                        // navigate to Therapist Mode
                      },
                    ),
                    const SizedBox(height: 10),
                    _FeatureTile(
                      iconGradient: const LinearGradient(colors: [Color(0xFFF6E7F9), Color(
                          0xFFC437F3)]),
                      icon: Icons.auto_awesome,
                      title: 'Mirror Mode',
                      subtitle: "Practice conversations with your partner's AI twin",
                      onTap: () {
                        // navigate to Mirror Mode
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

// ---------- Account Settings ----------
              const Text('Account Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              _roundedCard(
                child: Column(
                  children: [
                    _FeatureTile(
                      iconGradient: const LinearGradient(colors: [Color(0xFFEBC7F3), Color(0xFFD78AF1)]),
                      icon: Icons.menu_book_outlined,
                      title: 'Journal',
                      subtitle: 'Capture and share special moments',
                      onTap: () {
                        // Navigator.push(... to Journal)
                      },
                    ),
                    const SizedBox(height: 10),
                    _FeatureTile(
                      iconGradient: const LinearGradient(colors: [Color(0xFFEBC7F3), Color(0xFFD78AF1)]),
                      icon: Icons.card_giftcard,
                      title: 'Gift Marketplace',
                      subtitle: 'AI-recommended gifts and experiences',
                      onTap: () {
                        // Navigator.push(... to Gift Marketplace)
                      },
                    ),
                    const SizedBox(height: 10),
                    _FeatureTile(
                      iconGradient: const LinearGradient(colors: [Color(0xFFEBC7F3), Color(0xFFD78AF1)]),
                      icon: Icons.emoji_events,
                      title: 'Rewards & Badges',
                      subtitle: 'View your earned points and achievements',
                      onTap: () {
                        // Navigator.push(... to Rewards)
                      },
                    ),
                    const SizedBox(height: 10),
                    _FeatureTile(
                      iconGradient: const LinearGradient(colors: [Color(0xFFEBC7F3), Color(0xFFD78AF1)]),
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Dashboard',
                      subtitle: 'Manage your data collection and privacy settings',
                      onTap: () {
                        // Navigator.push(... to Privacy Dashboard)
                      },
                    ),

                    const SizedBox(height: 12),

                    // Sign out (separate items with lighter icon color)
                    _FeatureTile(
                      iconGradient: const LinearGradient(colors: [Color(0xFFFFEDEE), Color(
                          0xFFF6A5A5)]),
                      icon: Icons.logout,
                      title: 'Sign Out',
                      subtitle: 'Securely log out of your account from this device',
                      onTap: () {
                        // TODO: perform sign out for current device
                        // e.g. await auth.signOut(); then navigate to login
                      },
                    ),
                    const SizedBox(height: 10),
                    _FeatureTile(
                      iconGradient: const LinearGradient(colors: [Color(0xFFFFEDEE), Color(0xFFF6A5A5)]),
                      icon: Icons.logout_outlined,
                      title: 'Logout from All Devices',
                      subtitle: 'Revoke all active sessions and log out from all devices',
                      onTap: () {
                        // TODO: call API to revoke sessions, then sign out locally
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              const SizedBox(height: 18),

              const SizedBox(height: 18),

              const SizedBox(height: 18),

            ],
          ),
        ),
      ),
    );
  }

  // helper to form initials from name
  static String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}

/// Reusable rounded card used throughout the app
Widget _roundedCard({required Widget child}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFEEE6F0)),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)],
    ),
    child: child,
  );
}

/// Reusable feature tile (icon circle + title + subtitle + chevron)
class _FeatureTile extends StatelessWidget {
  final LinearGradient iconGradient;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _FeatureTile({
    required this.iconGradient,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                gradient: iconGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Icon(icon, color: Colors.white)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(subtitle, style: const TextStyle(color: Color(0xFF9A8EA0))),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFB7AFC0)),
          ],
        ),
      ),
    );
  }
}
