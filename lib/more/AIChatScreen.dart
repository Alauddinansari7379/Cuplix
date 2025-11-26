import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

// TODO: put your real Gemini key here (keep it secret, don't commit to git)
const String _geminiApiKey = 'AIzaSyC0I-lxRd56zaunsVqfb2hNoq9dzyvyWms';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  bool emotionAnalysisOn = true;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_Message> _messages = [];
  bool _sending = false;

  // ---------- voice / “speech-to-text” state (UI only now) ----------
  bool _isListening = false;
  String _lastError = '';

  @override
  void initState() {
    super.initState();

    final greeting =
        "Hi! I'm here to help you strengthen your relationship. How are you feeling today?";

    _messages.add(
      _Message(
        role: 'assistant',
        content: greeting,
        time: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ---------- mic handler (no plugin, just UI) ----------
  Future<void> _onMicPressed() async {
    // fake toggle so the “Listening…” chip can still show
    setState(() => _isListening = !_isListening);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Speech recognition is disabled in this build (no plugin).',
        ),
      ),
    );
  }

  // ---------- file picker handler ----------

  Future<void> _onAttachFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result == null || result.files.isEmpty) return;

      final picked = result.files.first;
      final fileName = picked.name;
      final currentText = _controller.text.trim();

      // Combine typed text (if any) with file info and send as one message
      final textToSend = currentText.isEmpty
          ? 'Shared a file: $fileName'
          : '$currentText\n\n[File attached: $fileName]';

      await _sendUserMessage(textToSend);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not pick file: $e'),
        ),
      );
    }
  }

  // ---------- chat / Gemini logic ----------

  Future<void> _sendUserMessage(String? overrideText) async {
    final text = (overrideText ?? _controller.text).trim();
    if (text.isEmpty || _sending) return;

    _controller.clear();

    final userMsg = _Message(
      role: 'user',
      content: text,
      time: DateTime.now(),
    );

    setState(() {
      _sending = true;
      _messages.add(userMsg);
    });
    _scrollToBottom();

    try {
      final reply = await _callGemini();

      final aiMsg = _Message(
        role: 'assistant',
        content: reply,
        time: DateTime.now(),
      );

      if (!mounted) return;
      setState(() {
        _messages.add(aiMsg);
      });
      _scrollToBottom();
    } catch (e) {
      final err = e.toString();
      String friendly;

      if (err.contains('RESOURCE_EXHAUSTED') ||
          err.contains('rateLimitExceeded')) {
        friendly =
        'Gemini API rate limit or quota reached. Please wait a bit and try again.';
      } else if (err.contains('PERMISSION_DENIED') ||
          err.contains('API key not valid')) {
        friendly =
        'Your Gemini API key seems invalid or not authorized. Please check it in Google AI Studio.';
      } else {
        friendly =
        'Sorry, something went wrong while talking to the AI. Please try again.';
      }

      if (!mounted) return;
      setState(() {
        _messages.add(
          _Message(
            role: 'assistant',
            content: friendly,
            time: DateTime.now(),
          ),
        );
      });
      _scrollToBottom();
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  Future<String> _callGemini() async {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent',
    );

    final systemContent = emotionAnalysisOn
        ? 'You are a warm, empathetic relationship coach. '
        'Give short, supportive answers (3–6 sentences) and include emotional insight.'
        : 'You are a concise relationship coach. Give short, practical answers (2–4 sentences).';

    final contents = <Map<String, dynamic>>[];

    final systemInstruction = {
      'role': 'user',
      'parts': [
        {'text': systemContent},
      ],
    };

    for (final m in _messages) {
      final role = m.role == 'user' ? 'user' : 'model';
      contents.add({
        'role': role,
        'parts': [
          {'text': m.content},
        ],
      });
    }

    final body = jsonEncode({
      'systemInstruction': systemInstruction,
      'contents': contents,
      'generationConfig': {
        'temperature': 0.7,
      },
    });

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': _geminiApiKey,
      },
      body: body,
    );

    if (response.statusCode != 200) {
      try {
        final errJson = jsonDecode(response.body);
        throw Exception(
            'Gemini error ${response.statusCode}: ${errJson.toString()}');
      } catch (_) {
        throw Exception(
            'Gemini error ${response.statusCode}: ${response.body}');
      }
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = decoded['candidates'] as List<dynamic>?;

    if (candidates == null || candidates.isEmpty) {
      throw Exception('No candidates returned from Gemini');
    }

    final content = candidates.first['content'];
    final parts = content?['parts'] as List<dynamic>?;

    if (parts == null || parts.isEmpty) {
      throw Exception('No parts in Gemini response');
    }

    final text =
    parts.map((p) => p['text']?.toString() ?? '').join('\n').trim();

    if (text.isEmpty) {
      throw Exception('Empty text from Gemini');
    }

    return text;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 60,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _onSuggestionTap(String text) {
    _sendUserMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    final bool keyboardVisible =
        MediaQuery.of(context).viewInsets.bottom > 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F0FF),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // ---------- Top gradient header ----------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF8C62FF), Color(0xFFFF5FD3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(22),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HeaderSection(),
                  const SizedBox(height: 14),
                  const DescriptionBox(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.psychology_alt_outlined,
                              size: 18,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Emotion Analysis',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  emotionAnalysisOn
                                      ? 'On • More empathetic'
                                      : 'Off • Straight advice',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 10),
                            Switch(
                              value: emotionAnalysisOn,
                              onChanged: (v) =>
                                  setState(() => emotionAnalysisOn = v),
                              activeColor: Colors.white,
                              activeTrackColor:
                              Colors.white.withOpacity(0.4),
                              inactiveThumbColor: Colors.white,
                              inactiveTrackColor:
                              Colors.white.withOpacity(0.2),
                              materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (_isListening)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.mic,
                                size: 16,
                                color: Colors.white,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Listening...',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  if (_lastError.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Speech error: $_lastError',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFFFE4E9),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ---------- Chat list in card ----------
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Container(
                  margin: const EdgeInsets.only(top: 6, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: ChatBubble(message: msg),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // ---------- Bottom input + quick suggestions ----------
            SafeArea(
              top: false,
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InputArea(
                      controller: _controller,
                      onSend: () => _sendUserMessage(null),
                      sending: _sending,
                      isListening: _isListening,
                      onMicPressed: _onMicPressed,
                      onAttachFile: _onAttachFile,
                    ),
                    const SizedBox(height: 10),
                    if (!keyboardVisible)
                      QuickSuggestions(onTapSuggestion: _onSuggestionTap),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= UI widgets (unchanged) =================

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.6), width: 1),
          ),
          child: const CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white,
            child: Icon(Icons.auto_awesome, color: Color(0xFF8C62FF), size: 24),
          ),
        ),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Companion',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.circle, color: Colors.greenAccent, size: 8),
                SizedBox(width: 6),
                Text(
                  'Here for you • Anytime',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.16),
            borderRadius: BorderRadius.circular(30),
          ),
          child: IconButton(
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
            onPressed: () {},
            icon: const Icon(Icons.more_horiz, size: 20, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class DescriptionBox extends StatelessWidget {
  const DescriptionBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      "Your private space to talk, vent, or plan together. I’ll keep things kind and practical.",
      style: TextStyle(
        fontSize: 13,
        color: Colors.white.withOpacity(0.92),
        height: 1.3,
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final _Message message;

  const ChatBubble({super.key, required this.message});

  bool get isUser => message.role == 'user';

  @override
  Widget build(BuildContext context) {
    final timeText = _formatTime(message.time);

    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF5FD3), Color(0xFFB86BFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18).copyWith(
                    bottomRight: const Radius.circular(4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.content,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeText,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            CircleAvatar(
              radius: 11,
              backgroundColor: const Color(0xFFE8E1FF),
              child: const Text(
                'N',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A3C7A),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Align(
        alignment: Alignment.centerLeft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CircleAvatar(
              radius: 11,
              backgroundColor: const Color(0xFFEDE9FF),
              child: const Icon(
                Icons.auto_awesome,
                size: 14,
                color: Color(0xFF7C4DFF),
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F1F8),
                  borderRadius: BorderRadius.circular(18).copyWith(
                    bottomLeft: const Radius.circular(4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.content,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeText,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  String _formatTime(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    final ampm = t.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }
}

class InputArea extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool sending;
  final bool isListening;
  final VoidCallback onMicPressed;
  final VoidCallback onAttachFile;

  const InputArea({
    super.key,
    required this.controller,
    required this.onSend,
    required this.sending,
    required this.isListening,
    required this.onMicPressed,
    required this.onAttachFile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onAttachFile,
            icon: const Icon(
              Icons.attach_file,
              size: 22,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: const InputDecoration(
                hintText: 'Say or type what’s on your mind…',
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                border: InputBorder.none,
                isDense: true,
              ),
              minLines: 1,
              maxLines: 4,
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: onMicPressed,
            icon: Icon(
              isListening ? Icons.mic : Icons.mic_none,
              size: 22,
              color: isListening ? Colors.redAccent : Colors.grey[800],
            ),
          ),
          const SizedBox(width: 2),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8C62FF), Color(0xFFFF5FD3)],
              ),
              borderRadius: BorderRadius.circular(999),
            ),
            child: IconButton(
              onPressed: sending ? null : onSend,
              icon: sending
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Icon(Icons.send, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class QuickSuggestions extends StatelessWidget {
  final void Function(String) onTapSuggestion;

  const QuickSuggestions({super.key, required this.onTapSuggestion});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.only(left: 4, right: 4, top: 4, bottom: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Try asking about…',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Color(0xFF4A3C7A),
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              SuggestionChip('I need help with communication', onTapSuggestion),
              SuggestionChip('Feeling disconnected lately', onTapSuggestion),
              SuggestionChip('Want to plan a date night', onTapSuggestion),
              SuggestionChip(
                'Need advice on conflict resolution',
                onTapSuggestion,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SuggestionChip extends StatelessWidget {
  final String label;
  final void Function(String) onTap;

  const SuggestionChip(this.label, this.onTap, {super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => onTap(label),
      child: Chip(
        backgroundColor: const Color(0xFFF2EEF8),
        label: Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF4A3C7A)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
    );
  }
}

class _Message {
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime time;

  _Message({
    required this.role,
    required this.content,
    required this.time,
  });
}
