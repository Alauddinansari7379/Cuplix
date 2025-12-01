// file: lib/login/RelationshipGoalsScreen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../apiInterface/ApiInterface.dart';
import '../dashboard/Dashboard.dart';

// optional: your shared prefs helper from previous message
import '../utils/SharedPreferences.dart';


class RelationshipGoalsScreen extends StatefulWidget {
  // required basic info
  final String role;
  final String name;
  final String? email;

  // optional explicit fields (preferred when provided)
  final String? avatarUrl;
  final String? mobile;
  final String? dateOfBirth; // ISO yyyy-MM-dd (string)
  final int? age;
  final String? religion;
  final int? religiosityScore;
  final String? placeOfBirth;
  final String? journeyStartDate; // ISO yyyy-MM-dd

  // fallback map with previously collected answers (if you used that)
  final Map<String, dynamic>? previousAnswers;

  const RelationshipGoalsScreen({
    super.key,
    required this.role,
    required this.name,
    this.email,
    this.avatarUrl,
    this.mobile,
    this.dateOfBirth,
    this.age,
    this.religion,
    this.religiosityScore,
    this.placeOfBirth,
    this.journeyStartDate,
    this.previousAnswers,
  });

  @override
  State<RelationshipGoalsScreen> createState() =>
      _RelationshipGoalsScreenState();
}

class _RelationshipGoalsScreenState extends State<RelationshipGoalsScreen> {
  final _storage = const FlutterSecureStorage();

  final List<String> _goals = [
    'Fun & Adventure',
    'Peace & Stability',
    'Deep Intimacy',
    'Personal Growth',
    'Family Building',
    'Spiritual Connection',
  ];

  final Set<int> _selectedIndices = {};
  bool _loading = false;

