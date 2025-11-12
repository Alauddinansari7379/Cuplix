import 'package:flutter/material.dart';

class CoupleJournalScreen extends StatelessWidget {
  const CoupleJournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final horizontalPadding = 16.0;
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                PageHeader(),
                SizedBox(height: 14),
                EmotionalTrendsCard(),
                SizedBox(height: 14),
                NewMemoryCard(),
                SizedBox(height: 18),
                RecentMemoriesCard(),
                SizedBox(height: 18),
                CommunicationTipsCard(),
                SizedBox(height: 30),
              ],
            ),
          );
        }),
      ),
    );
  }
}

/* ---------- Header ---------- */
class PageHeader extends StatelessWidget {
  const PageHeader({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF7EEFD),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.bookmark, color: Color(0xFF8A4EF7), size: 22),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Couple Journal',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF2E2A30))),
            SizedBox(height: 4),
            Text('Capture your special moments together',
                style: TextStyle(fontSize: 13, color: Color(0xFF8B8690))),
          ],
        ),
      ],
    );
  }
}

/* ---------- Emotional Trends Card ---------- */
class EmotionalTrendsCard extends StatelessWidget {
  const EmotionalTrendsCard({super.key});
  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.show_chart, color: Color(0xFF8A4EF7), size: 18),
              const SizedBox(width: 8),
              const Expanded(child: Text('Emotional Trends', style: TextStyle(fontWeight: FontWeight.w700))),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: const Text('View Insights'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              EmotionSummary(icon: Icons.sentiment_satisfied_alt, color: Color(0xFFF8E9A6), percent: '65%', label: 'Positive'),
              EmotionSummary(icon: Icons.mood, color: Color(0xFFD5E9FF), percent: '25%', label: 'Neutral'),
              EmotionSummary(icon: Icons.sentiment_very_dissatisfied, color: Color(0xFFEBD6FD), percent: '10%', label: 'Challenging'),
            ],
          ),
        ],
      ),
    );
  }
}

class EmotionSummary extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String percent;
  final String label;
  const EmotionSummary({super.key, required this.icon, required this.color, required this.percent, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: color,
          child: Icon(icon, color: Colors.black54, size: 20),
        ),
        const SizedBox(height: 8),
        Text(percent, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Color(0xFF8B8690), fontSize: 12)),
      ],
    );
  }
}

/* ---------- New Memory Card ---------- */
class NewMemoryCard extends StatefulWidget {
  const NewMemoryCard({super.key});
  @override
  State<NewMemoryCard> createState() => _NewMemoryCardState();
}

class _NewMemoryCardState extends State<NewMemoryCard> {
  String selectedEmotion = 'Neutral';
  final TextEditingController _noteCtrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: const [
          Icon(Icons.add, color: Color(0xFF8A4EF7)),
          SizedBox(width: 8),
          Text('New Memory', style: TextStyle(fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 10),
        const Text('How are you feeling today?', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),

        // Emotion chips row
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _emotionChip('Excited', '😊'),
            _emotionChip('Happy', '🙂'),
            _emotionChip('Neutral', '😐'),
            _emotionChip('Anxious', '😟'),
            _emotionChip('Sad', '☹️'),
          ],
        ),
        const SizedBox(height: 12),

        // Text area
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F3F5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: _noteCtrl,
            maxLines: 5,
            style: const TextStyle(fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'What made today special? How are you feeling?...',
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.camera_alt, size: 18),
              label: const Text('Add Photo'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                side: BorderSide(color: Colors.grey.shade300),
                foregroundColor: Colors.black87,
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                backgroundColor: Colors.transparent,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFCB64F3), Color(0xFFF48CA8)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  constraints: const BoxConstraints(minWidth: 120),
                  alignment: Alignment.center,
                  child: const Text('Add to Journal', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ]),
    );
  }

  Widget _emotionChip(String label, String emoji) {
    final bool selected = label == selectedEmotion;
    return GestureDetector(
      onTap: () => setState(() => selectedEmotion = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF0D9FF) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: selected ? [BoxShadow(color: Colors.purple.withOpacity(0.06), blurRadius: 8)] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

/* ---------- Recent Memories ---------- */
class RecentMemoriesCard extends StatelessWidget {
  const RecentMemoriesCard({super.key});
  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Recent Memories', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F6F7),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            children: const [
              Icon(Icons.book, size: 34, color: Color(0xFFB6B0B9)),
              SizedBox(height: 10),
              Text('No entries yet. Start capturing your special moments!',
                  style: TextStyle(color: Color(0xFF8B8690))),
            ],
          ),
        ),
      ]),
    );
  }
}

/* ---------- Communication Tips ---------- */
class CommunicationTipsCard extends StatelessWidget {
  const CommunicationTipsCard({super.key});
  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
        Text('Communication Tips', style: TextStyle(fontWeight: FontWeight.w700)),
        SizedBox(height: 12),
        TipRow(icon: Icons.chat_bubble_outline, title: 'Active Listening', subtitle: 'Notice how your partner responds. This helps you understand their perspective better.'),
        SizedBox(height: 10),
        TipRow(icon: Icons.auto_awesome, title: 'Safe Practice', subtitle: 'Use this space to rehearse difficult conversations before having them in real life.'),
      ]),
    );
  }
}

class TipRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const TipRow({super.key, required this.icon, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: const Color(0xFFF7EEFD), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: const Color(0xFF8A4EF7), size: 18),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: Color(0xFF8B8690), fontSize: 13)),
        ]),
      ),
    ]);
  }
}

/* ---------- CardContainer helper for consistent style ---------- */
class CardContainer extends StatelessWidget {
  final Widget child;
  const CardContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1EAF3)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }
}