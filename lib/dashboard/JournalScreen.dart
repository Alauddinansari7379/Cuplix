// lib/journal/journal_screen.dart
import 'dart:io';

import 'package:cuplix/apiInterface/ApiInterface.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../apiInterface/ApIHelper.dart';
import '../model/journal_entry.dart';
import '../utils/SharedPreferences.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  String _selectedMood = 'Neutral';
  final TextEditingController _noteController = TextEditingController();

  // picked image file + path (local)
  File? _pickedImageFile;
  String? _pickedImageUrl; // path string to send/display

  bool _loadingList = false;
  bool _saving = false;
  List<JournalEntry> _entries = [];

  // dynamic mood list and icons map
  final List<String> _moodList = ['Excited', 'Happy', 'Neutral', 'Anxious', 'Sad'];
  final Map<String, IconData> _moodIcons = {
    'Excited': Icons.emoji_emotions_outlined,
    'Happy': Icons.sentiment_satisfied_outlined,
    'Neutral': Icons.sentiment_neutral_outlined,
    'Anxious': Icons.sentiment_dissatisfied_outlined,
    'Sad': Icons.sentiment_dissatisfied,
  };

  // image picker
  final ImagePicker _picker = ImagePicker();

  // developer-provided demo image path (use when user didn't pick)
  static const String kDemoImagePath = '/mnt/data/a59e40d7-3ca9-4f3e-8b88-78314a315a5b.jpeg';

  @override
  void initState() {
    super.initState();
    _fetchList();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // --------- API: fetch list ----------
  Future<void> _fetchList() async {
    if (!mounted) return;
    setState(() => _loadingList = true);

    try {
      final token = await SharedPrefs.getAccessToken();
      if (token == null || token.isEmpty) {
        if (!mounted) return;
        setState(() => _loadingList = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not authenticated. Please sign in.')));
        return;
      }

      final result = await ApiHelper.getWithAuth(
        url: ApiInterface.getJournal,
        token: token,
        context: context,
        showLoader: true,
      );

      debugPrint('Journal _fetchList result: $result');

      if (result == null) {
        if (!mounted) return;
        setState(() => _loadingList = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No response from server.')));
        return;
      }

      if (result['success'] == true) {
        final data = result['data'];

        List items = [];
        if (data is List) {
          items = data;
        } else if (data is Map && data['data'] is List) {
          items = data['data'];
        } else if (data is Map && data['items'] is List) {
          items = data['items'];
        } else if (data is Map && data.containsKey('id')) {
          items = [data];
        } else {
          debugPrint('Journal _fetchList -> unexpected data format: ${data.runtimeType}');
          items = [];
        }

        final entries = items
            .where((e) => e != null)
            .map<JournalEntry>((e) => JournalEntry.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        if (!mounted) return;
        setState(() {
          _entries = entries;
          _loadingList = false;
        });
      } else {
        final err = result['error'] ?? 'Failed to load journal';
        if (!mounted) return;
        setState(() => _loadingList = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.toString())));
      }
    } catch (e, st) {
      debugPrint('Journal _fetchList exception: $e\n$st');
      if (!mounted) return;
      setState(() => _loadingList = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching journal: $e')));
    }
  }

  // --------- Mood helpers ----------
  void _pickMood(String mood) {
    setState(() => _selectedMood = mood);
  }

  Future<void> _showAddMoodDialog() async {
    final TextEditingController ctl = TextEditingController();
    final res = await showDialog<String?>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add a mood'),
          content: TextField(
            controller: ctl,
            decoration: const InputDecoration(hintText: 'e.g. Grateful'),
            autofocus: true,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(null), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.of(ctx).pop(ctl.text.trim()), child: const Text('Add')),
          ],
        );
      },
    );

    if (res != null && res.isNotEmpty) {
      if (!mounted) return;
      setState(() {
        if (!_moodList.contains(res)) {
          _moodList.insert(0, res);
          _moodIcons[res] = Icons.emoji_emotions_outlined;
        }
        _selectedMood = res;
      });
    }
  }

  // --------- Image picking ----------
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? picked = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1600, maxHeight: 1600, imageQuality: 85);
      if (picked == null) return;
      _pickedImageFile = File(picked.path);
      _pickedImageUrl = picked.path;
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image selected')));
    } catch (e) {
      debugPrint('Image pick error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? picked = await _picker.pickImage(source: ImageSource.camera, maxWidth: 1600, maxHeight: 1600, imageQuality: 85);
      if (picked == null) return;
      _pickedImageFile = File(picked.path);
      _pickedImageUrl = picked.path;
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Photo captured')));
    } catch (e) {
      debugPrint('Camera capture error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to capture image: $e')));
    }
  }

  void _addPhoto() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Use demo image (developer)'),
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _pickedImageFile = null;
                    _pickedImageUrl = kDemoImagePath;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Demo photo selected')));
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Cancel'),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  // --------- Add a journal entry ----------
  Future<void> _addToJournal() async {
    final note = _noteController.text.trim();
    if (note.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter some text')));
      return;
    }

    if (!mounted) return;
    setState(() => _saving = true);

    // Use picked image if available, otherwise demo
    final imageUrlToSend = _pickedImageUrl ?? kDemoImagePath;

    try {
      final token = await SharedPrefs.getAccessToken();
      if (token == null || token.isEmpty) {
        if (!mounted) return;
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not authenticated')));
        return;
      }

      // POST to backend: { content, mood, imageUrl }
      final res = await ApiHelper.postWithAuth(
        url: ApiInterface.journal,
        token: token,
        body: {
          'content': note,
          'mood': _selectedMood.toLowerCase(),
          'imageUrl': imageUrlToSend,
        },
        context: context,
        showLoader: true,
      );

      if (!mounted) return;

      if (res != null && res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to journal')));
        _noteController.clear();
        setState(() {
          _selectedMood = 'Neutral';
          _pickedImageFile = null;
          _pickedImageUrl = null;
        });
        await _fetchList(); // refresh list to show new entry
      } else {
        final err = res != null ? (res['error'] ?? 'Failed to save') : 'Failed to save';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.toString())));
      }
    } catch (e, st) {
      debugPrint('Journal _addToJournal error: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving journal: $e')));
    } finally {
      if (!mounted) return;
      setState(() => _saving = false);
    }
  }

  // --------- UI helpers ----------
  Widget _buildEntryCard(JournalEntry e) {
    final date = DateFormat.yMMMd().add_jm().format(e.createdAt.toLocal());
    final icon = _moodIcons[e.mood.capitalize()] ?? Icons.book;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEE6F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFF4EEFF),
                child: Icon(icon, color: const Color(0xFFB890F6)),
              ),
              const SizedBox(width: 10),
              Text(e.mood.capitalize(), style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(date, style: const TextStyle(fontSize: 12, color: Color(0xFF9A8EA0))),
            ],
          ),
          const SizedBox(height: 8),
          Text(e.content, style: const TextStyle(color: Color(0xFF2C2139))),
          if (e.imageUrl != null && e.imageUrl!.isNotEmpty) ...[
            const SizedBox(height: 8),
            e.imageUrl!.startsWith('http')
                ? Image.network(e.imageUrl!, height: 140, width: double.infinity, fit: BoxFit.cover)
                : _buildLocalImagePreview(e.imageUrl!),
          ],
        ],
      ),
    );
  }

  Widget _buildLocalImagePreview(String path) {
    // if the path corresponds to a file that exists (picked), show it; otherwise show placeholder text
    try {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(file, height: 140, width: double.infinity, fit: BoxFit.cover);
      } else {
        return Container(
          height: 140,
          width: double.infinity,
          color: Colors.grey[200],
          child: Center(child: Text('Local image: $path', style: const TextStyle(color: Colors.black54))),
        );
      }
    } catch (_) {
      return Container(
        height: 140,
        width: double.infinity,
        color: Colors.grey[200],
        child: Center(child: Text('Local image: $path', style: const TextStyle(color: Colors.black54))),
      );
    }
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
        child: RefreshIndicator(
          onRefresh: _fetchList,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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

                      // Mood chips row (dynamic + add)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ..._moodList.map((m) {
                              final selected = _selectedMood == m;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  label: Row(
                                    children: [
                                      Icon(_moodIcons[m] ?? Icons.mood, size: 18, color: selected ? Colors.white : Colors.black54),
                                      const SizedBox(width: 8),
                                      Text(m, style: TextStyle(color: selected ? Colors.white : Colors.black87)),
                                    ],
                                  ),
                                  selected: selected,
                                  onSelected: (_) => _pickMood(m),
                                  selectedColor: const Color(0xFFaf57db),
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                              );
                            }).toList(),
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ActionChip(
                                avatar: const Icon(Icons.add, size: 18),
                                label: const Text('Add'),
                                onPressed: _showAddMoodDialog,
                              ),
                            )
                          ],
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

                      // selected image preview row + buttons
                      if (_pickedImageFile != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_pickedImageFile!, height: 140, width: double.infinity, fit: BoxFit.cover),
                        )
                      else if (_pickedImageUrl != null)
                        _buildLocalImagePreview(_pickedImageUrl!)
                      else
                        const SizedBox.shrink(),

                      const SizedBox(height: 12),

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
                          // Add to Journal button
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
                              onPressed: _saving ? null : _addToJournal,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 18),
                              ),
                              child: _saving
                                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Text(
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

                const Text('Recent Memories', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF2C2139))),
                const SizedBox(height: 12),

                if (_loadingList)
                  const Center(child: CircularProgressIndicator())
                else if (_entries.isEmpty)
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
                          style: TextStyle(color: Color(0xFF9A8EA0), fontSize: 15, height: 1.4),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    children: _entries.map((e) => _buildEntryCard(e)).toList(),
                  ),

                const SizedBox(height: 40),
              ],
            ),
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

/// String extension for capitalizing
extension _CapExt on String {
  String capitalize() => isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';
}
