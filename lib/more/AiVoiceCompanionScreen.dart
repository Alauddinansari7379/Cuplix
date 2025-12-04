import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'package:cuplix/utils/SharedPreferences.dart';

// Cuplix AI backend base URL
const String _aiBaseUrl = 'https://ai.cuplix.in';

/// Simple chat message model
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
  });
}

class AiVoiceCompanionScreen extends StatefulWidget {
  const AiVoiceCompanionScreen({super.key});

  @override
  State<AiVoiceCompanionScreen> createState() =>
      _AiVoiceCompanionScreenState();
}

class _AiVoiceCompanionScreenState extends State<AiVoiceCompanionScreen> {
  // -------- recording & state (record 5.x) --------
  final AudioRecorder _recorder = AudioRecorder();

  bool _speechAvailable = false;
  bool _isListening = false;
  String _micHint = 'Press to Talk';

  String _currentTranscript = '';

  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  /// session for continuing same chat (voice 1st + 2nd API)
  String? _sessionId;

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    final hasPermission = await _recorder.hasPermission();
    setState(() {
      _speechAvailable = hasPermission;
    });
  }

  // ---------- MIC / RECORDING ----------

  Future<void> _startListening() async {
    final hasPermission = await _recorder.hasPermission();
    setState(() {
      _speechAvailable = hasPermission;
    });

    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Microphone permission denied'),
        ),
      );
      return;
    }

    // build a temp file path
    final dir = await getTemporaryDirectory();
    final filePath =
        '${dir.path}/cuplix_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

    setState(() {
      _isListening = true;
      _micHint = 'Listening...';
    });

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: filePath, // REQUIRED in record 5.x
    );
  }

  Future<void> _stopListening() async {
    final path = await _recorder.stop();

    setState(() {
      _isListening = false;
      _micHint = 'Press to Talk';
    });

    if (path == null) return;

    final file = File(path);
    if (!file.existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recording failed, please try again.'),
        ),
      );
      return;
    }

    // send to AI as audio_file (voice API)
    await _sendVoiceToAi(file);
  }

  void _toggleListening() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  // ---------- CHAT HELPERS ----------

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: true, time: DateTime.now()),
      );
    });
    _scrollToBottom();
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: false, time: DateTime.now()),
      );
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _newConversation() {
    setState(() {
      _messages.clear();
      _currentTranscript = '';
      _sessionId = null;
    });
  }

  // ---------- VOICE API INTEGRATION ----------

  /// Voice API:
  /// 1st call: audio_file only  -> returns session_id
  /// Next:    audio_file + session_id -> continues chat
  Future<void> _sendVoiceToAi(File audioFile) async {
    try {
      final token = await SharedPrefs.getAccessToken();
      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to continue')),
        );
        return;
      }

      final uri = Uri.parse('$_aiBaseUrl/ai/text-chat/send');
      final request = http.MultipartRequest('POST', uri);

      // file
      request.files.add(
        await http.MultipartFile.fromPath('audio_file', audioFile.path),
      );

      // session id if any
      if (_sessionId != null && _sessionId!.isNotEmpty) {
        request.fields['session_id'] = _sessionId!;
      }

      request.headers['Authorization'] = 'Bearer $token';

      final streamedResponse = await request.send();
      final bodyString =
      await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode != 200) {
        debugPrint(
            'Voice API error ${streamedResponse.statusCode}: $bodyString');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Voice request failed (${streamedResponse.statusCode})',
            ),
          ),
        );
        return;
      }

      final Map<String, dynamic> data =
      jsonDecode(bodyString) as Map<String, dynamic>;

      final String aiResponse =
          (data['response'] as String?) ?? '';
      final String transcription =
          (data['transcription'] as String?) ?? '';
      final String? newSessionId =
      data['session_id'] as String?;

      if (newSessionId != null && newSessionId.isNotEmpty) {
        _sessionId = newSessionId;
      }

      if (transcription.isNotEmpty) {
        _addUserMessage(transcription);
      } else {
        _addUserMessage('[Voice message]');
      }

      if (aiResponse.isNotEmpty) {
        _addBotMessage(aiResponse);
      }
    } catch (e) {
      debugPrint('Voice API exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error while sending voice to AI'),
        ),
      );
    }
  }

  /// Optional dummy text API – logic unchanged, in case you add typing later.
  Future<void> _sendToAi(String userText) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final aiReply =
        'Thanks for sharing. You said: "$userText". How does that make you feel?';
    _addBotMessage(aiReply);
  }

  @override
  void dispose() {
    _recorder.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ---------- UI (unchanged) ----------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Text(
                        'AI Voice Companion',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Talk to your AI relationship companion anytime. A private, '
                            'judgment-free space to explore your feelings.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Main card (avatar + status + mic)
                      _buildMainCard(theme),

                      const SizedBox(height: 16),

                      // Conversation History title
                      Row(
                        children: [
                          Text(
                            'Conversation History',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_messages.length} messages',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Chat list (fixed height instead of Expanded)
                      SizedBox(
                        height: constraints.maxHeight * 0.45, // adjust if needed
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 6,
                          ),
                          child: _messages.isEmpty
                              ? Center(
                            child: Text(
                              _currentTranscript.isEmpty
                                  ? 'Start talking to see your conversation here.'
                                  : _currentTranscript,
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                              : ListView.builder(
                            controller: _scrollController,
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final msg = _messages[index];
                              return MessageBubble(message: msg);
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Tips card
                      _buildTipsCard(theme),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainCard(ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar + status
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(60),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF7B3FE0),
                          Color(0xFFF94C8F),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: _speechAvailable ? Colors.green : Colors.grey,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cuplix AI Companion',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _speechAvailable ? 'Connected' : 'Checking microphone…',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your private, judgment-free space to talk about anything',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // New conversation
            OutlinedButton.icon(
              onPressed: _newConversation,
              icon: const Icon(Icons.refresh),
              label: const Text('New Conversation'),
            ),

            const SizedBox(height: 18),

            // Mic button
            Column(
              children: [
                GestureDetector(
                  onTap: _toggleListening,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: _isListening ? 100 : 90,
                    height: _isListening ? 100 : 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF7B3FE0),
                          Color(0xFFF94C8F),
                        ],
                      ),
                      boxShadow: [
                        if (_isListening)
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.4),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(_micHint),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsCard(ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F2FF),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tips for a Better Experience',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '• Speak naturally as if you\'re talking to a trusted friend\n'
                '• Be specific about your feelings and situations for more relevant guidance\n'
                '• You can either speak using the microphone or type your messages',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}

/// Chat bubble UI
class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final bgColor =
    isUser ? const Color(0xFF7B3FE0) : const Color(0xFFF2F2F7);
    final textColor = isUser ? Colors.white : Colors.black87;
    final align =
    isUser ? Alignment.centerRight : Alignment.centerLeft;

    return Align(
      alignment: align,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.text,
          style: TextStyle(color: textColor, fontSize: 14),
        ),
      ),
    );
  }
}
