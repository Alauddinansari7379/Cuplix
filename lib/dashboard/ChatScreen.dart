// lib/dashboard/ChatScreen.dart

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

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
  final String messageType; // text / image / file / audio
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
  // UI state
  final TextEditingController _textController = TextEditingController();
  final List<_ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  bool _loadingConnection = false;
  bool _isConnected = false;
  bool _partnerTyping = false;
  bool _partnerOnline = false;

  String? _partnerId;
  String? _currentUserId;
  String _partnerName = "Partner";
  String? _partnerAvatarUrl;

  // socket
  IO.Socket? _socket;

  // typing debounce
  Timer? typingTimer;

  // audio recorder
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _recorderInited = false;
  bool _isRecording = false;
  String? _recordFilePath;
  DateTime? _recordStartTime;

  // image picker
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _fetchPartnerConnection();
  }

  Future<void> _initRecorder() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      debugPrint("❌ Microphone permission not granted");
      return;
    }

    await _recorder.openRecorder();
    _recorderInited = true;
  }

  @override
  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    _textController.dispose();
    _scrollController.dispose();
    typingTimer?.cancel();
    _recorder.closeRecorder();
    super.dispose();
  }

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
  // Get current logged-in user from /users/me
  // ---------------------------------------------------
  Future<String?> _getCurrentUserId(String token) async {
    try {
      final res = await ApiHelper.getWithAuth(
        // if you have an ApiInterface constant, you can use it here instead
        url: ApiInterface.currentUser,
        token: token,
        context: context,
        showLoader: false,
      );

      if (res == null) return null;
      final data = res["data"] ?? res;
      return data["id"]?.toString();
    } catch (e) {
      debugPrint("Error fetching current user: $e");
      return null;
    }
  }

  // ---------------------------------------------------
  // 1️⃣ LOAD PARTNER CONNECTION
  // ---------------------------------------------------
  Future<void> _fetchPartnerConnection() async {
    setState(() => _loadingConnection = true);

    final token = await SharedPrefs.getAccessToken();
    if (token == null) return;

    // First figure out who I am on this device
    final String? myId = await _getCurrentUserId(token);

    // Then fetch partner connection
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

    final String? user1Id = data["user1Id"]?.toString();
    final String? user2Id = data["user2Id"]?.toString();

    Map<String, dynamic>? partnerUser;

    if (myId != null && myId == user1Id) {
      // I am user1 → partner is user2
      _currentUserId = user1Id;
      _partnerId = user2Id;
      partnerUser = data["user2"];
    } else if (myId != null && myId == user2Id) {
      // I am user2 → partner is user1
      _currentUserId = user2Id;
      _partnerId = user1Id;
      partnerUser = data["user1"];
    } else {
      // Fallback: assume user2 is me
      _currentUserId = user2Id;
      _partnerId = user1Id;
      partnerUser = data["user1"];
    }

    final partnerProfile =
    (partnerUser?["profile"] ?? {}) as Map<String, dynamic>;
    _partnerName = partnerProfile["name"] ?? "Partner";
    _partnerAvatarUrl = partnerProfile["avatarUrl"];

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

    final data = res["data"] as Map<String, dynamic>;
    final rawList = (data["messages"] as List?) ?? [];

    final List<_ChatMessage> loaded = [];
    for (final raw in rawList) {
      final m = raw as Map<String, dynamic>;
      final senderId = m["senderId"]?.toString();

      loaded.add(
        _ChatMessage(
          id: (m["id"] ?? m["_id"]).toString(),
          clientMessageId: m["clientMessageId"],
          text: m["content"] ?? "",
          isMe: senderId == _currentUserId, // ✅ my messages
          messageType: m["messageType"] ?? "text",
          mediaUrl: m["mediaUrl"],
          status: m["status"] ?? "sent",
          time: DateTime.tryParse(m["createdAt"] ?? "") ?? DateTime.now(),
        ),
      );
    }

    setState(() {
      _messages
        ..clear()
        ..addAll(loaded);
    });

    _scrollToBottom();
  }

  // ---------------------------------------------------
  // 4️⃣ HANDLE INCOMING MESSAGE
  // ---------------------------------------------------
  void _handleIncomingMessage(dynamic raw) {
    final data = Map<String, dynamic>.from(raw as Map);

    final senderId = data["senderId"]?.toString();
    final clientMessageId = data["clientMessageId"]?.toString();
    final messageId = (data["id"] ?? data["_id"]).toString();

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

    final isMe = senderId != null && senderId == _currentUserId; // ✅

    final msg = _ChatMessage(
      id: messageId,
      clientMessageId: clientMessageId,
      text: data["content"] ?? "",
      isMe: isMe,
      messageType: data["messageType"] ?? "text",
      mediaUrl: data["mediaUrl"],
      status: data["status"] ?? "sent",
      time: DateTime.tryParse(data["createdAt"] ?? "") ?? DateTime.now(),
    );

    setState(() => _messages.add(msg));
    _scrollToBottom();

    if (!isMe) {
      _markMessageAsRead([msg.id]);
    }
  }

  // ---------------------------------------------------
  // 5️⃣ SEND TEXT MESSAGE
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
      "receiverId": _partnerId, // always the other person
      "content": text,
      "messageType": "text",
      "clientMessageId": clientMessageId,
    });
  }

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
  // Emoji / Attach / Camera / Mic handlers
  // ---------------------------------------------------
  void _onEmojiPressed() {
    debugPrint("Emoji button pressed");
  }

  Future<void> _onAttachFilePressed() async {
    try {
      final result = await FilePicker.platform.pickFiles(allowMultiple: false);
      if (result == null || result.files.isEmpty) return;

      final path = result.files.single.path;
      if (path == null) return;

      await _sendFileMessage(path);
    } catch (e) {
      debugPrint("Error picking file: $e");
    }
  }

  Future<void> _sendFileMessage(String filePath) async {
    if (_socket == null || _partnerId == null) return;

    final file = File(filePath);
    if (!file.existsSync()) return;

    final clientMessageId =
        "file-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(999999)}";

    final fileName = file.path.split(Platform.pathSeparator).last;

    final optimistic = _ChatMessage(
      id: clientMessageId,
      clientMessageId: clientMessageId,
      text: fileName,
      isMe: true,
      messageType: "file",
      mediaUrl: file.path,
      status: "sent",
      time: DateTime.now(),
    );

    setState(() {
      _messages.add(optimistic);
    });
    _scrollToBottom();

    _socket!.emit("send-message", {
      "receiverId": _partnerId,
      "content": "File: $fileName",
      "messageType": "text",
      "clientMessageId": clientMessageId,
    });
  }

  Future<void> _onCameraPressed() async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 80,
      );
      if (picked == null) return;

      await _sendImageMessage(picked.path);
    } catch (e) {
      debugPrint("Error opening camera: $e");
    }
  }

  Future<void> _sendImageMessage(String filePath) async {
    if (_socket == null || _partnerId == null) return;

    final file = File(filePath);
    if (!file.existsSync()) return;

    final clientMessageId =
        "image-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(999999)}";

    final fileName = file.path.split(Platform.pathSeparator).last;

    final optimistic = _ChatMessage(
      id: clientMessageId,
      clientMessageId: clientMessageId,
      text: "",
      isMe: true,
      messageType: "image",
      mediaUrl: file.path,
      status: "sent",
      time: DateTime.now(),
    );

    setState(() {
      _messages.add(optimistic);
    });
    _scrollToBottom();

    _socket!.emit("send-message", {
      "receiverId": _partnerId,
      "content": "[Image] $fileName",
      "messageType": "text",
      "clientMessageId": clientMessageId,
    });
  }

  // 🎤 MIC: RECORD + SEND VOICE MESSAGE
  Future<void> _onMicPressed() async {
    if (_partnerId == null) return;
    if (!_recorderInited) {
      debugPrint("Recorder not initialized");
      return;
    }

    if (_isRecording) {
      final path = await _stopRecording();
      if (path != null) {
        await _sendVoiceMessage(path);
      }
      return;
    }

    await _startRecording();
  }

  Future<void> _startRecording() async {
    try {
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        debugPrint("❌ Microphone permission not granted");
        return;
      }

      final dir = await getTemporaryDirectory();
      final filePath =
          '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.aac';

      await _recorder.startRecorder(
        toFile: filePath,
        codec: Codec.aacADTS,
      );

      setState(() {
        _isRecording = true;
        _recordFilePath = filePath;
        _recordStartTime = DateTime.now();
      });
      debugPrint("🎙️ Recording started → $filePath");
    } catch (e) {
      debugPrint("Error starting recording: $e");
    }
  }

  Future<String?> _stopRecording() async {
    try {
      final path = await _recorder.stopRecorder();
      debugPrint("🛑 Recording stopped: $path");
      setState(() {
        _isRecording = false;
      });
      return path ?? _recordFilePath;
    } catch (e) {
      debugPrint("Error stopping recording: $e");
      setState(() {
        _isRecording = false;
      });
      return null;
    }
  }

  Future<void> _sendVoiceMessage(String filePath) async {
    if (_socket == null || _partnerId == null) return;

    final file = File(filePath);
    if (!file.existsSync()) {
      debugPrint("Voice file does not exist: $filePath");
      return;
    }

    int seconds = 0;
    if (_recordStartTime != null) {
      seconds = DateTime.now().difference(_recordStartTime!).inSeconds;
      if (seconds < 1) seconds = 1;
    }
    final label =
    seconds > 0 ? "Voice note • ${seconds}s" : "Voice note";

    final clientMessageId =
        "voice-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(999999)}";

    final optimistic = _ChatMessage(
      id: clientMessageId,
      clientMessageId: clientMessageId,
      text: label,
      isMe: true,
      messageType: "audio",
      mediaUrl: file.path,
      status: "sent",
      time: DateTime.now(),
    );

    setState(() {
      _messages.add(optimistic);
    });
    _scrollToBottom();

    _socket!.emit("send-message", {
      "receiverId": _partnerId,
      "content": label,
      "messageType": "text",
      "clientMessageId": clientMessageId,
    });
  }

  // ---------------------------------------------------
  // UI
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
              controller: _scrollController,
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

  Widget _buildInputBar() {
    final hasText = _textController.text.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: const Color(0xFFE0C9F0),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _onEmojiPressed,
                    icon: const Icon(
                      Icons.emoji_emotions_outlined,
                      size: 22,
                      color: Color(0xFF8A7C9B),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      minLines: 1,
                      maxLines: 4,
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
                      decoration: const InputDecoration(
                        hintText: "Type a message...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _onAttachFilePressed,
                    icon: const Icon(
                      Icons.attach_file,
                      size: 20,
                      color: Color(0xFF8A7C9B),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    onPressed: _onCameraPressed,
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      size: 20,
                      color: Color(0xFF8A7C9B),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              if (hasText) {
                _sendMessage();
              } else {
                _onMicPressed();
              }
            },
            child: Container(
              height: 46,
              width: 46,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFF05A94), Color(0xFFE83C7A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(
                hasText
                    ? Icons.send
                    : (_isRecording ? Icons.stop : Icons.mic),
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// MESSAGE BUBBLE
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

    final lower = message.text.toLowerCase();
    final isAudio = message.messageType == 'audio' ||
        lower.startsWith('voice note') ||
        lower.startsWith('voice message');
    final isFile =
        message.messageType == 'file' || lower.startsWith('file:');
    final isImage =
        message.messageType == 'image' || lower.startsWith('[image]');

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

    Widget content;

    if (isImage) {
      if (message.mediaUrl != null) {
        final file = File(message.mediaUrl!);
        content = ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            file,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
            const Icon(Icons.broken_image, color: textColor),
          ),
        );
      } else {
        content = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.image, size: 18, color: textColor),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                message.text,
                style: const TextStyle(color: textColor, fontSize: 15),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      }
    } else if (isFile) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.attach_file, size: 18, color: textColor),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message.text,
              style: const TextStyle(color: textColor, fontSize: 15),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    } else if (isAudio) {
      final label =
      message.text.isNotEmpty ? message.text : 'Voice note';
      final String? url = message.mediaUrl;

      Future<void> playAudio() async {
        if (url == null || url.isEmpty) return;
        final player = AudioPlayer();
        try {
          if (url.startsWith('http')) {
            await player.play(UrlSource(url));
          } else {
            await player.play(DeviceFileSource(url));
          }
        } catch (e) {
          debugPrint("Error playing audio: $e");
        }
      }

      content = InkWell(
        onTap: url == null ? null : playAudio,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              const Icon(Icons.play_arrow,
                  size: 22, color: Colors.black54),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 3,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 40,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.deepPurpleAccent,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      content = Text(
        message.text,
        style: const TextStyle(color: textColor, fontSize: 15),
      );
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
            content,
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
