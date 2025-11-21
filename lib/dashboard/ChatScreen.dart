// lib/chat/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:cuplix/apiInterface/ApiInterface.dart';
import 'package:cuplix/utils/SharedPreferences.dart';

import '../apiInterface/ApIHelper.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // ---- partner connection state ----
  bool _loadingConnection = false;
  bool _isConnected = false;

  String _partnerName = 'Partner';
  String? _partnerAvatarUrl;

  String get _partnerInitial =>
      _partnerName.isNotEmpty ? _partnerName[0].toUpperCase() : 'P';

  // ---- chat state ----
  final TextEditingController _textController = TextEditingController();
  final List<_ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _fetchPartnerConnection();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _fetchPartnerConnection() async {
    setState(() => _loadingConnection = true);

    try {
      final String? token = await SharedPrefs.getAccessToken();

      if (token == null) {
        setState(() {
          _loadingConnection = false;
          _isConnected = false;
        });
        return;
      }

      final res = await ApiHelper.getWithAuth(
        url: ApiInterface.partnerConnectionsMe,
        token: token,
        context: context,
        showLoader: false,
      );

      if (!mounted) return;

      if (res['success'] != true) {
        setState(() {
          _loadingConnection = false;
          _isConnected = false;
        });
        return;
      }

      final data = res['data'];

      // If API returns `null` => not connected
      if (data == null) {
        setState(() {
          _loadingConnection = false;
          _isConnected = false;
        });
        return;
      }

      // 🔹 Backend guarantees that for `/me`
      //     the OTHER person is always in `user1`.
      //    (As per your screenshot)
      Map<String, dynamic>? partnerProfile =
      (data['user1'] ?? const {})['profile'];

      // Fallback to user2.profile if needed
      partnerProfile ??= (data['user2'] ?? const {})['profile'];

      final String name =
      (partnerProfile?['name']?.toString().trim().isNotEmpty ?? false)
          ? partnerProfile!['name'].toString()
          : 'Partner';

      final String? avatarUrl =
      (partnerProfile?['avatarUrl']?.toString().trim().isNotEmpty ?? false)
          ? partnerProfile!['avatarUrl'].toString()
          : null;

      setState(() {
        _loadingConnection = false;
        _isConnected = true;
        _partnerName = name;
        _partnerAvatarUrl = avatarUrl;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingConnection = false;
        _isConnected = false;
      });
    }
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        _ChatMessage(
          text: text,
          isMe: true,
          time: DateTime.now(),
        ),
      );
      _textController.clear();
    });

    // TODO: send to backend / socket here when you implement real chat
  }

  @override
  Widget build(BuildContext context) {
    // theme colors used in your designs
    const primaryText = Color(0xFF2C2139);
    const mutedText = Color(0xFF9A8EA0);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: primaryText),
              onPressed: () => Navigator.pop(context),
            ),
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey.shade200,
              backgroundImage:
              _partnerAvatarUrl != null ? NetworkImage(_partnerAvatarUrl!) : null,
              child: _partnerAvatarUrl == null
                  ? Text(
                _partnerInitial,
                style: const TextStyle(
                  color: primaryText,
                  fontWeight: FontWeight.bold,
                ),
              )
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _partnerName,
                    style: const TextStyle(
                      color: primaryText,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _isConnected ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isConnected ? 'Online' : 'Offline',
                        style: const TextStyle(
                          color: mutedText,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: primaryText),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ---------------- Messages area ----------------
            Expanded(
              child: _loadingConnection && _messages.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _messages.isEmpty
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'No messages yet. Send a message to start the conversation!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: mutedText,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _MessageBubble(message: msg);
                },
              ),
            ),

            // ---------------- Input & (optional) info bar ----------------
            _buildBottomArea(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomArea(BuildContext context) {
    const mutedText = Color(0xFF9A8EA0);
    const cardBorder = Color(0xFFEDE8EF);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Input row
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          padding: EdgeInsets.only(
            left: 12,
            right: 12,
            top: 8,
            bottom: 8 + 4, // small extra spacing
          ),
          child: Row(
            children: [
              // ---- rounded input field ----
              Expanded(
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color(0xFFE0C9F0),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          // TODO: emoji picker
                        },
                        icon: const Icon(
                          Icons.emoji_emotions_outlined,
                          size: 22,
                          color: mutedText,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          onChanged: (_) {
                            setState(() {}); // refresh mic/send icon
                          },
                          minLines: 1,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(color: mutedText),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // TODO: attachment
                        },
                        icon: const Icon(
                          Icons.attach_file,
                          size: 20,
                          color: mutedText,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // TODO: open camera
                        },
                        icon: const Icon(
                          Icons.camera_alt_outlined,
                          size: 20,
                          color: mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // ---- Mic / Send button with gradient ----
              GestureDetector(
                onTap: () {
                  if (_textController.text.trim().isNotEmpty) {
                    _sendMessage(); // send
                  } else {
                    // TODO: mic action (voice note)
                  }
                },
                child: Container(
                  height: 46,
                  width: 46,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFB57BFF),
                        Color(0xFFE45EFF),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(
                    _textController.text.trim().isEmpty
                        ? Icons.mic
                        : Icons.send,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ---- "not connected" info bar (only when disconnected) ----
        if (!_isConnected)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: cardBorder)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 14,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'You are no longer connected with this partner.',
                    style: TextStyle(color: mutedText, fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 220,
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: open Manage Connections screen
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                      ),
                      child: const Text(
                        'Manage Connections',
                        style: TextStyle(
                          color: Color(0xFF2C2139),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ----------------- simple in-memory message model & bubble -----------------

class _ChatMessage {
  final String text;
  final bool isMe;
  final DateTime time;

  _ChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
  });
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;

  const _MessageBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    final bgColor = isMe ? const Color(0xFFE4C8FF) : Colors.white;
    final textColor = const Color(0xFF2C2139);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.text,
          style: TextStyle(color: textColor, fontSize: 15),
        ),
      ),
    );
  }
}
