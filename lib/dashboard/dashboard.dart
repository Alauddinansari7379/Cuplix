import 'package:cuplix/dashboard/JournalScreen.dart';
import 'package:cuplix/dashboard/MoreScreen.dart';
import 'package:cuplix/dashboard/ProfileScreen.dart';
import 'package:flutter/material.dart';

import 'ChatScreen.dart';
import 'UpgradeToCuplixScreen.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0;

  // simple content for tabs (ChatScreen is used in-place)
  final List<Widget> _pages = <Widget>[
    const _DashboardContent(),
    const ChatScreen(
      partnerName: 'Partner',
      partnerInitial: 'P',
      isConnected: false,
    ),
    const JournalScreen(), // 👈 Journal screen added
    const ProfileScreen(), // 👈 ProfileScreen screen added
    const MoreScreen(), // 👈 MoreScreen screen added
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    const items = [
      _NavItem(icon: Icons.favorite, label: 'Dashboard'),
      _NavItem(icon: Icons.chat_bubble_outline, label: 'Chat'),
      _NavItem(icon: Icons.book_outlined, label: 'Journal'),
      _NavItem(icon: Icons.person_outline, label: 'Profile'),
      _NavItem(icon: Icons.menu, label: 'More'),
    ];

    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (i) => setState(() => _currentIndex = i),
      selectedItemColor: const Color(0xFFaf57db),
      unselectedItemColor: Colors.grey[600],
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      items:
          items
              .map(
                (e) =>
                    BottomNavigationBarItem(icon: Icon(e.icon), label: e.label),
              )
              .toList(),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}

