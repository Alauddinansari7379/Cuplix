import 'package:flutter/material.dart';

class MirrorModeScreen extends StatefulWidget {
  const MirrorModeScreen({super.key});

  @override
  State<MirrorModeScreen> createState() => _MirrorModeScreenState();
}

class _MirrorModeScreenState extends State<MirrorModeScreen> {
  final TextEditingController _partnerController = TextEditingController(text: 'Your Partner');
  final TextEditingController _chatController = TextEditingController();
  String _topic = 'General';
  final List<String> _topics = ['General', 'Relationship', 'Conflict', 'Appreciation', 'Scheduling'];

  @override
  void dispose() {
    _partnerController.dispose();
    _chatController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_chatController.text.trim().isEmpty) return;
    // For demo: clear input. In real app you would append message to message list.
    _chatController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message sent to partner-s AI twin (demo)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // compact padding and card radius to match your screenshots
    const double cardRadius = 12;
    const Color bg = Color(0xFFF9F6FB);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                'Mirror Mode',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.05),
              ),
              const SizedBox(height: 6),
              const Text(
                'Practice conversations with your partner\'s AI twin in a safe space',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 16),

              // Info Card: How Mirror Mode Works
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(cardRadius),
                  boxShadow: const [
                    BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 3))
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // icon circle
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.purple.shade100, Colors.purple.shade300]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.smart_toy, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('How Mirror Mode Works',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          SizedBox(height: 6),
                          Text(
                            'Our AI mimics your partner\'s communication style based on shared history. Practice difficult conversations or rehearse important discussions.',
                            style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.3),
                          ),
                          SizedBox(height: 8),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Conversation Settings Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(cardRadius),
                  border: Border.all(color: const Color(0xFFEFE8F3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Conversation Settings',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 12),

                    // Topic Dropdown
                    const Text('Conversation Topic', style: TextStyle(fontSize: 13, color: Colors.black87)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F4FB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFEDE4EE)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _topic,
                          isExpanded: true,
                          items: _topics
                              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                              .toList(),
                          onChanged: (v) => setState(() => _topic = v ?? _topic),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Partner's Name
                    const Text('Partner\'s Name', style: TextStyle(fontSize: 13, color: Colors.black87)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F4FB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFEDE4EE)),
                      ),
                      child: TextField(
                        controller: _partnerController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Your Partner',
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Practice Conversation Box (big area)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(cardRadius),
                  border: Border.all(color: const Color(0xFFEDE4EE)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // top row: title + optional listen button
                    Row(
                      children: [
                        const Expanded(
                          child: Text('Practice Conversation',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        ),
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.play_arrow, size: 18),
                          label: const Text('Start Listening'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.purple,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),

                    // large empty conversation area
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F3F6),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFF0E9F1)),
                      ),
                      child: const Center(
                        child: Text(
                          'Start a conversation with Your Partner\'s AI twin...',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black45),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Input row
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F4FB),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE9E0EA)),
                            ),
                            child: TextField(
                              controller: _chatController,
                              minLines: 1,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                hintText: 'What would you like to say to Your Partner?',
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // mic button
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFEDE4EE)),
                            ),
                            child: const Icon(Icons.mic_none, color: Colors.purple),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // send button (gradient)
                        GestureDetector(
                          onTap: _sendMessage,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [Colors.purple, Colors.pinkAccent]),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.send, color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Communication Tips Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(cardRadius),
                  border: Border.all(color: const Color(0xFFEDE4EE)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Communication Tips',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.chat_bubble_outline, color: Colors.purple, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Active Listening\nNotice how your partner responds. This can help you understand their perspective better.',
                            style: TextStyle(fontSize: 13, height: 1.35),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.shield_outlined, color: Colors.purple, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Safe Practice\nUse this space to rehearse difficult conversations before having them in real life.',
                            style: TextStyle(fontSize: 13, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}