// lib/chat/chat_screen.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../apiInterface/ApIHelper.dart';
import '../apiInterface/ApiInterface.dart';
import '../utils/SharedPreferences.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatMessage {
  String id;
  final String? clientMessageId;
  final String text;
  final bool isMe;
  final String messageType;
  final String? mediaUrl;
  String status; // sent / delivered / read
  final DateTime time;

  _ChatMessage({
    required this.id,
    required this.clientMessageId,
    required this.text,
    required this.isMe,
    required this.messageType,
    required this.mediaUrl,
    required this.status,
    required this.time,
  });
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<_ChatMessage> _messages = [];

  // NEW: controller so we can scroll to bottom
  final ScrollController _scrollController = ScrollController();

  bool _loadingConnection = false;
  bool _isConnected = false;
  bool _partnerTyping = false;
  bool _partnerOnline = false;

  String? _partnerId;
  String? _currentUserId;
  String _partnerName = "Partner";
  String? _partnerAvatarUrl;

  IO.Socket? _socket;
  Timer? typingTimer;

  @override
  void initState() {
    super.initState();
    _fetchPartnerConnection();
  }

  @override
  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Helper: always scroll list to bottom (last message)
  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  // ---------------------------------------------------
  // 1️⃣ LOAD PARTNER CONNECTION
  // ---------------------------------------------------
  Future<void> _fetchPartnerConnection() async {
    setState(() => _loadingConnection = true);

    final token = await SharedPrefs.getAccessToken();
    if (token == null) return;

    final res = await ApiHelper.getWithAuth(
      url: ApiInterface.partnerConnectionsMe,
      token: token,
      context: context,
      showLoader: false,
    );

    if (!mounted) return;
    setState(() => _loadingConnection = false);

    if (res["success"] != true || res["data"] == null) return;

    final data = res["data"];

    // Backend: user1 = partner, user2 = me
    final partnerProfile = data["user1"]["profile"];

    _partnerId = data["user1Id"]?.toString();
    _currentUserId = data["user2Id"]?.toString();
    _partnerName = partnerProfile["name"] ?? "Partner";
    _partnerAvatarUrl = partnerProfile["avatar"];

    setState(() => _isConnected = true);

    _connectSocket(token);
    _loadMessageHistory(token);
  }

  // ---------------------------------------------------
  // 2️⃣ SOCKET CONNECTION
  // ---------------------------------------------------
  void _connectSocket(String token) {
    const socketUrl = "https://api.cuplix.in/partner-chat";

    _socket = IO.io(
      socketUrl,
      {
        'transports': ['websocket', 'polling'],
        'auth': {'token': token},
        'extraHeaders': {'Authorization': 'Bearer $token'},
        'reconnection': true,
      },
    );

    _socket!.on('connect', (_) {
      debugPrint("🔌 Socket Connected");
      if (_partnerId != null) {
        _socket!.emit("join-room", {"partnerId": _partnerId});
      }
    });

    _socket!.on("joined-room", (data) {
      setState(() => _partnerOnline = data["isPartnerOnline"] ?? false);
    });

    _socket!.on("partner-online", (_) {
      setState(() => _partnerOnline = true);
    });

    _socket!.on("partner-offline", (_) {
      setState(() => _partnerOnline = false);
    });

    _socket!.on("partner-typing", (data) {
      setState(() => _partnerTyping = data["isTyping"]);
    });

    _socket!.on("receive-message", _handleIncomingMessage);

    _socket!.on("message-delivered", (data) {
      final index = _messages.indexWhere(
            (m) => m.clientMessageId == data["clientMessageId"],
      );
      if (index != -1) {
        setState(() {
          _messages[index].id = data["messageId"];
          _messages[index].status = "delivered";
        });
        _scrollToBottom();
      }
    });

    _socket!.on("messages-read", (data) {
      final ids = List<String>.from(data["messageIds"]);
      setState(() {
        for (var m in _messages) {
          if (ids.contains(m.id)) {
            m.status = "read";
          }
        }
      });
    });
  }

  // ---------------------------------------------------
  // 3️⃣ FETCH MESSAGE HISTORY
  // ---------------------------------------------------

  Future<void> _loadMessageHistory(String token) async {
    if (_partnerId == null) return;

    final url =
        "https://api.cuplix.in/api/partner-messages/history?partnerId=$_partnerId";

    final res = await ApiHelper.getWithAuth(
      url: url,
      token: token,
      context: context,
    );

    if (res["success"] != true || res["data"] == null) return;

    // Safely read list of raw messages
    final data = res["data"] as Map<String, dynamic>;
    final rawList = (data["messages"] as List?) ?? [];

    // Build a *local* list first
    final List<_ChatMessage> loaded = [];
    for (final raw in rawList) {
      final m = raw as Map<String, dynamic>;
      final senderId = m["senderId"]?.toString();

      loaded.add(
        _ChatMessage(
          id: (m["id"] ?? m["_id"]).toString(),
          clientMessageId: m["clientMessageId"],
          text: m["content"] ?? "",
          isMe: senderId != _partnerId,
          messageType: m["messageType"] ?? "text",
          mediaUrl: m["mediaUrl"],
          status: m["status"] ?? "sent",
          time: DateTime.tryParse(m["createdAt"] ?? "") ?? DateTime.now(),
        ),
      );
    }

    // Now update state in one go
    setState(() {
      _messages
        ..clear()
        ..addAll(loaded);
    });

    _scrollToBottom(); // make sure last message is visible
  }


  // ---------------------------------------------------
  // 4️⃣ HANDLE INCOMING MESSAGE (DEDUP + STATUS UPDATE)
  // ---------------------------------------------------
  void _handleIncomingMessage(dynamic raw) {
    final data = Map<String, dynamic>.from(raw as Map);

    final senderId = data["senderId"]?.toString();
    final clientMessageId = data["clientMessageId"]?.toString();
    final messageId = (data["id"] ?? data["_id"]).toString();

    // 1. If already have this message -> update, don't add
    final existingIndex = _messages.indexWhere(
          (m) =>
      m.id == messageId ||
          (clientMessageId != null && m.clientMessageId == clientMessageId),
    );

    if (existingIndex != -1) {
      setState(() {
        _messages[existingIndex].id = messageId;
        _messages[existingIndex].status =
            data["status"]?.toString() ?? _messages[existingIndex].status;
      });
      _scrollToBottom();
      return;
    }

    // 2. New message
    final isMe = senderId != null && senderId != _partnerId;

    final msg = _ChatMessage(
      id: messageId,
      clientMessageId: clientMessageId,
      text: data["content"] ?? "",
      isMe: isMe,
      messageType: data["messageType"],
      mediaUrl: data["mediaUrl"],
      status: data["status"] ?? "sent",
      time: DateTime.parse(data["createdAt"]),
    );

    setState(() => _messages.add(msg));
    _scrollToBottom();

    if (!isMe) {
      _markMessageAsRead([msg.id]);
    }
  }

  // ---------------------------------------------------
  // 5️⃣ SEND MESSAGE
  // ---------------------------------------------------
  void _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    if (_partnerId == null || _socket == null) return;

    final clientMessageId =
        "client-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(999999)}";

    final optimistic = _ChatMessage(
      id: clientMessageId,
      clientMessageId: clientMessageId,
      text: text,
      isMe: true,
      messageType: "text",
      mediaUrl: null,
      status: "sent",
      time: DateTime.now(),
    );

    setState(() {
      _messages.add(optimistic);
      _textController.clear();
    });
    _scrollToBottom();

    _socket!.emit("send-message", {
      "receiverId": _partnerId,
      "content": text,
      "messageType": "text",
      "clientMessageId": clientMessageId,
    });
  }

  // ---------------------------------------------------
  // 6️⃣ MARK AS READ
  // ---------------------------------------------------
  Future<void> _markMessageAsRead(List<String> ids) async {
    final token = await SharedPrefs.getAccessToken();
    if (token == null) return;

    await ApiHelper.postWithAuth(
      url: "https://api.cuplix.in/api/partner-messages/read",
      token: token,
      body: {"messageIds": ids},
    );
  }

  // ---------------------------------------------------
  // UI BELOW THIS POINT
  // ---------------------------------------------------
  @override
  Widget build(BuildContext context) {
    const primaryText = Color(0xFF2C2139);
    const mutedText = Color(0xFF9A8EA0);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
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
              backgroundImage: _partnerAvatarUrl != null
                  ? NetworkImage(_partnerAvatarUrl!)
                  : null,
              child: _partnerAvatarUrl == null
                  ? Text(
                _partnerName.isNotEmpty
                    ? _partnerName[0].toUpperCase()
                    : 'P',
                style: const TextStyle(
                  color: primaryText,
                  fontWeight: FontWeight.bold,
                ),
              )
                  : null,
            ),
            const SizedBox(width: 8),
            Column(
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
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color:
                        _partnerOnline ? Colors.green : Colors.grey.shade400,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _partnerOnline ? "Online" : "Offline",
                      style: const TextStyle(
                        color: mutedText,
                        fontSize: 12,
                      ),
                    )
                  ],
                )
              ],
            )
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,           // ⬅️ controller added
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _MessageBubble(message: _messages[i]),
            ),
          ),

          if (_partnerTyping)
            const Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Text(
                "Typing...",
                style: TextStyle(color: Colors.grey),
              ),
            ),

          _buildInputBar(),
        ],
      ),
    );
  }

  // INPUT BAR ---------------------------------------------------
  Widget _buildInputBar() {
    final text = _textController.text.trim();

    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              maxLines: 4,
              minLines: 1,
              onChanged: (v) {
                if (v.isNotEmpty) {
                  _socket?.emit(
                    "typing",
                    {"partnerId": _partnerId, "isTyping": true},
                  );
                }
                typingTimer?.cancel();
                typingTimer = Timer(const Duration(seconds: 2), () {
                  _socket?.emit(
                    "typing",
                    {"partnerId": _partnerId, "isTyping": false},
                  );
                });
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: "Type a message...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: text.isEmpty ? null : _sendMessage,
            child: const CircleAvatar(
              radius: 25,
              backgroundColor: Colors.purple,
              child: Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          )
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// MESSAGE BUBBLE WIDGET  (time + ticks)
// ---------------------------------------------------------------------------

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  const _MessageBubble({required this.message});

  String _formatTime(DateTime t) {
    final now = DateTime.now();
    final diff = now.difference(t);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';

    final d = t.day.toString().padLeft(2, '0');
    final m = t.month.toString().padLeft(2, '0');
    return '$d/$m';
  }

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    final bgColor = isMe ? const Color(0xFFE4C8FF) : Colors.white;
    const textColor = Color(0xFF2C2139);

    IconData? tickIcon;
    Color tickColor = Colors.grey;

    if (isMe) {
      switch (message.status) {
        case 'sent':
          tickIcon = Icons.check;
          tickColor = Colors.grey;
          break;
        case 'delivered':
          tickIcon = Icons.done_all;
          tickColor = Colors.grey;
          break;
        case 'read':
          tickIcon = Icons.done_all;
          tickColor = Colors.blue;
          break;
        default:
          tickIcon = Icons.check;
          tickColor = Colors.grey;
      }
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: const TextStyle(color: textColor, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                Text(
                  _formatTime(message.time),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
                if (isMe && tickIcon != null) ...[
                  const SizedBox(width: 4),
                  Icon(
                    tickIcon,
                    size: 14,
                    color: tickColor,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
