import 'package:cuplix/more/AffectionBuilderScreen.dart';
import 'package:cuplix/more/AiAgentScreen.dart';
import 'package:cuplix/more/CoupleJournalScreen.dart';
import 'package:cuplix/more/MirrorModeScreen.dart';
import 'package:flutter/material.dart';

import '../more/AIChatScreen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'All Features',
          style: TextStyle(
            color: Color(0xFF2C2139),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(18, 10, 18, 20 + bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(thickness: 1, color: Color(0xFFEDE7F1)),
              const SizedBox(height: 12),

              // ---------- AI ----------
              const SectionTitle(title: 'AI'),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.95,
                children: [
                  _FeatureTile(
                    icon: Icons.chat_bubble_outline,
                    title: 'AI Chat',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AiChatScreen(),
                        ),
                      );
                    },
                  ),
                  _FeatureTile(
                    icon: Icons.mic_none_rounded,
                    title: 'Voice AI',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AiAgentScreen(),
                        ),
                      );
                    },
                  ),
                  _FeatureTile(
                    icon: Icons.auto_awesome_outlined,
                    title: 'AI Agent',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AiAgentScreen(),
                        ),
                      );
                    },
                  ),
                  _FeatureTile(
                    icon: Icons.star_outline,
                    title: 'Mirror Mode',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MirrorModeScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 26),

              // ---------- Connection ----------
              const SectionTitle(title: 'Connection'),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.05,
                children: [
                  const _FeatureTile(
                    icon: Icons.chat_bubble,
                    title: 'Partner Chat',
                  ),
                  _FeatureTile(
                    icon: Icons.menu_book_outlined,
                    title: 'Journal',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CoupleJournalScreen(),
                        ),
                      );
                    },
                  ),
                  _FeatureTile(
                    icon: Icons.favorite_border,
                    title: 'Affection',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AffectionBuilderScreen(),
                        ),
                      );
                    },
                  ),
                  const _FeatureTile(
                    icon: Icons.headset_mic_outlined,
                    title: 'Therapist',
                  ),
                  const _FeatureTile(
                    icon: Icons.card_giftcard,
                    title: 'Marketplace',
                  ),
                  const _FeatureTile(
                    icon: Icons.emoji_events_outlined,
                    title: 'Rewards',
                  ),
                  const _FeatureTile(
                    icon: Icons.person_add_alt_1_outlined,
                    title: 'Invite Partner',
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ---------- Planning ----------
              const SectionTitle(title: 'Planning'),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.05,
                children: const [
                  _FeatureTile(icon: Icons.calendar_today, title: 'Calendar'),
                  _FeatureTile(
                    icon: Icons.monitor_heart_outlined,
                    title: 'Shared Goals',
                  ),
                  _FeatureTile(icon: Icons.bar_chart, title: 'Compatibility'),
                  _FeatureTile(icon: Icons.music_note, title: 'Mood Music'),
                ],
              ),

              const SizedBox(height: 28),

              // ---------- Health ----------
              const SectionTitle(title: 'Health'),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.05,
                children: const [
                  _FeatureTile(icon: Icons.water_drop_outlined, title: 'Cycle'),
                  _FeatureTile(
                    icon: Icons.nights_stay_outlined,
                    title: 'Sleep',
                  ),
                  _FeatureTile(
                    icon: Icons.monitor_heart_outlined,
                    title: 'Sensors',
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Divider(color: Color(0xFFEDE7F1)),
              const SizedBox(height: 20),

              const SizedBox(height: 16 + 8),
              // breathing room above bottom inset
            ],
          ),
        ),
      ),
    );
  }
}

/// small reusable section title
class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Color(0xFFAF57DB),
        fontSize: 20,
      ),
    );
  }
}

/// ---------- Reusable Feature Tile ----------
class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _FeatureTile({required this.icon, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // Use the provided onTap callback
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEFECEC),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: Icon(icon, color: const Color(0xFF8B7AAE), size: 22),
            ),
            const SizedBox(height: 6),
            Flexible(
              fit: FlexFit.loose,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxW = constraints.maxWidth * 0.95;
                  return ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxW),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF6C627D),
                        fontWeight: FontWeight.w600,
                        fontSize: 13.0,
                        height: 1.05,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
