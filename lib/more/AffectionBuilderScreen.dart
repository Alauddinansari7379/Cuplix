import 'package:flutter/material.dart';

class AffectionBuilderScreen extends StatelessWidget {
  const AffectionBuilderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _Header(),
              SizedBox(height: 14),
              _ProgressCard(),
              SizedBox(height: 18),
              _SectionTitle('Personalized for Today'),
              SizedBox(height: 10),
              _ActionCard(
                title: 'Cook Their Favorite Meal',
                subtitle:
                    'Prepare a homemade dinner with their favorite dishes',
                duration: '30-60 min',
                color: Color(0xFFFFF1D6),
              ),
              SizedBox(height: 10),
              _ActionCard(
                title: 'Send a Voice Note',
                subtitle:
                    'Record a heartfelt message sharing what you appreciate about them',
                duration: '5 min',
                color: Color(0xFFEFF6FF),
              ),
              SizedBox(height: 18),
              _SectionTitle('All Affection Actions'),
              SizedBox(height: 10),
              _AllActionsList(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Icon(Icons.favorite, color: Color(0xFF9B5DE5), size: 26),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Intimacy & Affection Builder',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.05,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Personalized affection gestures to keep emotional spark alive',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      color: const Color(0xFFF7EEF9),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 14.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.auto_awesome, color: Color(0xFF9B5DE5)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Today's Affection Goal",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        '1',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Action to complete',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '0/6',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                ],
              ),
            ),
            SizedBox(
              width: 110,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Completed this week',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: const LinearProgressIndicator(
                      minHeight: 8,
                      value: 0.0,
                      backgroundColor: Colors.white,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF9B5DE5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String duration;
  final Color color;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFEDE6F1)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.restaurant_menu, color: Colors.black54),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.black45),
                const SizedBox(width: 6),
                Text(
                  duration,
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AllActionsList extends StatelessWidget {
  const _AllActionsList();

  @override
  Widget build(BuildContext context) {
    // ✅ Explicitly typed list
    final List<Map<String, dynamic>> items = [
      {
        'title': 'Cook Their Favorite Meal',
        'subtitle': 'Prepare a homemade dinner with their favorite dishes',
        'time': '30-60 min',
        'color': const Color(0xFFFFF1D6),
      },
      {
        'title': 'Send a Voice Note',
        'subtitle':
            'Record a heartfelt message sharing what you appreciate about them',
        'time': '5 min',
        'color': const Color(0xFFEFF6FF),
      },
      {
        'title': 'Plan a Surprise Date',
        'subtitle':
            'Organize an activity you both enjoy but haven\'t done recently',
        'time': '2-3 hours',
        'color': const Color(0xFFEFFAF0),
      },
      {
        'title': 'Create a Memory Book',
        'subtitle':
            'Compile photos and notes from your favorite moments together',
        'time': '1-2 hours',
        'color': const Color(0xFFFFF0F8),
      },
      {
        'title': 'Give a Back Massage',
        'subtitle': 'Offer a relaxing massage after a long day',
        'time': '15-20 min',
        'color': const Color(0xFFFFF1F6),
      },
      {
        'title': 'Write a Compliment List',
        'subtitle': 'List 10 things you love about your partner and share it',
        'time': '10 min',
        'color': const Color(0xFFF3ECFF),
      },
    ];

    return Column(
      children: [
        for (final it in items) ...[
          _ActionCard(
            title: it['title'] as String,
            subtitle: it['subtitle'] as String,
            duration: it['time'] as String,
            color: it['color'] as Color,
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 8),

        // ✅ Gradient button
        SizedBox(
          width: double.infinity,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {},
            child: Ink(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9B5DE5), Color(0xFFFF6FA0)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                alignment: Alignment.center,
                child: const Text(
                  'Get New Suggestions',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
