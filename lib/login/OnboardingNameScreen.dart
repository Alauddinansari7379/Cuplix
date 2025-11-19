import 'package:flutter/material.dart';
import '../dashboard/Dashboard.dart';
import 'LoveLanguageTestScreen.dart';

class OnboardingNameScreen extends StatefulWidget {
  final String role;
  final String? initialName;
  final String? email;

  const OnboardingNameScreen({
    super.key,
    required this.role,
    this.initialName,
    this.email,
  });

  @override
  State<OnboardingNameScreen> createState() => _OnboardingNameScreenState();
}

class _OnboardingNameScreenState extends State<OnboardingNameScreen> {
  late TextEditingController _nameController;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final initial =
        widget.initialName?.trim().isNotEmpty == true
            ? widget.initialName!.trim()
            : _nameFromEmail(widget.email);
    _nameController = TextEditingController(text: initial);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _nameFromEmail(String? email) {
    if (email == null || email.trim().isEmpty) return '';
    final prefix = email.split('@').first;
    var cleaned = prefix.replaceAll(RegExp(r'[._\-+]'), ' ');
    cleaned = cleaned.replaceAll(RegExp(r'\d+$'), '').trim();
    if (cleaned.isEmpty) return prefix;
    final parts = cleaned.split(RegExp(r'\s+'));
    final titled = parts
        .map((p) {
          if (p.isEmpty) return p;
          final lower = p.toLowerCase();
          return lower[0].toUpperCase() +
              (lower.length > 1 ? lower.substring(1) : '');
        })
        .join(' ');
    return titled;
  }


  void _onBack() {
    // Return current name to previous screen
    Navigator.pop(context, _nameController.text.trim());
  }

  Future<void> _onContinue() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name')),
      );
      return;
    }

    // Optionally save name & role to server here (show loader)
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600)); // placeholder for API call
    setState(() => _loading = false);

    // Navigate to Love Language Test screen and pass data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoveLanguageTestScreen(
          role: widget.role,
          name: name,
          email: widget.email,
        ),
      ),
    );
  }


  Widget _buildProgressDots() {
    return Row(
      children: List.generate(
        6,
        (i) => Expanded(
          child: Container(
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: i <= 1 ? const Color(0xFFd99be9) : const Color(0xFFF0ECEF),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const gradient = LinearGradient(
      colors: [Color(0xFFaf57db), Color(0xFFe46791)],
    );
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: _buildProgressDots(),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      Container(
                        height: 64,
                        width: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: gradient,
                        ),
                        child: const Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'What should we call you?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Your name helps personalize your experience",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Your Name',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'eg. Somenath',
                    filled: true,
                    fillColor: const Color(0xFFF8F6F8),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _onBack,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child:
                          _loading
                              ? const SizedBox(
                                height: 48,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                              : ElevatedButton(
                                onPressed: _onContinue,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  backgroundColor: const Color(0xFFaf57db),
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Continue'),
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
