// lib/journal/journal_screen.dart
import 'package:flutter/material.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  String _selectedMood = 'Neutral';
  final TextEditingController _noteController = TextEditingController();

  final Map<String, IconData> moods = {
    'Excited': Icons.emoji_emotions_outlined,
    'Happy': Icons.sentiment_satisfied_outlined,
    'Neutral': Icons.sentiment_neutral_outlined,
    'Anxious': Icons.sentiment_dissatisfied_outlined,
  };

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _pickMood(String mood) {
    setState(() => _selectedMood = mood);
  }

  void _addPhoto() {
    // TODO: wire image picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Photo pressed (demo)')),
    );
  }

  void _addToJournal() {
    final note = _noteController.text.trim();
    // TODO: save mood + note + photo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved: $_selectedMood — ${note.isEmpty ? "(no note)" : note}')),
    );
    _noteController.clear();
    setState(() => _selectedMood = 'Neutral');
  }

  @override
  Widget build(BuildContext context) {
    const primaryText = Color(0xFF2C2139);
    const mutedText = Color(0xFF9A8EA0);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Couple Journal', style: TextStyle(color: primaryText, fontWeight: FontWeight.bold)),
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
                'Capture your special moments together',
                style: TextStyle(color: mutedText),
              ),
              const SizedBox(height: 18),

              // Emotional Trends card
              _roundedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.show_chart, color: Color(0xFFaf57db)),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text('Emotional Trends',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            // TODO: open insights
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Colors.grey.shade200),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          child: const Text('View Insights'),
                        )
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _TrendItem(
                          color: const Color(0xFFFFF0D9),
                          iconColor: const Color(0xFFF3C451),
                          label: 'Positive',
                          percent: '65%',
                        ),
                        _TrendItem(
                          color: const Color(0xFFEFF4FF),
                          iconColor: const Color(0xFF7AA1FF),
                          label: 'Neutral',
                          percent: '25%',
                        ),
                        _TrendItem(
                          color: const Color(0xFFF4EEFF),
                          iconColor: const Color(0xFFB890F6),
                          label: 'Challenging',
                          percent: '10%',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // New Memory card
              _roundedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.add, color: Color(0xFFaf57db)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text('New Memory', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('How are you feeling today?', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),

                    // Mood chips row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: moods.keys.map((m) {
                          final selected = _selectedMood == m;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              label: Row(
                                children: [
                                  Icon(moods[m], size: 18, color: selected ? Colors.white : Colors.black54),
                                  const SizedBox(width: 8),
                                  Text(m, style: TextStyle(color: selected ? Colors.white : Colors.black87)),
                                ],
                              ),
                              selected: selected,
                              onSelected: (_) => _pickMood(m),
                              selectedColor: const LinearGradient(
                                colors: [Color(0xFFaf57db), Color(0xFFe46791)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).colors.first,
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Note input
                    TextField(
                      controller: _noteController,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: 'What made today special? How are you feeling?...',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: _addPhoto,
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text('Add Photo'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade200),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        // Gradient Add to Journal button
                        Container(
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFaf57db), Color(0xFFe46791)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ElevatedButton(
                            onPressed: _addToJournal,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 18),
                            ),
                            child: const Text(
                              'Add to Journal',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

// ------------------- Recent Memories Section -------------------
              const Text(
                'Recent Memories',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF2C2139),
                ),
              ),
              const SizedBox(height: 12),

              _roundedCard(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Icon(Icons.menu_book_outlined, size: 48, color: Color(0xFFB9AFC0)),
                    SizedBox(height: 12),
                    Text(
                      'No entries yet. Start capturing your special moments!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF9A8EA0),
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

}

/// small rounded card used across dashboard & journal
Widget _roundedCard({required Widget child}) {
  return Container(
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

/// Trend item
class _TrendItem extends StatelessWidget {
  final Color color;
  final Color iconColor;
  final String percent;
  final String label;

  const _TrendItem({
    required this.color,
    required this.iconColor,
    required this.percent,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Center(child: Icon(Icons.sentiment_satisfied, color: iconColor)),
        ),
        const SizedBox(height: 8),
        Text(percent, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Color(0xFF9A8EA0))),
      ],
    );
  }
}