/// ---------- Dashboard content widget ----------
class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    const gradient = LinearGradient(
      colors: [Color(0xFFaf57db), Color(0xFFe46791)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Welcome back, Alauddin Ansari! 👋',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                // small avatar / placeholder
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.purple.shade50,
                  child: const Icon(Icons.person, color: Colors.purple),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              "Here's how your relationship is growing today",
              style: TextStyle(color: Color(0xFF9A8EA0)),
            ),
            const SizedBox(height: 18),

            // Partner card
            _roundedCard(
              child: Row(
                children: [
                  const Icon(Icons.people_outline, color: Color(0xFF9A8EA0)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'No partner connected yet',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.person_add, size: 18),
                    label: const Text('Invite Partner'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Trial / Upgrade card
            _roundedCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7EEFF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.crop, color: Color(0xFFaf57db)),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Free Trial Active',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '10 days remaining - Unlock all premium features',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 46,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      gradient: LinearGradient(
                        colors: [Color(0xFFaf57db), Color(0xFFe46791)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UpgradeToCuplixScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Upgrade Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Emotional Connection Score card (big)
            _roundedCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Emotional Connection Score',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: const [
                      Text(
                        '87%',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8A2BE2),
                        ),
                      ),
                      SizedBox(width: 12),
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFFf6ecff),
                        child: Icon(Icons.favorite, color: Color(0xFFaf57db)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: 0.87,
                      minHeight: 10,
                      backgroundColor: const Color(0xFFF3EAF6),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFaf57db),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '⬈ Up 12% from last week',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ---------- Metrics grid (2 columns) - using Wrap to avoid fixed height ----------
            Builder(
              builder: (context) {
                // compute item width based on available width and spacing
                final screenWidth = MediaQuery.of(context).size.width;
                // We used horizontal padding 18 on the parent SingleChildScrollView
                const horizontalPadding = 18.0 * 2; // left + right
                const spacing = 12.0;
                final available = screenWidth - horizontalPadding - spacing;
                final itemWidth = available / 2;

                final metricItems = const [
                  _MetricCard(
                    title: 'Spark Index',
                    value: '92',
                    badgeColor: Color(0xFFF5A623),
                    badgeIcon: Icons.star,
                  ),
                  _MetricCard(
                    title: 'Days Together',
                    value: '247',
                    badgeColor: Color(0xFF4FC3F7),
                    badgeIcon: Icons.calendar_today,
                  ),
                  _MetricCard(
                    title: 'Love Points',
                    value: '1,240',
                    badgeColor: Color(0xFFCE8AF0),
                    badgeIcon: Icons.emoji_events,
                  ),
                  _MetricCard(
                    title: 'Compatibility',
                    value: '84%',
                    badgeColor: Color(0xFFFB7B9A),
                    badgeIcon: Icons.favorite,
                  ),
                ];

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children:
                      metricItems.map((w) {
                        return SizedBox(width: itemWidth, child: w);
                      }).toList(),
                );
              },
            ),
            const SizedBox(height: 18),

            // Weekly Happiness Trend chart card (placeholder)
            _roundedCard(
              child: SizedBox(
                height: 180,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Weekly Happiness Trend',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // placeholder chart area
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDF9FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'Chart goes here',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // weekday labels
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        Text('M', style: TextStyle(color: Color(0xFF9A8EA0))),
                        Text('T', style: TextStyle(color: Color(0xFF9A8EA0))),
                        Text('W', style: TextStyle(color: Color(0xFF9A8EA0))),
                        Text('T', style: TextStyle(color: Color(0xFF9A8EA0))),
                        Text('F', style: TextStyle(color: Color(0xFF9A8EA0))),
                        Text('S', style: TextStyle(color: Color(0xFF9A8EA0))),
                        Text('S', style: TextStyle(color: Color(0xFF9A8EA0))),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Compatibility Over Time chart card (placeholder)
            _roundedCard(
              child: SizedBox(
                height: 180,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Compatibility Over Time',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDF9FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'Chart goes here',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        Text('M', style: TextStyle(color: Color(0xFF9A8EA0))),
                        Text('T', style: TextStyle(color: Color(0xFF9A8EA0))),
                        Text('W', style: TextStyle(color: Color(0xFF9A8EA0))),
                        Text('T', style: TextStyle(color: Color(0xFF9A8EA0))),
                        Text('F', style: TextStyle(color: Color(0xFF9A8EA0))),
                        Text('S', style: TextStyle(color: Color(0xFF9A8EA0))),
                        Text('S', style: TextStyle(color: Color(0xFF9A8EA0))),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Relationship Blueprint card with progress rows + insights
            _roundedCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      // circular icon
                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFaf57db), Color(0xFFe46791)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Icon(Icons.track_changes, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Relationship Blueprint',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Your personalized compatibility map',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // progress rows
                  _ProgressRow(
                    icon: Icons.chat_bubble_outline,
                    label: 'Communication',
                    percent: 0.85,
                  ),
                  const SizedBox(height: 12),
                  _ProgressRow(
                    icon: Icons.favorite_border,
                    label: 'Emotional Intimacy',
                    percent: 0.78,
                  ),
                  const SizedBox(height: 12),
                  _ProgressRow(
                    icon: Icons.album,
                    label: 'Shared Values',
                    percent: 0.92,
                  ),
                  const SizedBox(height: 12),
                  _ProgressRow(
                    icon: Icons.person_search,
                    label: 'Conflict Resolution',
                    percent: 0.72,
                  ),
                  const SizedBox(height: 12),
                  _ProgressRow(
                    icon: Icons.accessibility_new,
                    label: 'Physical Intimacy',
                    percent: 0.88,
                  ),

                  const SizedBox(height: 18),

                  // Blueprint Insights box (rounded pale card inside the main card)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F0F7),
                      // very pale purple background
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Blueprint Insights',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Your strongest area is Shared Values (92%). Focus on improving Conflict '
                          'Resolution through active listening techniques.',
                          style: TextStyle(color: Colors.grey, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Smart Notifications header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Smart Notifications',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey.shade200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'Settings',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Notification cards list
            _roundedCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  SizedBox(height: 4),
                  _NotificationCard(
                    iconColorStart: Color(0xFFEB9AA6),
                    iconColorEnd: Color(0xFFF7C7C9),
                    icon: Icons.favorite_border,
                    title:
                        "It's been 2 days since you said something kind — try now?",
                    timeAgo: '2 hours ago',
                    primaryLabel: 'Send appreciation',
                    bgColor: Color(0xFFFFF3F4),
                  ),
                  SizedBox(height: 12),
                  _NotificationCard(
                    iconColorStart: Color(0xFFB9D9FF),
                    iconColorEnd: Color(0xFFDDEEFF),
                    icon: Icons.chat_bubble_outline,
                    title:
                        "Your partner had a tough workday — maybe send a message.",
                    timeAgo: '4 hours ago',
                    primaryLabel: 'Check in',
                    bgColor: Color(0xFFF3F8FF),
                  ),
                  SizedBox(height: 12),
                  _NotificationCard(
                    iconColorStart: Color(0xFFF9E9C6),
                    iconColorEnd: Color(0xFFFBF0D6),
                    icon: Icons.access_time,
                    title:
                        "You both haven't interacted much today — small gesture time.",
                    timeAgo: '6 hours ago',
                    primaryLabel: 'Start conversation',
                    bgColor: Color(0xFFFFFBF2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Unspoken Needs Decoder
            _roundedCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8E6DF5), Color(0xFFEA7FA6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.auto_mode_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Unspoken Needs Decoder',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'AI insights for better understanding',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // list of unspoken needs suggestions
                  const _UnspokenCard(
                    icon: Icons.favorite_border,
                    title:
                        "Today, your partner would appreciate being noticed for his efforts.",
                    actionLabel: "Send a text acknowledging their hard work",
                    bgColor: Color(0xFFFFF3F4),
                  ),

                  const SizedBox(height: 12),

                  const _UnspokenCard(
                    icon: Icons.favorite,
                    title:
                        "You may be feeling overwhelmed with responsibilities lately.",
                    actionLabel:
                        "Ask your partner for support with daily tasks",
                    bgColor: Color(0xFFF6F0FF),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Communication & AI header
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                Text(
                  'Communication & AI',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                Text(
                  'Tools to enhance conversations with your partner and Cuplix AI',
                  style: TextStyle(color: Color(0xFF9A8EA0)),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Features list
            _roundedCard(
              child: Column(
                children: [
                  _FeatureTile(
                    iconGradient: LinearGradient(
                      colors: [Color(0xFF6EC1FF), Color(0xFF5AA6FF)],
                    ),
                    icon: Icons.chat_bubble_outline,
                    title: 'AI Chat',
                    subtitle:
                        'Get advice and guidance through text conversations',
                    onTap: null,
                  ),
                  SizedBox(height: 10),
                  _FeatureTile(
                    iconGradient: LinearGradient(
                      colors: [Color(0xFFAF57DB), Color(0xFFE46791)],
                    ),
                    icon: Icons.mic,
                    title: 'Voice AI',
                    subtitle: 'Talk to your AI relationship therapist anytime',
                    onTap: null,
                  ),
                  SizedBox(height: 10),
                  _FeatureTile(
                    iconGradient: LinearGradient(
                      colors: [Color(0xFF6EC1FF), Color(0xFF5AA6FF)],
                    ),
                    icon: Icons.forum_outlined,
                    title: 'Partner Chat',
                    subtitle: 'Secure, AI-enhanced messaging with your partner',
                    onTap: null,
                  ),
                  SizedBox(height: 10),
                  _FeatureTile(
                    iconGradient: LinearGradient(
                      colors: [Color(0xFF8E6DF5), Color(0xFFEA7FA6)],
                    ),
                    icon: Icons.auto_awesome,
                    title: 'AI Agent',
                    subtitle:
                        'Command your AI assistant to manage app features',
                    onTap: null,
                  ),
                  SizedBox(height: 10),
                  _FeatureTile(
                    iconGradient: LinearGradient(
                      colors: [Color(0xFFF5B24A), Color(0xFFF3983E)],
                    ),
                    icon: Icons.smart_toy,
                    title: 'Mirror Mode',
                    subtitle:
                        "Practice conversations with your partner's AI twin",
                    onTap: null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Memories & Care header
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                Text(
                  'Memories & Care',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                Text(
                  'Capture special moments and nurture emotional closeness',
                  style: TextStyle(color: Color(0xFF9A8EA0)),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Memories & Care features list (uses same _roundedCard style)
            _roundedCard(
              child: Column(
                children: [
                  _FeatureTile(
                    iconGradient: LinearGradient(
                      colors: [Color(0xFF4FD77E), Color(0xFF2DB06A)],
                    ),
                    icon: Icons.book_outlined,
                    title: 'Journal',
                    subtitle: 'Capture memories and track emotional trends',
                    onTap: () {
                      // navigate to Journal
                    },
                  ),
                  const SizedBox(height: 10),
                  _FeatureTile(
                    iconGradient: LinearGradient(
                      colors: [Color(0xFFF47B9A), Color(0xFFEA5E82)],
                    ),
                    icon: Icons.person_add_alt_1,
                    title: 'Invite Partner',
                    subtitle:
                        'Send a personal invite so your partner can join you',
                    onTap: () {
                      // invite flow
                    },
                  ),
                  const SizedBox(height: 10),
                  _FeatureTile(
                    iconGradient: LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFEE5A5A)],
                    ),
                    icon: Icons.favorite,
                    title: 'Intimacy Builder',
                    subtitle: 'Custom suggestions to maintain emotional spark',
                    onTap: () {
                      // intimacy feature
                    },
                  ),
                  const SizedBox(height: 10),
                  _FeatureTile(
                    iconGradient: LinearGradient(
                      colors: [Color(0xFF8E6DF5), Color(0xFFE46791)],
                    ),
                    icon: Icons.health_and_safety,
                    title: 'Therapist Mode',
                    subtitle: 'Conflict analysis with improvement suggestions',
                    onTap: () {
                      // therapist mode
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Planning & Adventures header
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                Text(
                  'Planning & Adventures',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                Text(
                  'Organize quality time and shared goals',
                  style: TextStyle(color: Color(0xFF9A8EA0)),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Planning & Adventures tiles (grouped in a single card)
            _roundedCard(
              child: Column(
                children: [
                  _FeatureTile(
                    iconGradient: LinearGradient(
                      colors: [Color(0xFFF5B24A), Color(0xFFF3983E)],
                    ),
                    icon: Icons.calendar_today,
                    title: 'Couple Calendar',
                    subtitle: 'AI-managed scheduling for relationship events',
                    onTap: () {
                      // navigate to Couple Calendar
                    },
                  ),
                  const SizedBox(height: 10),
                  _FeatureTile(
                    iconGradient: LinearGradient(
                      colors: [Color(0xFFEE6A3D), Color(0xFFEF4A2A)],
                    ),
                    icon: Icons.track_changes,
                    title: 'Shared Goals',
                    subtitle: 'Track goals and dream experiences in one place',
                    onTap: () {
                      // navigate to Shared Goals
                    },
                  ),
                  const SizedBox(height: 10),
                  _FeatureTile(
                    iconGradient: LinearGradient(
                      colors: [Color(0xFFF3C451), Color(0xFFF1B33C)],
                    ),
                    icon: Icons.show_chart,
                    title: 'Compatibility',
                    subtitle: 'Deep emotional interaction visualization',
                    onTap: () {
                      // navigate to Compatibility analytics
                    },
                  ),
                  const SizedBox(height: 10),
                  _FeatureTile(
                    iconGradient: LinearGradient(
                      colors: [Color(0xFFF47B9A), Color(0xFFEE5E82)],
                    ),
                    icon: Icons.music_note,
                    title: 'Mood Music',
                    subtitle: 'Personalized playlists for emotional regulation',
                    onTap: () {
                      // navigate to Mood Music
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Health & Wellness header
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                Text(
                  'Health & Wellness',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                Text(
                  'Track your well-being and its impact on your relationship',
                  style: TextStyle(color: Color(0xFF9A8EA0)),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Health & Wellness tiles (grouped in one card)
            _roundedCard(
              child: Column(
                children: [
                  _FeatureTile(
                    iconGradient: LinearGradient(
                      colors: [Color(0xFFFB7B9A), Color(0xFFEA6A96)],
                    ),
                    icon: Icons.bloodtype,
                    title: 'Cycle Tracker',
                    subtitle: 'Hormonal mood insights with gentle reminders',
                    onTap: () {
                      // navigate to Cycle Tracker
                    },
                  ),
                  const SizedBox(height: 10),
                  _FeatureTile(
                    iconGradient: LinearGradient(
                      colors: [Color(0xFF7AA1FF), Color(0xFF6B8CFF)],
                    ),
                    icon: Icons.nightlight_round,
                    title: 'Sleep & Stress',
                    subtitle:
                        'Biological harmony tracking with wellness insights',
                    onTap: () {
                      // navigate to Sleep & Stress
                    },
                  ),
                  const SizedBox(height: 10),
                  _FeatureTile(
                    iconGradient: LinearGradient(
                      colors: [Color(0xFF56D7C6), Color(0xFF2FBEB0)],
                    ),
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

            // Rewards & Marketplace header
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                Text(
                  'Rewards & Marketplace',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                Text(
                  'Celebrate each other with thoughtful surprises',
                  style: TextStyle(color: Color(0xFF9A8EA0)),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Rewards & Marketplace tiles (grouped together in one rounded card)
            _roundedCard(
              child: Column(
                children: [
                  _FeatureTile(
                    iconGradient: LinearGradient(
                      colors: [Color(0xFFF47B9A), Color(0xFFEB5E7C)],
                    ),
                    icon: Icons.card_giftcard,
                    title: 'Gift Marketplace',
                    subtitle: 'AI-recommended gifts and experiences',
                    onTap: () {
                      // navigate to Gift Marketplace
                    },
                  ),
                  const SizedBox(height: 10),
                  _FeatureTile(
                    iconGradient: LinearGradient(
                      colors: [Color(0xFF4FD77E), Color(0xFF2DB06A)],
                    ),
                    icon: Icons.emoji_events,
                    title: 'Rewards',
                    subtitle:
                        'Earn love points and badges for positive actions',
                    onTap: () {
                      // navigate to Rewards section
                    },
                  ),
                  const SizedBox(height: 10),
                  _FeatureTile(
                    iconGradient: LinearGradient(
                      colors: [Color(0xFFF3C451), Color(0xFFEFAE39)],
                    ),
                    icon: Icons.workspace_premium,
                    title: 'Subscription',
                    subtitle: 'Manage Cuplix+ perks and billing details',
                    onTap: () {
                      // navigate to Subscription management
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Account & Privacy header
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                Text(
                  'Account & Privacy',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                Text(
                  'Manage your personal details and data preferences',
                  style: TextStyle(color: Color(0xFF9A8EA0)),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Account & Privacy tiles
            _roundedCard(
              child: Column(
                children: [
                  _FeatureTile(
                    iconGradient: LinearGradient(
                      colors: [Color(0xFF7AA1FF), Color(0xFF6C8CFF)],
                    ),
                    icon: Icons.person_outline,
                    title: 'Profile',
                    subtitle: 'View your connection stats and badges',
                    onTap: () {
                      // Navigate to Profile screen
                    },
                  ),
                  const SizedBox(height: 10),
                  _FeatureTile(
                    iconGradient: LinearGradient(
                      colors: [Color(0xFF6C7684), Color(0xFF9BA3AE)],
                    ),
                    icon: Icons.edit_outlined,
                    title: 'Edit Profile',
                    subtitle: 'Update bios, avatars, and personal info',
                    onTap: () {
                      // Navigate to Edit Profile screen
                    },
                  ),
                  const SizedBox(height: 10),
                  _FeatureTile(
                    iconGradient: LinearGradient(
                      colors: [Color(0xFF5E5E6B), Color(0xFF3A3A44)],
                    ),
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Center',
                    subtitle: 'Review data controls and permissions',
                    onTap: () {
                      // Navigate to Privacy settings
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Today's Insight Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE7E6F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 42,
                        width: 42,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFFaf57db), Color(0xFFe46791)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Today's Insight",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF2C2139),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Your partner has been showing extra effort this week. "
                    "Consider expressing appreciation – a simple acknowledgment can "
                    "strengthen your bond by 15%.",
                    style: TextStyle(color: Color(0xFF7C748A), height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFEEE6F0)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Take Action',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C2139),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            const SizedBox(height: 18),

            const SizedBox(height: 18),

            const SizedBox(height: 18),

            const SizedBox(height: 18),

            const SizedBox(height: 18),

            const SizedBox(height: 18),

            const SizedBox(height: 18),

            const SizedBox(height: 24),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // helper to create a rounded card container
  static Widget _roundedCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEE6F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8),
        ],
      ),
      child: child,
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final Color badgeColor;
  final IconData badgeIcon;

  const _MetricCard({
    required this.title,
    required this.value,
    this.badgeColor = const Color(0xFFF5A623),
    this.badgeIcon = Icons.star,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // card look
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEE6F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6),
        ],
      ),
      child: Stack(
        children: [
          // content column (shrink to content)
          Column(
            mainAxisSize: MainAxisSize.min,
            // <-- prevents the Column from forcing height
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
              const SizedBox(height: 12),
              // FittedBox prevents the value text from forcing a big height
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28, // visual size, FittedBox will scale if needed
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1036),
                  ),
                ),
              ),
            ],
          ),

          // small circular badge top-right
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              height: 34,
              width: 34,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    badgeColor.withOpacity(0.18),
                    badgeColor.withOpacity(0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(badgeIcon, size: 16, color: badgeColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Small helper widget for a progress row used in Relationship Blueprint
class _ProgressRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double percent; // 0.0 - 1.0

  const _ProgressRow({
    required this.icon,
    required this.label,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    // gradient used for progress bar
    const gradient = LinearGradient(
      colors: [Color(0xFFaf57db), Color(0xFFe46791)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // small circular icon
        Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF4F2B8A), size: 18),
        ),
        const SizedBox(width: 12),

        // label + progress bar expanded
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    '${(percent * 100).round()}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // progress bar background
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    Container(height: 12, color: const Color(0xFFF3EAF6)),
                    // colored filled portion
                    FractionallySizedBox(
                      widthFactor: percent,
                      child: Container(
                        height: 12,
                        decoration: const BoxDecoration(gradient: gradient),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final Color iconColorStart;
  final Color iconColorEnd;
  final IconData icon;
  final String title;
  final String timeAgo;
  final String primaryLabel;
  final Color bgColor;

  const _NotificationCard({
    required this.iconColorStart,
    required this.iconColorEnd,
    required this.icon,
    required this.title,
    required this.timeAgo,
    required this.primaryLabel,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bgColor.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // gradient circular icon
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [iconColorStart, iconColorEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: Icon(icon, color: Colors.white, size: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            timeAgo,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // primary pill button
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey.shade200),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                ),
                child: Text(
                  primaryLabel,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Dismiss',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UnspokenCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String actionLabel;
  final Color bgColor;

  const _UnspokenCard({
    required this.icon,
    required this.title,
    required this.actionLabel,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bgColor.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.0),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withOpacity(0.0)),
                ),
                child: Center(
                  child: Icon(icon, color: Colors.pink.shade400, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // action pill
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.grey.shade200),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            child: Text(
              actionLabel,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {},
            child: const Text('Done', style: TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}

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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEE6F0)),
        ),
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
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
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Color(0xFF9A8EA0)),
                  ),
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
