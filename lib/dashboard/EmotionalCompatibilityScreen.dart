import 'package:flutter/material.dart';

class EmotionalCompatibilityScreen extends StatelessWidget {
  const EmotionalCompatibilityScreen({Key? key}) : super(key: key);

  static const Color _primaryPurple = Color(0xFF5C2D91);
  static const Color _mutedText = Color(0xFF9A8EA0);
  static const Color _cardBg = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF8FB),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Emotional Compatibility',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header title
              Row(
                children: [
                  Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFd38bff), width: 2),
                    ),
                    child: const Icon(Icons.favorite_border,
                        color: Color(0xFFd38bff), size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Emotional Compatibility',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: _primaryPurple,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                "Visualize how your emotions interact with your partner's",
                style: TextStyle(color: _mutedText, fontSize: 14),
              ),
              const SizedBox(height: 20),

              // ----- Your Emotional Profile -----
              _roundedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _circleBadge('You'),
                        const SizedBox(width: 10),
                        const Text(
                          'Your Emotional Profile',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: _primaryPurple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _emotionRow('Joy', 0.85, Colors.amber),
                    const SizedBox(height: 10),
                    _emotionRow('Calm', 0.72, Colors.blueAccent),
                    const SizedBox(height: 10),
                    _emotionRow('Anxiety', 0.25, Colors.purpleAccent),
                    const SizedBox(height: 10),
                    _emotionRow('Frustration', 0.18, Colors.redAccent),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ----- Partner Emotional Profile -----
              _roundedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _circleBadge('P', gradient: const LinearGradient(
                          colors: [Color(0xFF82d4ff), Color(0xFFd07cff)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )),
                        const SizedBox(width: 10),
                        const Text(
                          "Partner's Emotional Profile",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: _primaryPurple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _emotionRow('Joy', 0.68, Colors.amber),
                    const SizedBox(height: 10),
                    _emotionRow('Calm', 0.82, Colors.blueAccent),
                    const SizedBox(height: 10),
                    _emotionRow('Anxiety', 0.42, Colors.purpleAccent),
                    const SizedBox(height: 10),
                    _emotionRow('Frustration', 0.31, Colors.redAccent),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ----- Interaction Patterns -----
              _roundedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.bar_chart,
                            color: Color(0xFFd38bff), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Interaction Patterns',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _interactionPatternTile(
                      title: "When you're stressed",
                      subtitle: 'She tends to withdraw',
                      moodLabel: 'Neutral',
                      moodColor: const Color(0xFFFFE7A5),
                    ),
                    const SizedBox(height: 10),
                    _interactionPatternTile(
                      title: "When she's sad",
                      subtitle: 'Your reassurance helps most',
                      moodLabel: 'Positive',
                      moodColor: const Color(0xFFB8F3C2),
                    ),
                    const SizedBox(height: 10),
                    _interactionPatternTile(
                      title: 'During arguments',
                      subtitle: 'Both raise voices within 30 seconds',
                      moodLabel: 'Negative',
                      moodColor: const Color(0xFFFFC7C5),
                    ),
                    const SizedBox(height: 10),
                    _interactionPatternTile(
                      title: 'After disagreements',
                      subtitle: 'You both need 2 hours to cool down',
                      moodLabel: 'Neutral',
                      moodColor: const Color(0xFFFFE7A5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ----- Emotional Chemistry Chart (simple summary) -----
              _roundedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.bolt,
                            color: Color(0xFFd38bff), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Emotional Chemistry Chart',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // placeholder area for chart
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F3FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Chart coming soon',
                        style: TextStyle(color: _mutedText),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('Joy', style: TextStyle(color: _mutedText)),
                        Text('Calm', style: TextStyle(color: _mutedText)),
                        Text('Anxiety', style: TextStyle(color: _mutedText)),
                        Text('Frustration',
                            style: TextStyle(color: _mutedText)),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Compatibility Score: 76%',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF9140FF),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Your emotional patterns complement each other well',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _mutedText),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ----- AI Insight -----
              _roundedCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 46,
                      width: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7ED0FF), Color(0xFFB96CFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(Icons.show_chart,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AI Insight',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "When you're stressed, your partner's calming presence helps "
                                "reduce your anxiety by 23%. This is a strong positive interaction "
                                "pattern that you can leverage during challenging times.",
                            style: TextStyle(color: _mutedText, height: 1.35),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () {
                              // TODO: navigate to deeper analytics
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                              side: const BorderSide(
                                color: Color(0xFFd38bff),
                              ),
                            ),
                            child: const Text(
                              'View Detailed Analysis',
                              style: TextStyle(
                                color: _primaryPurple,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- helpers ----------

  static Widget _roundedCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  static Widget _circleBadge(
      String text, {
        LinearGradient? gradient,
      }) {
    return Container(
      height: 34,
      width: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: gradient ??
            const LinearGradient(
              colors: [Color(0xFFff8bd6), Color(0xFFff5b9f)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  static Widget _emotionRow(String label, double value, Color barColor) {
    final percentage = (value * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const Spacer(),
            Text(
              '$percentage%',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _primaryPurple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0E8F5),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value.clamp(0.0, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _interactionPatternTile({
    required String title,
    required String subtitle,
    required String moodLabel,
    required Color moodColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF8FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3E6FF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.favorite,
              size: 18, color: Color(0xFFD38BFF)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _mutedText,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: moodColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              moodLabel,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
