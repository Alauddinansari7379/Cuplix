import 'package:cuplix/apiInterface/ApiInterface.dart';
import 'package:cuplix/dashboard/InvitePartnerScreen.dart';
import 'package:cuplix/dashboard/JournalScreen.dart';
import 'package:cuplix/dashboard/MoreScreen.dart';
import 'package:cuplix/dashboard/ProfileScreen.dart';
import 'package:cuplix/dashboard/UpgradeToCuplixScreen.dart';
import 'package:flutter/material.dart';

import '../apiInterface/ApIHelper.dart';
import '../utils/SharedPreferences.dart';
import 'ChatScreen.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0;

  // partner connection state
  bool _isPartnerConnected = false;
  String? _partnerName;
  String? _partnerRole;
  bool _showDisconnectPrompt = false;

  @override
  void initState() {
    super.initState();
    _loadPartnerConnection();
  }

  Future<String?> _getAuthToken() async {
    return SharedPrefs.getAccessToken();
  }

  /// Load current partner connection from GET /partner-connections/me
  Future<void> _loadPartnerConnection() async {
    final token = await _getAuthToken();
    if (token == null || token.isEmpty) return;

    final res = await ApiHelper.getWithAuth(
      url: ApiInterface.partnerConnectionsMe,
      token: token,
      context: context,
      showLoader: false,
    );

    if (!mounted) return;

    if (res['success'] == true) {
      final data = res['data'];
      if (data == null) {
        // not connected
        setState(() {
          _isPartnerConnected = false;
          _partnerName = null;
          _partnerRole = null;
          _showDisconnectPrompt = false;
        });
      } else if (data is Map<String, dynamic>) {
        // connected – try to read partner info
        // (adjust mapping if your API uses different keys)
        Map<String, dynamic>? partnerProfile;

        // many backends send user1/user2 – pick the "other" one,
        // but if not available just use whatever profile is present.
        if (data['partner'] is Map) {
          partnerProfile = (data['partner'] as Map)['profile'];
        } else if (data['user2'] is Map) {
          partnerProfile = (data['user2'] as Map)['profile'];
        } else if (data['user1'] is Map) {
          partnerProfile = (data['user1'] as Map)['profile'];
        }

        setState(() {
          _isPartnerConnected = true;
          _partnerName = partnerProfile?['name']?.toString() ?? 'Alex Doe';
          _partnerRole = partnerProfile?['role']?.toString() ?? 'husband';
        });
      }
    } else {
      // on error we just keep whatever state we had
    }
  }

  Future<void> _openInvitePartner() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InvitePartnerScreen()),
    );

    // after coming back from invite/accept, refresh partner status
    await _loadPartnerConnection();
  }

  void _toggleDisconnectPrompt() {
    setState(() {
      _showDisconnectPrompt = !_showDisconnectPrompt;
    });
  }

  /// Called when user taps "Disconnect" button in red card
  Future<void> _onConfirmDisconnect() async {
    final token = await _getAuthToken();
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login again')),
      );
      return;
    }

    final res = await ApiHelper.deleteWithAuth(
      url: ApiInterface.partnerConnectionsMe, // DELETE /partner-connections/me
      token: token,
      context: context,
      showLoader: true,
    );

    if (!mounted) return;

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Disconnected successfully')),
      );

      setState(() {
        _isPartnerConnected = false;
        _partnerName = null;
        _partnerRole = null;
        _showDisconnectPrompt = false;
      });

      await _loadPartnerConnection();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            res['error']?.toString() ?? 'Failed to disconnect',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // simple content for tabs (ChatScreen is used in-place)
    final List<Widget> pages = <Widget>[
      _DashboardContent(
        isPartnerConnected: _isPartnerConnected,
        partnerName: _partnerName,
        partnerRole: _partnerRole,
        onInvitePartner: _openInvitePartner,
        onTapDisconnectIcon: _toggleDisconnectPrompt,
        showDisconnectPrompt: _showDisconnectPrompt,
        onCancelDisconnect: _toggleDisconnectPrompt,
        onConfirmDisconnect: _onConfirmDisconnect,
      ),
      const ChatScreen(
      ),
      const JournalScreen(), // 👈 Journal screen added
      const ProfileScreen(), // 👈 ProfileScreen screen added
      const MoreScreen(), // 👈 MoreScreen screen added
    ];

    return Scaffold(
      body: pages[_currentIndex],
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
      items: items
          .map(
            (e) => BottomNavigationBarItem(
          icon: Icon(e.icon),
          label: e.label,
        ),
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
  const _DashboardContent({
    Key? key,
    required this.isPartnerConnected,
    required this.partnerName,
    required this.partnerRole,
    required this.onInvitePartner,
    required this.onTapDisconnectIcon,
    required this.showDisconnectPrompt,
    required this.onCancelDisconnect,
    required this.onConfirmDisconnect,
  }) : super(key: key);

  final bool isPartnerConnected;
  final String? partnerName;
  final String? partnerRole;
  final VoidCallback onInvitePartner;
  final VoidCallback onTapDisconnectIcon;
  final bool showDisconnectPrompt;
  final VoidCallback onCancelDisconnect;
  final VoidCallback onConfirmDisconnect;

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

            // Partner section – either original "no partner" card OR connected UI
            if (!isPartnerConnected)
              _roundedCard(child: _noPartnerRow(onInvitePartner))
            else
              Column(
                children: [
                  _connectedPartnerCard(
                    partnerName: partnerName ?? 'Alex Doe',
                    partnerRole: partnerRole ?? 'husband',
                    onTapDisconnectIcon: onTapDisconnectIcon,
                  ),
                  if (showDisconnectPrompt) const SizedBox(height: 12),
                  if (showDisconnectPrompt)
                    _disconnectPromptCard(
                      partnerName: partnerName ?? 'Alex Doe',
                      onCancel: onCancelDisconnect,
                      onConfirm: onConfirmDisconnect,
                    ),
                ],
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
                            builder: (context) => UpgradeToCuplixScreen(),
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

            // ---------- Metrics grid (2 columns) ----------
            Builder(
              builder: (context) {
                final screenWidth = MediaQuery.of(context).size.width;
                const horizontalPadding = 18.0 * 2;
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
                  children: metricItems
                      .map((w) => SizedBox(width: itemWidth, child: w))
                      .toList(),
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
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                  const _ProgressRow(
                    icon: Icons.chat_bubble_outline,
                    label: 'Communication',
                    percent: 0.85,
                  ),
                  const SizedBox(height: 12),
                  const _ProgressRow(
                    icon: Icons.favorite_border,
                    label: 'Emotional Intimacy',
                    percent: 0.78,
                  ),
                  const SizedBox(height: 12),
                  const _ProgressRow(
                    icon: Icons.album,
                    label: 'Shared Values',
                    percent: 0.92,
                  ),
                  const SizedBox(height: 12),
                  const _ProgressRow(
                    icon: Icons.person_search,
                    label: 'Conflict Resolution',
                    percent: 0.72,
                  ),
                  const SizedBox(height: 12),
                  const _ProgressRow(
                    icon: Icons.accessibility_new,
                    label: 'Physical Intimacy',
                    percent: 0.88,
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F0F7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                children: const [
                  _UnspokenHeader(),
                  SizedBox(height: 14),
                  _UnspokenCard(
                    icon: Icons.favorite_border,
                    title:
                    "Today, your partner would appreciate being noticed for his efforts.",
                    actionLabel: "Send a text acknowledging their hard work",
                    bgColor: Color(0xFFFFF3F4),
                  ),
                  SizedBox(height: 12),
                  _UnspokenCard(
                    icon: Icons.favorite,
                    title:
                    "You may be feeling overwhelmed with responsibilities lately.",
                    actionLabel: "Ask your partner for support with daily tasks",
                    bgColor: Color(0xFFF6F0FF),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Communication & AI header
            const _SectionHeader(
              title: 'Communication & AI',
              subtitle:
              'Tools to enhance conversations with your partner and Cuplix AI',
            ),

            const SizedBox(height: 12),

            // Features list
            _roundedCard(
              child: Column(
                children: const [
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
            const _SectionHeader(
              title: 'Memories & Care',
              subtitle:
              'Capture special moments and nurture emotional closeness',
            ),

            const SizedBox(height: 12),

            _roundedCard(
              child: Column(
                children: [
                  const _FeatureTile(
                    iconGradient: LinearGradient(
                      colors: [Color(0xFF4FD77E), Color(0xFF2DB06A)],
                    ),
                    icon: Icons.book_outlined,
                    title: 'Journal',
                    subtitle: 'Capture memories and track emotional trends',
                    onTap: null,
                  ),
                  const SizedBox(height: 10),
                  _FeatureTile(
                    iconGradient: const LinearGradient(
                      colors: [Color(0xFFF47B9A), Color(0xFFEA5E82)],
                    ),
                    icon: Icons.person_add_alt_1,
                    title: 'Invite Partner',
                    subtitle:
                    'Send a personal invite so your partner can join you',
                    onTap: onInvitePartner,
                  ),
                  const SizedBox(height: 10),
                  const _FeatureTile(
                    iconGradient: LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFEE5A5A)],
                    ),
                    icon: Icons.favorite,
                    title: 'Intimacy Builder',
                    subtitle: 'Custom suggestions to maintain emotional spark',
                    onTap: null,
                  ),
                  const SizedBox(height: 10),
                  const _FeatureTile(
                    iconGradient: LinearGradient(
                      colors: [Color(0xFF8E6DF5), Color(0xFFE46791)],
                    ),
                    icon: Icons.health_and_safety,
                    title: 'Therapist Mode',
                    subtitle: 'Conflict analysis with improvement suggestions',
                    onTap: null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Planning & Adventures header
            const _SectionHeader(
              title: 'Planning & Adventures',
              subtitle: 'Organize quality time and shared goals',
            ),

            const SizedBox(height: 12),

            _roundedCard(
              child: Column(
                children: const [
                  _FeatureTile(
                    iconGradient: LinearGradient(
                      colors: [Color(0xFFF5B24A), Color(0xFFF3983E)],
                    ),
                    icon: Icons.calendar_today,
                    title: 'Couple Calendar',
                    subtitle: 'AI-managed scheduling for relationship events',
                    onTap: null,
                  ),
                  SizedBox(height: 10),
                  _FeatureTile(
                    iconGradient: LinearGradient(
                      colors: [Color(0xFFEE6A3D), Color(0xFFEF4A2A)],
                    ),
                    icon: Icons.track_changes,
                    title: 'Shared Goals',
                    subtitle: 'Track goals and dream experiences in one place',
                    onTap: null,
                  ),
                  SizedBox(height: 10),
                  _FeatureTile(
                    iconGradient: LinearGradient(
                      colors: [Color(0xFFF3C451), Color(0xFFF1B33C)],
                    ),
                    icon: Icons.show_chart,
                    title: 'Compatibility',
                    subtitle: 'Deep emotional interaction visualization',
                    onTap: null,
                  ),
                  SizedBox(height: 10),
                  _FeatureTile(
                    iconGradient: LinearGradient(
                      colors: [Color(0xFFF47B9A), Color(0xFFEE5E82)],
                    ),
                    icon: Icons.music_note,
                    title: 'Mood Music',
                    subtitle: 'Personalized playlists for emotional regulation',
                    onTap: null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Health & Wellness header
            const _SectionHeader(
              title: 'Health & Wellness',
              subtitle:
              'Track your well-being and its impact on your relationship',
            ),

            const SizedBox(height: 12),

            _roundedCard(
              child: Column(
                children: const [
                  _FeatureTile(
                    iconGradient: LinearGradient(
                      colors: [Color(0xFFFB7B9A), Color(0xFFEA6A96)],
                    ),
                    icon: Icons.bloodtype,
                    title: 'Cycle Tracker',
                    subtitle:
                    'Hormonal mood insights with gentle reminders',
                    onTap: null,
                  ),
                  SizedBox(height: 10),
                  _FeatureTile(
                    iconGradient: LinearGradient(
                      colors: [Color(0xFF7AA1FF), Color(0xFF6B8CFF)],
                    ),
                    icon: Icons.nightlight_round,
                    title: 'Sleep & Stress',
                    subtitle:
                    'Biological harmony tracking with wellness insights',
                    onTap: null,
                  ),
                  SizedBox(height: 10),
                  _FeatureTile(
                    iconGradient: LinearGradient(
                      colors: [Color(0xFF56D7C6), Color(0xFF2FBEB0)],
                    ),
                    icon: Icons.monitor_heart,
                    title: 'Sensor Tracking',
                    subtitle: 'Real-time emotional and conflict detection',
                    onTap: null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Rewards & Marketplace header
            const _SectionHeader(
              title: 'Rewards & Marketplace',
              subtitle: 'Celebrate each other with thoughtful surprises',
            ),

            const SizedBox(height: 12),

            _roundedCard(
              child: Column(
                children: const [
                  _FeatureTile(
                    iconGradient: LinearGradient(
                      colors: [Color(0xFFF47B9A), Color(0xFFEB5E7C)],
                    ),
                    icon: Icons.card_giftcard,
                    title: 'Gift Marketplace',
                    subtitle: 'AI-recommended gifts and experiences',
                    onTap: null,
                  ),
                  SizedBox(height: 10),
                  _FeatureTile(
                    iconGradient: LinearGradient(
                      colors: [Color(0xFF4FD77E), Color(0xFF2DB06A)],
                    ),
                    icon: Icons.emoji_events,
                    title: 'Rewards',
                    subtitle:
                    'Earn love points and badges for positive actions',
                    onTap: null,
                  ),
                  SizedBox(height: 10),
                  _FeatureTile(
                    iconGradient: LinearGradient(
                      colors: [Color(0xFFF3C451), Color(0xFFEFAE39)],
                    ),
                    icon: Icons.workspace_premium,
                    title: 'Subscription',
                    subtitle: 'Manage Cuplix+ perks and billing details',
                    onTap: null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Account & Privacy header
            const _SectionHeader(
              title: 'Account & Privacy',
              subtitle: 'Manage your personal details and data preferences',
            ),

            const SizedBox(height: 12),

            _roundedCard(
              child: Column(
                children: const [
                  _FeatureTile(
                    iconGradient: LinearGradient(
                      colors: [Color(0xFF7AA1FF), Color(0xFF6C8CFF)],
                    ),
                    icon: Icons.person_outline,
                    title: 'Profile',
                    subtitle: 'View your connection stats and badges',
                    onTap: null,
                  ),
                  SizedBox(height: 10),
                  _FeatureTile(
                    iconGradient: LinearGradient(
                      colors: [Color(0xFF6C7684), Color(0xFF9BA3AE)],
                    ),
                    icon: Icons.edit_outlined,
                    title: 'Edit Profile',
                    subtitle: 'Update bios, avatars, and personal info',
                    onTap: null,
                  ),
                  SizedBox(height: 10),
                  _FeatureTile(
                    iconGradient: LinearGradient(
                      colors: [Color(0xFF5E5E6B), Color(0xFF3A3A44)],
                    ),
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Center',
                    subtitle: 'Review data controls and permissions',
                    onTap: null,
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

  // original "no partner connected" row
  static Widget _noPartnerRow(VoidCallback onInvitePartner) {
    return Row(
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
          onPressed: onInvitePartner,
          icon: const Icon(Icons.person_add, size: 18),
          label: const Text('Invite Partner'),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  // connected partner green card (third image)
  static Widget _connectedPartnerCard({
    required String partnerName,
    required String partnerRole,
    required VoidCallback onTapDisconnectIcon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF9EE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFB7E6C5)),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFD5F3DF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.people, color: Color(0xFF1B8733)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connected with $partnerName',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF20C05C),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '✓ Active',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• $partnerRole',
                      style: const TextStyle(
                        color: Color(0xFF7C8A8C),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onTapDisconnectIcon,
            icon: const Icon(
              Icons.person_off,
              color: Colors.redAccent,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  // red "Disconnect" prompt (fifth image)
  static Widget _disconnectPromptCard({
    required String partnerName,
    required VoidCallback onCancel,
    required VoidCallback onConfirm,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF5C2C2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 32,
                width: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFFAD4D7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_off,
                  color: Color(0xFFE53935),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Disconnect from $partnerName?',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'This will end your partnership. You can reconnect anytime by sharing codes again.',
            style: TextStyle(
              color: Color(0xFF9E5656),
              fontSize: 13,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFE0E0E0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text(
                    'Disconnect',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ===== helper widgets below are unchanged from your file =====

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
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
              const SizedBox(height: 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1036),
                  ),
                ),
              ),
            ],
          ),
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

class _ProgressRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double percent;

  const _ProgressRow({
    required this.icon,
    required this.label,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    const gradient = LinearGradient(
      colors: [Color(0xFFaf57db), Color(0xFFe46791)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
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
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    Container(height: 12, color: const Color(0xFFF3EAF6)),
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
                child:
                Center(child: Icon(icon, color: Colors.white, size: 18)),
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
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.grey.shade200),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            child: Text(
              actionLabel,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {},
            child: const Text(
              'Done',
              style: TextStyle(color: Colors.black87),
            ),
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

class _UnspokenHeader extends StatelessWidget {
  const _UnspokenHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
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
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(color: Color(0xFF9A8EA0)),
        ),
      ],
    );
  }
}
