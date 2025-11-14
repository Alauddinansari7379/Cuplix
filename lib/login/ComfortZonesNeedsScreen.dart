// file: comfort_zones_needs_screen.dart
import 'package:flutter/material.dart';
import '../dashboard/dashboard.dart'; // adjust path if needed
import 'package:intl/intl.dart';

class ComfortZonesNeedsScreen extends StatefulWidget {
  final String role;
  final String name;
  final String? email;
  final String? loveLanguage;
  final String? communicationStyle; // optional passed data

  const ComfortZonesNeedsScreen({
    super.key,
    required this.role,
    required this.name,
    this.email,
    this.loveLanguage,
    this.communicationStyle,
  });

  @override
  State<ComfortZonesNeedsScreen> createState() => _ComfortZonesNeedsScreenState();
}

class _ComfortZonesNeedsScreenState extends State<ComfortZonesNeedsScreen> {
  // Multi-select choices
  final List<_TileChoice> _comfortChoices = [
    _TileChoice('home', 'Home', Icons.home),
    _TileChoice('work', 'Work', Icons.work),
    _TileChoice('social', 'Social Events', Icons.people),
    _TileChoice('alone', 'Alone Time', Icons.self_improvement),
  ];
  final Set<String> _selectedComforts = {};

  // Text controllers
  final TextEditingController _emotionalNeedsController = TextEditingController();
  final TextEditingController _expectationsController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _placeOfBirthController = TextEditingController();

  // Dropdown (religion)
  final List<String> _religions = ['Hindu', 'Christian', 'Muslim', 'Sikh', 'Buddhist', 'Other'];
  String? _selectedReligion;

  // DOB and togetherness
  DateTime? _dob;
  DateTime? _togetherSince;

  // religiosity slider (0..10)
  double _religiosity = 5;

  bool _loading = false;

  // For formatting
  final DateFormat _displayDateFormat = DateFormat('dd-MM-yyyy');

  @override
  void dispose() {
    _emotionalNeedsController.dispose();
    _expectationsController.dispose();
    _mobileController.dispose();
    _placeOfBirthController.dispose();
    super.dispose();
  }

