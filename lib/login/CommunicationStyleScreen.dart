import 'package:flutter/material.dart';
import 'package:cuplix/login/ComfortZonesNeedsScreen.dart';

class CommunicationStyleScreen extends StatefulWidget {
  final String role;
  final String name;
  final String? email;
  final String loveLanguage;

  const CommunicationStyleScreen({
    super.key,
    required this.role,
    required this.name,
    this.email,
    required this.loveLanguage,
  });

  @override
  State<CommunicationStyleScreen> createState() => _CommunicationStyleScreenState();
}

class _CommunicationStyleScreenState extends State<CommunicationStyleScreen> {
  // two groups
  int? _conflictChoice; // group 1: In a conflict, I usually:
  int? _styleChoice; // group 2: My communication style:

  final List<String> _conflictOptions = [
    'Stand my ground and express my views',
    'Withdraw to process my emotions first',
    'Shut down emotionally to protect myself',
    'Seek to understand and find solutions',
  ];

  final List<String> _styleOptions = [
    'Direct and to the point',
    'Emotionally expressive',
    'Thoughtful and analytical',
    'Supportive and nurturing',
  ];

  Widget _buildProgressDots() {
    return Row(
      children: List.generate(
        6,
            (i) => Expanded(
          child: Container(
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: i <= 3 ? const Color(0xFFd99be9) : const Color(0xFFF0ECEF),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ),
    );
  }

  Widget _optionCard(String text, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFfaf5ff) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFFb76bd6) : const Color(0xFFEAE6EA),
            width: selected ? 2.0 : 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? const Color(0xFFb76bd6) : Colors.grey.shade400,
                  width: selected ? 2 : 1.4,
                ),
              ),
              child: Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? const Color(0xFFb76bd6) : Colors.transparent,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
          ],
        ),
      ),
    );
  }

  void _onBack() => Navigator.pop(context);

  void _onContinue() {
    if (_conflictChoice == null || _styleChoice == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please answer both questions to continue')));
      return;
    }

    final conflictAnswer = _conflictOptions[_conflictChoice!];
    final styleAnswer = _styleOptions[_styleChoice!];

    // TODO: send collected data to backend if needed:
    // widget.role, widget.name, widget.email, widget.loveLanguage, conflictAnswer, styleAnswer

    // Navigate to ComfortZonesNeedsScreen and pass the required fields
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ComfortZonesNeedsScreen(
          role: widget.role,
          name: widget.name,
          email: widget.email,
          loveLanguage: widget.loveLanguage,
          communicationStyle: '$conflictAnswer | $styleAnswer',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const gradient = LinearGradient(colors: [Color(0xFFaf57db), Color(0xFFe46791)]);
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFF),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            width: 560,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 18, offset: const Offset(0, 8))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // progress
                Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: _buildProgressDots()),

                const SizedBox(height: 12),

                // icon + title
                Center(
                  child: Column(
                    children: [
                      Container(
                        height: 64,
                        width: 64,
                        decoration: BoxDecoration(shape: BoxShape.circle, gradient: gradient),
                        child: const Icon(Icons.account_tree, color: Colors.white, size: 34),
                      ),
                      const SizedBox(height: 16),
                      const Text('Communication Style', textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Understanding how you communicate and handle conflicts', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                const Text('In a conflict, I usually:', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),

                // group 1
                ...List.generate(
                  _conflictOptions.length,
                      (i) => _optionCard(
                    _conflictOptions[i],
                    _conflictChoice == i,
                        () => setState(() => _conflictChoice = i),
                  ),
                ),

                const SizedBox(height: 18),

                const Text('My communication style:', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),

                // group 2
                ...List.generate(
                  _styleOptions.length,
                      (i) => _optionCard(
                    _styleOptions[i],
                    _styleChoice == i,
                        () => setState(() => _styleChoice = i),
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _onBack,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: (_conflictChoice != null && _styleChoice != null) ? _onContinue : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ).copyWith(
                          backgroundColor: MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.disabled)) return Colors.grey.shade300;
                            return null;
                          }),
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: gradient,
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          height: 48,
                          alignment: Alignment.center,
                          child: const Text('Continue', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
