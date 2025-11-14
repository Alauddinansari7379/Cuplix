import 'package:flutter/material.dart';
import 'CommunicationStyleScreen.dart';

class LoveLanguageTestScreen extends StatefulWidget {
  final String role;
  final String name;
  final String? email;

  const LoveLanguageTestScreen({
    super.key,
    required this.role,
    required this.name,
    this.email,
  });

  @override
  State<LoveLanguageTestScreen> createState() => _LoveLanguageTestScreenState();
}

class _LoveLanguageTestScreenState extends State<LoveLanguageTestScreen> {
  int? _selectedIndex;

  final List<String> _options = [
    'Words of Affirmation',
    'Acts of Service',
    'Quality Time',
    'Physical Touch',
    'Receiving Gifts',
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
              color: i <= 2 ? const Color(0xFFd99be9) : const Color(0xFFF0ECEF),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ),
    );
  }

  Widget _optionCard(int index) {
    final selected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
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
            Expanded(
              child: Text(
                _options[index],
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onBack() {
    Navigator.of(context).pop();
  }


  void _onContinue() {
    if (_selectedIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select one option to continue')));
      return;
    }

    final chosen = _options[_selectedIndex!];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CommunicationStyleScreen(
          role: widget.role,
          name: widget.name,
          email: widget.email,
          loveLanguage: chosen,
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

                const SizedBox(height: 14),

                // icon + title
                Center(
                  child: Column(
                    children: [
                      Container(
                        height: 64,
                        width: 64,
                        decoration: BoxDecoration(shape: BoxShape.circle, gradient: gradient),
                        child: const Icon(Icons.favorite_border, color: Colors.white, size: 34),
                      ),
                      const SizedBox(height: 16),
                      const Text('Love Language Test', textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Discover how you prefer to give and receive love', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                const Text('Which makes you feel most loved?', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 12),

                // options
                ...List.generate(_options.length, (i) => _optionCard(i)),

                const SizedBox(height: 18),

                // buttons
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
                        onPressed: _selectedIndex == null ? null : _onContinue,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          backgroundColor: _selectedIndex == null ? Colors.grey.shade300 : null,
                        ),
                        child: Ink(
                          decoration: const BoxDecoration(
                            gradient: gradient,
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          child: Container(
                            height: 48,
                            alignment: Alignment.center,
                            child: const Text('Continue', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          ),
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
