import 'package:flutter/material.dart';

import 'OnboardingNameScreen.dart';


class OnboardingRoleSelection extends StatefulWidget {
  final String? userEmail; // pass user's email when navigating here

  const OnboardingRoleSelection({super.key, this.userEmail});

  @override
  State<OnboardingRoleSelection> createState() =>
      _OnboardingRoleSelectionState();
}

class _OnboardingRoleSelectionState extends State<OnboardingRoleSelection> {
  String? _selected;
  String? _enteredNameFromNext; // optional: store name returned from name screen

  Widget _roleCard({
    required String id,
    required IconData icon,
    required String label,
  }) {
    final selected = _selected == id;
    return GestureDetector(
      onTap: () => setState(() {
        _selected = id;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFfaf5ff) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFFe6c9ff) : const Color(0xFFEAE6EA),
            width: 1.6,
          ),
          boxShadow: selected
              ? [
            BoxShadow(
              color: const Color(0xFFaf57db).withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 6),
            )
          ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFFF7EDFF),
              ),
              child: Icon(icon, color: const Color(0xFFb76bd6)),
            ),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      foregroundColor: Colors.white,
    ).copyWith(
      backgroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
        if (states.contains(MaterialState.disabled)) return Colors.grey.shade300;
        return const Color(0xFFaf57db);
      }),
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
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 18, offset: const Offset(0, 8))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // progress dots...
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(children: List.generate(6, (i) => Expanded(child: Container(height: 6, margin: const EdgeInsets.symmetric(horizontal: 6), decoration: BoxDecoration(color: i == 0 ? const Color(0xFFd99be9) : const Color(0xFFF0ECEF), borderRadius: BorderRadius.circular(6)))))),
                ),

                const SizedBox(height: 12),
                Center(
                  child: Column(
                    children: [
                      Container(
                        height: 64,
                        width: 64,
                        decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [Color(0xFFaf57db), Color(0xFFe46791)])),
                        child: const Icon(Icons.favorite, color: Colors.white, size: 34),
                      ),
                      const SizedBox(height: 12),
                      const Text('Welcome to Cuplix.AI', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text("Let's get to know you better", style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),

                const SizedBox(height: 22),
                const Text('I am a...', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),

                Column(
                  children: [
                    _roleCard(id: 'husband', icon: Icons.person, label: 'Husband'),
                    const SizedBox(height: 12),
                    _roleCard(id: 'wife', icon: Icons.person_outline, label: 'Wife'),
                    const SizedBox(height: 12),
                    _roleCard(id: 'partner', icon: Icons.favorite_border, label: 'Partner'),
                  ],
                ),

                const SizedBox(height: 22),

                ElevatedButton(
                  onPressed: _selected == null
                      ? null
                      : () async {
                    // Use push so Back returns to this screen
                    final returnedName = await Navigator.push<String?>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OnboardingNameScreen(
                          role: _selected!,
                          initialName: null,
                          email: widget.userEmail,
                        ),
                      ),
                    );

                    // optional: store name returned from name screen
                    if (returnedName != null && returnedName.trim().isNotEmpty) {
                      setState(() {
                        _enteredNameFromNext = returnedName.trim();
                      });
                    }
                  },
                  style: buttonStyle,
                  child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.w600)),
                ),

                if (_enteredNameFromNext != null) ...[
                  const SizedBox(height: 12),
                  Text('Name entered: $_enteredNameFromNext', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
