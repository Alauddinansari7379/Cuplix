import 'package:flutter/material.dart';

class AiAgentScreen extends StatelessWidget {
  const AiAgentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final contentWidth = width > 800 ? 760.0 : width - 32;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SectionHeader(
                  title: 'AI Agent',
                  subtitle:
                  'Command your AI assistant to execute app features through natural language',
                ),
                const SizedBox(height: 18),

                // Hero / Personal Assistant Card
                SizedBox(width: contentWidth, child: const PersonalAssistantCard()),

                const SizedBox(height: 18),

                // Try Commands Row
                SizedBox(
                  width: contentWidth,
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: Colors.purple.shade100),
                          ),
                          icon: const Icon(Icons.chat_bubble_outline),
                          label: const Text('Try Text Commands'),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Fixed Gradient Button
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {},
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.purple.shade300, Colors.pink.shade300],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.mic, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Try Voice Commands',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Chat area card
                SizedBox(width: contentWidth, child: const AssistantChatCard()),

                const SizedBox(height: 18),

                // How it works card
                SizedBox(width: contentWidth, child: const HowItWorksCard()),

                const SizedBox(height: 18),

                // Examples card
                SizedBox(width: contentWidth, child: const ExamplesCard()),

                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Section header (title + subtitle)
class SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const SectionHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 28, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 760,
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
          ),
        ),
      ],
    );
  }
}

/// The top personal assistant card with feature tiles
class PersonalAssistantCard extends StatelessWidget {
  const PersonalAssistantCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: const Color(0xFFFBF7FB),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: Colors.purple.shade50,
              child: Icon(Icons.smart_toy, size: 36, color: Colors.purple.shade400),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your Personal AI Assistant',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
            ),
            const SizedBox(height: 6),
            Text(
              'Control your entire relationship app through simple voice or text commands',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),

            // Feature tiles
            Column(
              children: const [
                FeatureTile(
                  icon: Icons.event,
                  title: 'Calendar Management',
                  subtitle: 'Add events, set reminders',
                ),
                SizedBox(height: 12),
                FeatureTile(
                  icon: Icons.card_giftcard,
                  title: 'Gift Suggestions',
                  subtitle: 'Personalized recommendations',
                ),
                SizedBox(height: 12),
                FeatureTile(
                  icon: Icons.favorite_border,
                  title: 'Mood Tracking',
                  subtitle: 'Log emotions and patterns',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Feature tile used in the hero card
class FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const FeatureTile({super.key, required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: Colors.purple, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Chat card (AI message + chips + input)
class AssistantChatCard extends StatelessWidget {
  const AssistantChatCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFF8FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.room, color: Colors.purple.shade300),
                const SizedBox(width: 10),
                const Text('AI Assistant', style: TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF2ECEF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Hello! I'm your AI assistant. I can help you manage your calendar, suggest gifts, track your mood, and more. What would you like me to do?",
                    style: TextStyle(height: 1.4),
                  ),
                  SizedBox(height: 8),
                  Text('04:52 pm', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                SmallChip('Add anniversary to calendar'),
                SmallChip('Suggest a romantic gift'),
                SmallChip('Plan a date night'),
                SmallChip('Track my mood today'),
                SmallChip('Invite partner to connect'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Ask me to add events, suggest gifts, or anything else...',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.mic, color: Colors.purple),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade300, Colors.pink.shade300],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  TinyTag('Calendar Events'),
                  TinyTag('Gift Suggestions'),
                  TinyTag('Mood Tracking'),
                  TinyTag('Partner Connection'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// small rounded chip for quick actions
class SmallChip extends StatelessWidget {
  final String label;
  const SmallChip(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF2ECEF),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(label, style: const TextStyle(fontSize: 13)),
    );
  }
}

/// tiny tag chip used in footer of chat card
class TinyTag extends StatelessWidget {
  final String label;
  const TinyTag(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, size: 10, color: Colors.purple),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}

/// How it works card with numbered steps
class HowItWorksCard extends StatelessWidget {
  const HowItWorksCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: const [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'How It Works',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(height: 12),
            HowStep(
              number: 1,
              title: 'Describe What You Want',
              subtitle:
              "Simply tell the AI agent what you'd like to do in natural language",
            ),
            SizedBox(height: 12),
            HowStep(
              number: 2,
              title: 'AI Processes Your Request',
              subtitle:
              'The agent understands your command and prepares the action',
            ),
            SizedBox(height: 12),
            HowStep(
              number: 3,
              title: 'Action Completed',
              subtitle: 'The AI executes the task and confirms completion',
            ),
          ],
        ),
      ),
    );
  }
}

class HowStep extends StatelessWidget {
  final int number;
  final String title;
  final String subtitle;
  const HowStep(
      {super.key, required this.number, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.purple.shade50,
          child: Text('$number', style: const TextStyle(color: Colors.purple)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Examples card with rounded example rows
class ExamplesCard extends StatelessWidget {
  const ExamplesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final examples = [
      'Add a romantic dinner with my partner next Friday',
      'Suggest a personalized gift for our anniversary',
      "Log that I'm feeling stressed today",
      'Invite my partner to a weekend getaway',
      'Create a journal entry about our last conversation',
      'Plan a surprise date night',
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Try These Examples',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 12),
            Column(
              children: examples
                  .map(
                    (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2ECEF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('"$e"', style: const TextStyle(fontSize: 14)),
                  ),
                ),
              )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