  // Helper: age in years
  int _ageYears(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final initial = _dob ?? DateTime(now.year - 25);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _pickTogetherSince() async {
    final now = DateTime.now();
    final initial = _togetherSince ?? DateTime(now.year - 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) setState(() => _togetherSince = picked);
  }

  bool _isValidMobile(String s) {
    final digits = s.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 7 && digits.length <= 15; // len check
  }

  bool _allRequiredValid() {
    // Required: at least one comfort, emotional needs not empty, expectations not empty, DOB provided and >=13
    if (_selectedComforts.isEmpty) return false;
    if (_emotionalNeedsController.text.trim().isEmpty) return false;
    if (_expectationsController.text.trim().isEmpty) return false;
    if (_dob == null) return false;
    if (_ageYears(_dob!) < 13) return false;
    // mobile is optional; if provided must be valid
    final mobileText = _mobileController.text.trim();
    if (mobileText.isNotEmpty && !_isValidMobile(mobileText)) return false;
    // togetherSince optional but if provided shouldn't be future
    if (_togetherSince != null && _togetherSince!.isAfter(DateTime.now())) return false;
    return true;
  }

  Future<void> _onContinue() async {
    // Check and show specific errors to the user
    if (_selectedComforts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one comfort zone.')));
      return;
    }
    if (_emotionalNeedsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please describe what you need emotionally from your partner.')));
      return;
    }
    if (_expectationsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please describe what you expect from your partner.')));
      return;
    }
    if (_dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select your date of birth.')));
      return;
    }
    final age = _ageYears(_dob!);
    if (age < 13) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('You must be at least 13 years old. Current age: $age')));
      return;
    }
    final mobileText = _mobileController.text.trim();
    if (mobileText.isNotEmpty && !_isValidMobile(mobileText)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid mobile number (7-15 digits).')));
      return;
    }
    if (_togetherSince != null && _togetherSince!.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Journey start date cannot be in the future.')));
      return;
    }

    // All good -> prepare payload
    final payload = {
      'role': widget.role,
      'name': widget.name,
      'email': widget.email,
      'comfortZones': _selectedComforts.toList(),
      'emotionalNeeds': _emotionalNeedsController.text.trim(),
      'expectations': _expectationsController.text.trim(),
      'mobile': _mobileController.text.trim().isEmpty ? null : _mobileController.text.trim(),
      'dateOfBirth': _dob != null ? DateFormat('yyyy-MM-dd').format(_dob!) : null,
      'religion': _selectedReligion,
      'placeOfBirth': _placeOfBirthController.text.trim().isEmpty ? null : _placeOfBirthController.text.trim(),
      'religiosity': _religiosity.round(),
      'togetherSince': _togetherSince != null ? DateFormat('yyyy-MM-dd').format(_togetherSince!) : null,
      // add other onboarding fields if needed
    };

    setState(() => _loading = true);

    try {
      // TODO: call your backend here (e.g. ApiHelper.post(...))
      // For now we simulate a delay
      await Future.delayed(const Duration(milliseconds: 700));

      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Onboarding data saved.')));

      // Navigate to next screen (Dashboard). Replace with the real next step if required.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Dashboard()),
      );
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save data: $e')));
    }
  }

  Widget _buildProgressDots(int filledUpTo) {
    return Row(
      children: List.generate(
        6,
            (i) => Expanded(
          child: Container(
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: i <= filledUpTo ? const Color(0xFFd99be9) : const Color(0xFFF0ECEF),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
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
                Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: _buildProgressDots(4)),
                const SizedBox(height: 12),

                // Icon & Title
                Center(
                  child: Column(
                    children: [
                      Container(
                        height: 64,
                        width: 64,
                        decoration: BoxDecoration(shape: BoxShape.circle, gradient: gradient),
                        child: const Icon(Icons.home_outlined, color: Colors.white, size: 34),
                      ),
                      const SizedBox(height: 12),
                      const Text('Comfort Zones & Needs', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Understanding your emotional landscape', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                const Text('Where do you feel most comfortable? (Select all that apply)', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),

                // Comfort chips (grid-like)
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _comfortChoices.map((c) {
                    final selected = _selectedComforts.contains(c.id);
                    return GestureDetector(
                      onTap: () => setState(() {
                        if (selected) _selectedComforts.remove(c.id);
                        else _selectedComforts.add(c.id);
                      }),
                      child: Container(
                        width: (MediaQuery.of(context).size.width > 700) ? 120 : (MediaQuery.of(context).size.width - 120) / 4,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: selected ? const Color(0xFFfaf5ff) : Colors.white,
                          border: Border.all(color: selected ? const Color(0xFFb76bd6) : Colors.grey.shade300),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(c.icon, color: const Color(0xFFb76bd6)),
                            const SizedBox(height: 8),
                            Text(c.label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 18),

                const Text('What do you need emotionally from your partner?', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: _emotionalNeedsController,
                  minLines: 3,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: 'Describe what makes you feel emotionally supported...',
                    filled: true,
                    fillColor: const Color(0xFFF8F6F8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),

                const SizedBox(height: 18),

                const Text('What do you expect from your partner?', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: _expectationsController,
                  minLines: 3,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: 'What behaviors or actions are important to you from your partner?',
                    filled: true,
                    fillColor: const Color(0xFFF8F6F8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),
                const Text('Additional Information', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),

                const Text('Mobile Number', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Optional: for account security and notifications',
                    filled: true,
                    fillColor: const Color(0xFFF8F6F8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 12),

                const Text('Date of Birth', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickDob,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F6F8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _dob == null ? 'Select date of birth' : _displayDateFormat.format(_dob!),
                            style: TextStyle(color: _dob == null ? Colors.grey.shade600 : Colors.black),
                          ),
                        ),
                        const Icon(Icons.calendar_today_outlined),
                      ],
                    ),
                  ),
                ),
                if (_dob != null) ...[
                  const SizedBox(height: 6),
                  Text('Age: ${_ageYears(_dob!)} years old', style: const TextStyle(color: Colors.grey)),
                ],
                const SizedBox(height: 12),

                const Text('Religion', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedReligion,
                  items: [null, ..._religions].map((r) {
                    if (r == null) return const DropdownMenuItem<String>(value: null, child: Text('Select religion'));
                    return DropdownMenuItem(value: r, child: Text(r));
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedReligion = v),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF8F6F8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                ),

                const SizedBox(height: 12),
                const Text('Place of Birth', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: _placeOfBirthController,
                  decoration: InputDecoration(
                    hintText: 'Where were you born?',
                    filled: true,
                    fillColor: const Color(0xFFF8F6F8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),

                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('How religious are you?', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text('${_religiosity.round()}/10', style: const TextStyle(color: Color(0xFFaf57db), fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFF8F6F8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      Slider(
                        value: _religiosity,
                        min: 0,
                        max: 10,
                        divisions: 10,
                        label: _religiosity.round().toString(),
                        onChanged: (v) => setState(() => _religiosity = v),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _religiosity <= 3
                            ? 'Not religious'
                            : (_religiosity <= 7 ? 'Spiritual' : 'Devout'),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                const Text('When did your journey of togetherness start?', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickTogetherSince,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F6F8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(_togetherSince == null ? 'dd-mm-yyyy' : _displayDateFormat.format(_togetherSince!))),
                        const Icon(Icons.calendar_month_outlined),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: const Text('Back'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _loading
                          ? const SizedBox(height: 48, child: Center(child: CircularProgressIndicator()))
                          : ElevatedButton(
                        onPressed: _allRequiredValid() ? _onContinue : () {
                          // show why disabled - quick check
                          if (_selectedComforts.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select at least one comfort zone first')));
                            return;
                          }
                          if (_emotionalNeedsController.text.trim().isEmpty || _expectationsController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill the emotional needs and expectations fields')));
                            return;
                          }
                          if (_dob == null) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please pick your date of birth')));
                            return;
                          }
                          if (_mobileController.text.trim().isNotEmpty && !_isValidMobile(_mobileController.text.trim())) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid mobile number (7-15 digits)')));
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please complete required fields')));
                        },
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), backgroundColor: const Color(0xFFaf57db)),
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

class _TileChoice {
  final String id;
  final String label;
  final IconData icon;
  const _TileChoice(this.id, this.label, this.icon);
}
