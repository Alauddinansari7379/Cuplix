import 'package:flutter/material.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  bool emotionAnalysisOn = true;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FB),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header Section
              const HeaderSection(),
              const SizedBox(height: 10),

              // Description Box
              const DescriptionBox(),
              const SizedBox(height: 10),

              // Emotion Analysis
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Emotion Analysis',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    Switch(
                      value: emotionAnalysisOn,
                      onChanged: (v) => setState(() => emotionAnalysisOn = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Chat Bubble
              const ChatBubble(),
              const SizedBox(height: 10),

              // Input Box
              InputArea(controller: _controller),
              const SizedBox(height: 14),

              // Quick Suggestions
              const QuickSuggestions(),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.purple.shade200,
          child: const Icon(Icons.android, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI Companion',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.circle, color: Colors.green, size: 8),
                SizedBox(width: 6),
                Text('Online', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
        )
      ],
    );
  }
}

class DescriptionBox extends StatelessWidget {
  const DescriptionBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF2EEF8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        "Your private, judgment-free space to talk about anything",
        style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.3),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2ECEF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hi! I'm here to help you strengthen your relationship. How are you feeling today?",
            style: TextStyle(fontSize: 13, height: 1.4),
          ),
          SizedBox(height: 6),
          Text('03:54 pm', style: TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}

class InputArea extends StatelessWidget {
  final TextEditingController controller;
  const InputArea({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Type your message... (Press Enter to send)',
                hintStyle: TextStyle(fontSize: 13),
                border: InputBorder.none,
              ),
              minLines: 1,
              maxLines: 3,
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.mic_none, size: 20)),
          Container(
            decoration: BoxDecoration(
              gradient:
              LinearGradient(colors: [Colors.purpleAccent, Colors.purple]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class QuickSuggestions extends StatelessWidget {
  const QuickSuggestions({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Suggestions',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: const [
              SuggestionChip('I need help with communication'),
              SuggestionChip('Feeling disconnected lately'),
              SuggestionChip('Want to plan a date night'),
              SuggestionChip('Need advice on conflict resolution'),
            ],
          )
        ],
      ),
    );
  }
}

class SuggestionChip extends StatelessWidget {
  final String label;
  const SuggestionChip(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: const Color(0xFFF2EEF8),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    );
  }
}