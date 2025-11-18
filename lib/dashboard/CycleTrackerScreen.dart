// lib/health/cycle_tracker_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CycleTrackerScreen extends StatefulWidget {
  const CycleTrackerScreen({Key? key}) : super(key: key);

  @override
  State<CycleTrackerScreen> createState() => _CycleTrackerScreenState();
}

class _CycleTrackerScreenState extends State<CycleTrackerScreen> {
  bool _trackingEnabled = true;

  final TextEditingController _avgCycleController =
  TextEditingController(text: '28');
  final TextEditingController _periodLengthController =
  TextEditingController(text: '5');

  DateTime? _lastPeriodStart;
  final DateFormat _displayFormat = DateFormat('dd-MM-yyyy');

  @override
  void dispose() {
    _avgCycleController.dispose();
    _periodLengthController.dispose();
    super.dispose();
  }

  Future<void> _pickLastPeriodDate() async {
    final now = DateTime.now();
    final initial = _lastPeriodStart ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _lastPeriodStart = picked);
    }
  }

  void _onSave() {
    // For now just show a snackbar. You can hook this up to an API later.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cycle information saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF5B2FB5);
    const gradient = LinearGradient(
      colors: [Color(0xFFaf57db), Color(0xFFe46791)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFBFF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2C2139)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Icon(Icons.water_drop_outlined,
                      color: Color(0xFFaf57db), size: 30),
                  SizedBox(width: 10),
                  Text(
                    'Cycle Tracker',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2C2139),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Track your menstrual cycle and emotional patterns for '
                    'better relationship harmony',
                style: TextStyle(
                  color: Color(0xFF9A8EA0),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Cycle tracking toggle card
              _card(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Cycle Tracking',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Color(0xFF2C2139),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Enable AI to adapt to your hormonal cycles',
                            style: TextStyle(
                              color: Color(0xFF9A8EA0),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: _trackingEnabled,
                      onChanged: (v) {
                        setState(() => _trackingEnabled = v);
                      },
                      activeColor: Colors.white,
                      activeTrackColor: const Color(0xFFe46791),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Cycle information card
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.calendar_today_rounded,
                            color: Color(0xFFaf57db)),
                        SizedBox(width: 8),
                        Text(
                          'Cycle Information',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: Color(0xFF2C2139),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Average Cycle Length
                    const Text(
                      'Average Cycle Length (days)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _avgCycleController,
                      keyboardType: TextInputType.number,
                      decoration: _fieldDecoration(),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Typically 21–35 days. Default is 28 days.',
                      style: TextStyle(
                        color: Color(0xFF9A8EA0),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Period Length
                    const Text(
                      'Period Length (days)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _periodLengthController,
                      keyboardType: TextInputType.number,
                      decoration: _fieldDecoration(),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Typically 2–7 days. Default is 5 days.',
                      style: TextStyle(
                        color: Color(0xFF9A8EA0),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // First Day of Last Period
                    const Text(
                      'First Day of Last Period',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _pickLastPeriodDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F6F8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE0D6EA)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _lastPeriodStart == null
                                    ? 'dd-mm-yyyy'
                                    : _displayFormat.format(_lastPeriodStart!),
                                style: TextStyle(
                                  color: _lastPeriodStart == null
                                      ? const Color(0xFF9A8EA0)
                                      : const Color(0xFF2C2139),
                                ),
                              ),
                            ),
                            const Icon(Icons.calendar_today_outlined,
                                size: 18, color: Color(0xFF9A8EA0)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'This helps predict your current cycle phase.',
                      style: TextStyle(
                        color: Color(0xFF9A8EA0),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          gradient: gradient,
                          borderRadius: BorderRadius.all(Radius.circular(14)),
                        ),
                        child: ElevatedButton(
                          onPressed: _onSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Save Information',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Understanding your cycle
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.show_chart,
                            color: Color(0xFFaf57db), size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Understanding Your Cycle',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: Color(0xFF2C2139),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Each phase of your cycle brings different energies and '
                          'emotions. Understanding these phases can help you and '
                          'your partner navigate your relationship more harmoniously.',
                      style: TextStyle(
                        color: Color(0xFF9A8EA0),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _PhaseCard(
                      dotColor: Color(0xFFFF4C4C),
                      title: 'Menstrual Phase (Days 1–5)',
                      description:
                      'Bleeding phase. Common symptoms: cramps, fatigue, mood changes.',
                      tip:
                      'Focus on rest and gentle activities. Stay hydrated and eat iron-rich foods.',
                    ),
                    const SizedBox(height: 10),
                    const _PhaseCard(
                      dotColor: Color(0xFFFF4DA6),
                      title: 'Follicular Phase (Days 6–14)',
                      description:
                      'Estrogen rises. Energy levels typically increase. Mood improves.',
                      tip:
                      'Great time for starting new projects. Good for social activities and exercise.',
                    ),
                    const SizedBox(height: 10),
                    const _PhaseCard(
                      dotColor: Color(0xFFFFC93A),
                      title: 'Ovulation Phase (Days 15–18)',
                      description:
                      'Peak fertility. High energy, confidence, and libido.',
                      tip:
                      'Optimal time for important conversations or intimate activities.',
                    ),
                    const SizedBox(height: 10),
                    const _PhaseCard(
                      dotColor: Color(0xFFB071FF),
                      title: 'Luteal Phase (Days 19–28)',
                      description:
                      'Progesterone rises. Possible PMS symptoms. Mood may fluctuate.',
                      tip:
                      'Practice self-care. Be patient with yourself and communicate needs clearly.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // AI Insights
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.bolt, color: primary),
                        SizedBox(width: 8),
                        Text(
                          'AI Insights',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: Color(0xFF2C2139),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const _InsightTile(
                      gradient: LinearGradient(
                        colors: [Color(0xFF7D6BFF), Color(0xFFEF5DA8)],
                      ),
                      icon: Icons.favorite,
                      title: "Today's Insight",
                      body:
                      "You're currently in your follicular phase. This is typically a time of increased energy and creativity. Your partner would appreciate your enthusiasm today!",
                    ),
                    const SizedBox(height: 12),
                    const _InsightTile(
                      gradient: LinearGradient(
                        colors: [Color(0xFFEF5DA8), Color(0xFFB06BF3)],
                      ),
                      icon: Icons.chat_bubble_outline,
                      title: 'Communication Tip',
                      body:
                      "During the luteal phase, it's common to feel more sensitive. Consider sharing your needs directly rather than expecting your partner to read your mind.",
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton(
                        onPressed: () {
                          // open full recommendations screen
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                        ),
                        child: const Text(
                          'View All Recommendations',
                          style: TextStyle(
                            color: primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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

  InputDecoration _fieldDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF8F6F8),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  static Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDE3F4)),
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
}

// ---------- Helper widgets ----------

class _PhaseCard extends StatelessWidget {
  final Color dotColor;
  final String title;
  final String description;
  final String tip;

  const _PhaseCard({
    Key? key,
    required this.dotColor,
    required this.title,
    required this.description,
    required this.tip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDE3F4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF4E3E60),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            tip,
            style: const TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: Color(0xFF9A8EA0),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  final LinearGradient gradient;
  final IconData icon;
  final String title;
  final String body;

  const _InsightTile({
    Key? key,
    required this.gradient,
    required this.icon,
    required this.title,
    required this.body,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            gradient: gradient,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                body,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF4E3E60),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
