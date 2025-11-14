// file: relationship_goals_screen.dart
import 'package:flutter/material.dart';
import '../dashboard/dashboard.dart';

class RelationshipGoalsScreen extends StatefulWidget {
  final String role;
  final String name;
  final String? email;
  final Map<String, dynamic>? previousAnswers; // optional payload from earlier steps

  const RelationshipGoalsScreen({
    super.key,
    required this.role,
    required this.name,
    this.email,
    this.previousAnswers,
  });

  @override
  State<RelationshipGoalsScreen> createState() =>
      _RelationshipGoalsScreenState();
}

class _RelationshipGoalsScreenState extends State<RelationshipGoalsScreen> {
  // goal options
  final List<String> _goals = [
    'Fun & Adventure',
    'Peace & Stability',
    'Deep Intimacy',
    'Personal Growth',
    'Family Building',
    'Spiritual Connection',
  ];

  final Set<int> _selectedIndexes = {};

  bool _loading = false;

  Widget _buildProgressDots() {
    return Row(
      children: List.generate(
        6,
            (i) => Expanded(
          child: Container(
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: i <= 5 ? const Color(0xFFd99be9) : const Color(0xFFF0ECEF),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleIndex(int i) {
    setState(() {
      if (_selectedIndexes.contains(i))
        _selectedIndexes.remove(i);
      else
        _selectedIndexes.add(i);
    });
  }

  bool _hasSelection() => _selectedIndexes.isNotEmpty;

  Future<void> _onComplete() async {
    if (!_hasSelection()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one goal to continue')),
      );
      return;
    }

    setState(() => _loading = true);

    // prepare payload merging previous answers
    final payload = <String, dynamic>{
      'role': widget.role,
      'name': widget.name,
      'email': widget.email,
      'relationshipGoals': _selectedIndexes.map((i) => _goals[i]).toList(),
      if (widget.previousAnswers != null) ...widget.previousAnswers!
    };

    try {
      // TODO: send payload to backend with your ApiHelper; here we simulate a delay
      await Future.delayed(const Duration(milliseconds: 700));
      setState(() => _loading = false);

      // navigate to final screen (Dashboard). Replace if you have a dedicated "complete" screen.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Dashboard()),
      );
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to complete setup: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const gradient = LinearGradient(colors: [Color(0xFFaf57db), Color(0xFFe46791)]);

    // responsive tile width: two columns on mobile-ish layout
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 720;
    final tileWidth = isWide ? 240.0 : (width - 120) / 2; // subtract margins/padding

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFF),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 560,
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 18, offset: const Offset(0, 8))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // progress dots (top)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: List.generate(
                      6,
                          (i) => Expanded(
                        child: Container(
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: i <= 5 ? const Color(0xFFd99be9) : const Color(0xFFF0ECEF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // header icon + title + subtitle
                Center(
                  child: Column(
                    children: [
                      Container(
                        height: 64,
                        width: 64,
                        decoration: BoxDecoration(shape: BoxShape.circle, gradient: gradient),
                        child: const Icon(Icons.icecream, color: Colors.white, size: 34),
                      ),
                      const SizedBox(height: 16),
                      const Text('Relationship Goals', textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('What matters most to you in your relationship?', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                const Text('What are your relationship goals? (Select all that apply)', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),

                // goal tiles
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: List.generate(_goals.length, (i) {
                    final selected = _selectedIndexes.contains(i);
                    return GestureDetector(
                      onTap: () => _toggleIndex(i),
                      child: Container(
                        width: tileWidth,
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
                        decoration: BoxDecoration(
                          color: selected ? const Color(0xFFfaf5ff) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected ? const Color(0xFFb76bd6) : Colors.grey.shade300,
                            width: selected ? 2.0 : 1.2,
                          ),
                          boxShadow: selected ? [BoxShadow(color: const Color(0xFFb76bd6).withOpacity(0.04), blurRadius: 8, offset: const Offset(0,6))] : null,
                        ),
                        child: Text(
                          _goals[i],
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: selected ? const Color(0xFF5a0d6f) : Colors.black),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 18),

                // info card
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7EEF8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Personalized AI Guidance', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text(
                        'Based on your age and responses, Cuplix will provide age-appropriate relationship guidance tailored to your life stage.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                // bottom buttons: Back, Complete Setup
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _loading
                          ? const SizedBox(height: 48, child: Center(child: CircularProgressIndicator()))
                          : ElevatedButton(
                        onPressed: _hasSelection() ? _onComplete : () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one goal')));
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Container(
                          height: 48,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: [Color(0xFFaf57db), Color(0xFFe46791)]),
                            borderRadius: BorderRadius.all(Radius.circular(14)),
                          ),
                          child: const Text('Complete Setup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
