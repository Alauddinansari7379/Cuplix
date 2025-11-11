// lib/chat/chat_screen.dart
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final String partnerName;
  final String partnerInitial;
  final bool isConnected;

  const ChatScreen({
    Key? key,
    this.partnerName = 'Partner',
    this.partnerInitial = 'P',
    this.isConnected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // theme colors used in your designs
    const primaryText = Color(0xFF2C2139);
    const mutedText = Color(0xFF9A8EA0);
    const cardBorder = Color(0xFFEDE8EF);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 16), // 👈 Adds margin from start (left side)
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey.shade200,
              child: Text(
                partnerInitial,
                style: const TextStyle(
                  color: Color(0xFF2C2139),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    partnerName,
                    style: const TextStyle(
                      color: Color(0xFF2C2139),
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
                          color: isConnected ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isConnected ? 'Online' : 'Offline',
                        style: const TextStyle(
                          color: Color(0xFF9A8EA0),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Color(0xFF2C2139)),
              onPressed: () {},
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFFBF8FB),
      body: SafeArea(
        child: Column(
          children: [
            // Message area (empty state)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'No messages yet. Send a message to start the conversation!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: mutedText,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ),

            // Bottom disconnected/info bar (fixed)
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
                    Text(
                      isConnected
                          ? 'You are connected with this partner.'
                          : 'You are no longer connected with this partner.',
                      style: const TextStyle(color: mutedText, fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 220,
                      child: OutlinedButton(
                        onPressed: () {
                          // open manage connections screen
                          // Navigator.push(context, MaterialPageRoute(builder: (_) => ManageConnectionsPage()));
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
        ),
      ),
    );
  }
}
