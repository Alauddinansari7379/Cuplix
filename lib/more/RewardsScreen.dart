import 'package:flutter/material.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        title: const Text(
          'Rewards & Badges',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Celebrate your relationship milestones and unlock premium features',
                style: TextStyle(color: Color(0xFF8B7F91), fontSize: 14),
              ),
              const SizedBox(height: 16),

              // Top KPI cards
              Wrap(
                runSpacing: 14,
                spacing: 14,
                children: [
                  _statCard(
                    icon: Icons.auto_awesome,
                    title: 'Love Points',
                    value: '0',
                    width: width,
                  ),
                  _statCard(
                    icon: Icons.favorite_border,
                    title: 'Day Streak',
                    value: '0',
                    width: width,
                  ),
                  _statCard(
                    icon: Icons.emoji_events_outlined,
                    title: 'Badges Earned',
                    value: '0/8',
                    width: width,
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Badges grid
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Make grid responsive based on available width
                    final availableWidth = constraints.maxWidth;
                    final crossAxisCount = availableWidth < 360 ? 1 : 2;
                    // childAspectRatio = width/height. Lower aspect ratio -> taller tiles.
                    final childAspectRatio = availableWidth < 360 ? 3.6 : 2.0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.emoji_events, color: Color(0xFFAB7BD8)),
                            SizedBox(width: 8),
                            Text(
                              'Your Badges',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        GridView.count(
                          crossAxisCount: crossAxisCount,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: childAspectRatio,
                          children: List.generate(_badgeData.length, (index) {
                            final item = _badgeData[index];
                            return _badgeTile(
                              title: item['title']!,
                              subtitle: item['subtitle']!,
                            );
                          }),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 22),

              // Active Challenges header
              Row(
                children: const [
                  Icon(Icons.flash_on, color: Color(0xFFAB7BD8)),
                  SizedBox(width: 8),
                  Text(
                    'Active Challenges',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Habits -> series of challenge cards
              _sectionCard(
                title: 'Daily Habits',
                children: [
                  _challengeCard(
                    title: 'Daily Appreciation',
                    subtitle: 'Send one compliment to your partner',
                    pointsLabel: '+50 pts',
                    progress: 14 / 30,
                    progressText: '14/30',
                  ),
                  _challengeCard(
                    title: 'Active Listening',
                    subtitle:
                        'Have a 10-minute conversation without distractions',
                    pointsLabel: '+75 pts',
                    progress: 7 / 14,
                    progressText: '7/14',
                  ),
                  _challengeCard(
                    title: 'Memory Sharing',
                    subtitle: 'Add one entry to your couple journal',
                    pointsLabel: '+100 pts',
                    progress: 3 / 7,
                    progressText: '3/7',
                  ),
                ],
              ),

              const SizedBox(height: 14),

              _sectionCard(
                title: 'Weekly Goals',
                children: [
                  _challengeCard(
                    title: 'Conflict Resolution',
                    subtitle: 'Successfully resolve one disagreement',
                    pointsLabel: '+150 pts',
                    progress: 2 / 4,
                    progressText: '2/4',
                  ),
                  _challengeCard(
                    title: 'Quality Time',
                    subtitle: 'Spend 2 hours of uninterrupted time together',
                    pointsLabel: '+125 pts',
                    progress: 1 / 2,
                    progressText: '1/2',
                  ),
                  _challengeCard(
                    title: 'Physical Affection',
                    subtitle: 'Share 5 non-sexual physical touches',
                    pointsLabel: '+75 pts',
                    progress: 3 / 5,
                    progressText: '3/5',
                  ),
                ],
              ),

              const SizedBox(height: 14),

              _sectionCard(
                title: 'Monthly Milestones',
                children: [
                  _challengeCard(
                    title: 'Relationship Check-in',
                    subtitle: 'Complete a full relationship assessment',
                    pointsLabel: '+300 pts',
                    progress: 0 / 1,
                    progressText: '0/1',
                  ),
                  _challengeCard(
                    title: 'New Experience',
                    subtitle: 'Try something new together',
                    pointsLabel: '+200 pts',
                    progress: 0 / 1,
                    progressText: '0/1',
                  ),
                  _challengeCard(
                    title: 'Gratitude Reflection',
                    subtitle: 'Write a letter expressing appreciation',
                    pointsLabel: '+250 pts',
                    progress: 0 / 1,
                    progressText: '0/1',
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Redeem Points Section
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.card_giftcard, color: Color(0xFFAB7BD8)),
                        SizedBox(width: 8),
                        Text(
                          'Redeem Love Points',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    _redeemRow(
                      title: 'Personalized Date Ideas',
                      subtitle:
                          'Get custom date suggestions based on your preferences',
                      pts: '500 pts',
                    ),
                    const SizedBox(height: 10),
                    _redeemRow(
                      title: 'Compatibility Insights',
                      subtitle: 'Unlock advanced compatibility analysis',
                      pts: '750 pts',
                    ),
                    const SizedBox(height: 12),

                    const Divider(),
                    const SizedBox(height: 8),

                    const Text(
                      'Premium Features',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _redeemRow(
                      title: 'Cuplix+ Upgrade',
                      subtitle: 'Unlock premium features and insights',
                      pts: '2500 pts',
                    ),
                    const SizedBox(height: 10),
                    _redeemRow(
                      title: 'Voice Companion Access',
                      subtitle: '24/7 AI relationship therapist',
                      pts: '1500 pts',
                    ),
                    const SizedBox(height: 10),

                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'Special Experiences',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _redeemRow(
                      title: 'Weekly Bond Review',
                      subtitle: 'Detailed relationship analysis report',
                      pts: '1000 pts',
                    ),
                    const SizedBox(height: 10),
                    _redeemRow(
                      title: 'Community Access',
                      subtitle: 'Join our exclusive couple community',
                      pts: '800 pts',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------- Helpers & UI pieces -----------------

Widget _statCard({
  required IconData icon,
  required String title,
  required String value,
  required double width,
}) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          backgroundColor: const Color(0xFFF3E8FB),
          child: Icon(icon, color: const Color(0xFFAB7BD8)),
        ),
        const SizedBox(height: 12),
        Text(title, style: const TextStyle(color: Color(0xFF8B7F91))),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}

Widget _badgeTile({required String title, required String subtitle}) {
  // Use MainAxisSize.min and constrained text to prevent RenderFlex overflow inside tight grid tiles
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFFF6F1F4),
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 2),
        Icon(Icons.favorite_border, size: 20, color: Colors.grey.shade400),
        const SizedBox(height: 8),
        // title allowed to wrap but limited lines
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        // constrain subtitle strongly
        Text(
          subtitle,
          style: const TextStyle(color: Color(0xFFB0A6B2), fontSize: 12),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

Widget _sectionCard({required String title, required List<Widget> children}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFF3E8FB),
              child: Icon(Icons.track_changes, color: const Color(0xFFAB7BD8)),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    ),
  );
}

Widget _challengeCard({
  required String title,
  required String subtitle,
  required String pointsLabel,
  required double progress,
  required String progressText,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFEFE7EE)),
      color: Colors.white,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFFF8E9F8),
              ),
              child: Text(
                pointsLabel,
                style: const TextStyle(
                  color: Color(0xFFAB7BD8),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(subtitle, style: const TextStyle(color: Color(0xFF9B8E99))),
        const SizedBox(height: 10),
        const Text(
          'Progress',
          style: TextStyle(color: Color(0xFF9B8E99), fontSize: 12),
        ),
        const SizedBox(height: 8),
        _progressBar(progress: progress, progressText: progressText),
        const SizedBox(height: 10),
        Row(children: [_gradientButton(label: 'Mark Complete', onTap: () {})]),
      ],
    ),
  );
}

Widget _progressBar({required double progress, required String progressText}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final fullWidth = constraints.maxWidth;
      final fillWidth = fullWidth * progress.clamp(0.0, 1.0);
      return Stack(
        alignment: Alignment.centerRight,
        children: [
          Container(
            height: 14,
            decoration: BoxDecoration(
              color: const Color(0xFFF3EAF0),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          Container(
            height: 14,
            width: fillWidth,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9E56E6), Color(0xFFD95C9F)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          Positioned(
            right: 8,
            child: Text(
              progressText,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      );
    },
  );
}

Widget _gradientButton({required String label, required VoidCallback onTap}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(24),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9E56E6), Color(0xFFD95C9F)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

Widget _redeemRow({
  required String title,
  required String subtitle,
  required String pts,
}) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFEFE7EE)),
      color: Colors.white,
    ),
    child: Row(
      children: [
        Icon(Icons.card_giftcard, color: const Color(0xFFAB7BD8)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Color(0xFF9B8E99))),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF3E8FB),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            pts,
            style: const TextStyle(
              color: Color(0xFFAB7BD8),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}

final List<Map<String, String>> _badgeData = [
  {
    'title': 'Emotional Hero',
    'subtitle': 'Consistently showed emotional intelligence',
  },
  {'title': 'Peacekeeper', 'subtitle': 'Helped resolve conflicts'},
  {'title': 'Listener', 'subtitle': 'Actively listened to your partner'},
  {'title': 'Appreciation Star', 'subtitle': 'Regularly expressed gratitude'},
  {'title': 'Memory Keeper', 'subtitle': 'Complete 10 journal entries'},
  {
    'title': 'Communication Pro',
    'subtitle': 'Have 50 meaningful conversations',
  },
  {'title': 'Consistency Champion', 'subtitle': 'Maintain a 30-day streak'},
  {'title': 'Premium Partner', 'subtitle': 'Upgrade to Cuplix+'},
];