  void _toggleGoal(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) _selectedIndices.remove(index);
      else _selectedIndices.add(index);
    });
  }

  /// Build final payload: prefer explicit constructor fields,
  /// fallback to previousAnswers map when explicit is null.
  Map<String, dynamic> _buildPayload() {
    final prev = widget.previousAnswers ?? <String, dynamic>{};

    String? mobile = widget.mobile ?? (prev['mobile'] as String?);
    String? dob = widget.dateOfBirth ?? (prev['dateOfBirth'] as String?);
    int? age = widget.age ??
        (prev['age'] is int ? prev['age'] as int : null) ??
        _computeAgeFromIso(dob);
    String? religion = widget.religion ?? (prev['religion'] as String?);
    int? religiosity = widget.religiosityScore ??
        (prev['religiosity'] is int
            ? prev['religiosity'] as int
            : (prev['religiosity'] is double
            ? (prev['religiosity'] as double).round()
            : null));
    String? placeOfBirth =
        widget.placeOfBirth ?? (prev['placeOfBirth'] as String?);
    String? journeyStart = widget.journeyStartDate ??
        (prev['togetherSince'] as String?) ??
        (prev['journeyStartDate'] as String?);
    String? avatarUrl = widget.avatarUrl ?? (prev['avatarUrl'] as String?);

    // ensure dates are ISO yyyy-MM-dd (if they parse-able)
    final formattedDob = _formatIso(dob);
    final formattedJourney = _formatIso(journeyStart);

    final payload = <String, dynamic>{
      "name": widget.name,
      "role": widget.role,
      "avatarUrl": avatarUrl,
      "mobile": (mobile == null || (mobile as String).isEmpty) ? null : mobile,
      "dateOfBirth": formattedDob,
      "age": age,
      "religion": religion,
      "religiosityScore": religiosity,
      "placeOfBirth": placeOfBirth,
      "journeyStartDate": formattedJourney,
      // additional collected answers
      "comfortZones": prev['comfortZones'],
      "emotionalNeeds": prev['emotionalNeeds'],
      "expectations": prev['expectations'],
      "communicationStyle": prev['communicationStyle'],
      "loveLanguage": prev['loveLanguage'],
      // "relationshipGoals": _selectedIndices.map((i) => _goals[i]).toList(),
      // "email": widget.email,
    };

    // remove nulls to keep payload clean
    payload.removeWhere((k, v) => v == null);
    return payload;
  }

  int? _computeAgeFromIso(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return null;
    try {
      final dt = DateTime.parse(isoDate);
      final now = DateTime.now();
      int age = now.year - dt.year;
      if (now.month < dt.month || (now.month == dt.month && now.day < dt.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return null;
    }
  }

  String? _formatIso(String? isoDate) {
    if (isoDate == null) return null;
    try {
      final dt = DateTime.parse(isoDate);
      return DateFormat('yyyy-MM-dd').format(dt);
    } catch (e) {
      // if input wasn't parseable, return null
      return null;
    }
  }

  /// Try to obtain auth token from SharedPreferences first (SharedPrefs),
  /// then fall back to FlutterSecureStorage keys.
  Future<String?> _getAuthToken() async {
    try {
      // try shared_prefs helper (if present)
      final spToken = await SharedPrefs.getAccessToken();
      if (spToken != null && spToken.isNotEmpty) return spToken;
    } catch (_) {
      // ignore - helper might not exist or fail
    }

    // check common keys in secure storage (several names to be safe)
    try {
      final keysToTry = ['user_token', 'auth_token', 'access_token', 'token'];
      for (final key in keysToTry) {
        final v = await _storage.read(key: key);
        if (v != null && v.isNotEmpty) return v;
      }
    } catch (_) {
      // ignore storage errors
    }

    return null;
  }

  Future<void> _onCompleteSetup() async {
    if (_selectedIndices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one relationship goal')),
      );
      return;
    }

    setState(() => _loading = true);

    final payload = _buildPayload();

    // Construct profiles endpoint. ApiInterface has baseUrl; append 'profiles'
    final String profilesUrl = '${ApiInterface.baseUrl}profiles';

    final token = await _getAuthToken();

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) headers['Authorization'] = 'Bearer $token';

    // debug print (ignore in release)
    // ignore: avoid_print
    print('Posting to $profilesUrl payload: $payload headers: $headers');

    try {
      final resp = await http.post(
        Uri.parse(profilesUrl),
        headers: headers,
        body: jsonEncode(payload),
      );

      setState(() => _loading = false);

      // attempt to decode body safely
      Map<String, dynamic>? decoded;
      try {
        decoded = resp.body.isNotEmpty ? jsonDecode(resp.body) as Map<String, dynamic> : null;
      } catch (_) {
        decoded = null;
      }

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        // optionally save returned profile or tokens here if server returns them
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile created/updated successfully')));
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Dashboard()));
        return;
      }

      // handle 401 unauthorized
      if (resp.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unauthorized — please sign in again.')),
        );
        // clear saved tokens from both storage places (best-effort)
        try {
          await SharedPrefs.clearAll();
        } catch (_) {}
        try {
          await _storage.deleteAll();
        } catch (_) {}
        return;
      }

      // other errors: show server message if any
      final serverMessage = decoded != null
          ? (decoded['message'] ?? decoded['error'] ?? decoded).toString()
          : 'Server returned ${resp.statusCode}';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $serverMessage')));
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Network error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    const gradient = LinearGradient(colors: [Color(0xFFaf57db), Color(0xFFe46791)]);
    final isWide = MediaQuery.of(context).size.width > 720;
    final tileWidth = isWide ? 220.0 : (MediaQuery.of(context).size.width - 96) / 2;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFF),
      appBar: AppBar(
        title: const Text('Relationship Goals'),
        backgroundColor: const Color(0xFFffffff),
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            width: isWide ? 720 : double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // header
                Center(
                  child: Column(
                    children: [
                      Container(
                        height: 64,
                        width: 64,
                        decoration: const BoxDecoration(shape: BoxShape.circle, gradient: gradient),
                        child: const Icon(Icons.track_changes, color: Colors.white, size: 34),
                      ),
                      const SizedBox(height: 12),
                      const Text('Relationship Goals', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('What matters most to you in your relationship?', style: TextStyle(color: Colors.grey[600]), textAlign: TextAlign.center),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text('What are your relationship goals? (Select all that apply)', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),

                // goals grid
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: List.generate(_goals.length, (i) {
                    final selected = _selectedIndices.contains(i);
                    return GestureDetector(
                      onTap: () => _toggleGoal(i),
                      child: Container(
                        width: tileWidth,
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                        decoration: BoxDecoration(
                          color: selected ? const Color(0xFFfaf5ff) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: selected ? const Color(0xFFb76bd6) : Colors.grey.shade300),
                        ),
                        child: Text(_goals[i], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFFF7F1F6), borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Personalized AI Guidance', style: TextStyle(fontWeight: FontWeight.w700)),
                      SizedBox(height: 8),
                      Text('Based on your age and responses, Cuplix will provide age-appropriate relationship guidance tailored to your life stage.'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
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
                        onPressed: _onCompleteSetup,
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), backgroundColor: const Color(0xFFaf57db), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: const Text('Complete Setup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
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
