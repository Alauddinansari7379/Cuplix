import 'package:flutter/material.dart';


class AiTherapistScreen extends StatelessWidget {
  const AiTherapistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final contentWidth = width > 800 ? 760.0 : width - 32.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  Header(),
                  SizedBox(height: 18),
                  ConversationCard(),
                  SizedBox(height: 18),
                  AiAnalysisCard(),
                  SizedBox(height: 18),
                  NextTimeCard(),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* -------------------------- Header -------------------------- */
class Header extends StatelessWidget {
  const Header({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        SizedBox(height: 4),
        IconRow(),
        SizedBox(height: 12),
        Text(
          'AI Therapist Mode',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF3A2140)),
        ),
        SizedBox(height: 6),
        Text(
          'Conflict replay and emotional awareness training',
          style: TextStyle(fontSize: 15, color: Color(0xFF7B6F79)),
        ),
      ],
    );
  }
}

class IconRow extends StatelessWidget {
  const IconRow({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1FB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFEBDDF2)),
        ),
        child: const Icon(Icons.headset_rounded, color: Color(0xFF9C57D6)),
      )
    ]);
  }
}

/* --------------------- Conversation Card -------------------- */
class ConversationCard extends StatefulWidget {
  const ConversationCard({super.key});
  @override
  State<ConversationCard> createState() => _ConversationCardState();
}

class _ConversationCardState extends State<ConversationCard> {
  // example messages
  final List<_Msg> _messages = [
    _Msg(sender: 'You', text: "I feel like you never listen to me anymore. It's like I'm talking to a wall.", time: '14:32:15'),
    _Msg(sender: 'Partner', text: "That's not true! I listen all the time. You just don't like what I have to say.", time: '14:32:32'),
    _Msg(sender: 'You', text: "See? That's exactly what I mean. You turn everything around!", time: '14:32:45'),
    _Msg(sender: 'Partner', text: "I'm not turning anything around. You're just being dramatic.", time: '14:33:02'),
  ];

  @override
  Widget build(BuildContext context) {
    return _RoundedCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + actions
            Row(
              children: [
                const Expanded(
                  child: Text('Conversation Replay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.refresh_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFF3ECEF),
                    padding: const EdgeInsets.all(8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    backgroundColor: Colors.purple,
                    elevation: 0,
                  ),
                  child: const Icon(Icons.play_arrow, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // messages list inside a fixed-height box (scrollable)
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.45,
                minHeight: 120,
              ),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF0E9EE)),
              ),
              child: Scrollbar(
                thumbVisibility: true,
                thickness: 8,
                radius: const Radius.circular(8),
                child: ListView.separated(
                  itemCount: _messages.length,
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(8),
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final m = _messages[index];
                    final isYou = m.sender == 'You';
                    return _MessageBubble(msg: m, isYou: isYou);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Msg {
  final String sender;
  final String text;
  final String time;
  _Msg({required this.sender, required this.text, required this.time});
}

class _MessageBubble extends StatelessWidget {
  final _Msg msg;
  final bool isYou;
  const _MessageBubble({required this.msg, required this.isYou, super.key});

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isYou ? const Color(0xFFF8F0D8) : const Color(0xFFF1ECEC);
    final senderColor = isYou ? const Color(0xFFB11F1F) : const Color(0xFF6D2DF5); // You=red, Partner=purple
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // left aligned bubble (design shows both left aligned, but with colored sender label)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(msg.sender, style: TextStyle(fontWeight: FontWeight.w700, color: senderColor)),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(color: bubbleColor, borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Text(msg.text, style: const TextStyle(height: 1.4)),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: Text(msg.time, style: const TextStyle(fontSize: 11, color: Color(0xFF8D8590))),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/* ------------------------ AI Analysis Card ----------------------- */
class AiAnalysisCard extends StatelessWidget {
  const AiAnalysisCard({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      'The tone started calm but escalated when interruptions began.',
      "You both raised voices within 30 seconds — that's your trigger point.",
      "Partner's defensive response at 14:32:32 shut down further communication.",
      'The conversation lacked active listening after the first minute.',
    ];

    return _RoundedCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: const [
            Icon(Icons.show_chart, color: Color(0xFF9C57D6)),
            SizedBox(width: 8),
            Text('AI Analysis', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          ]),
          const SizedBox(height: 12),
          Column(
            children: items.map((t) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F3FB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF0E6F6)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 18, color: Color(0xFFB77AC9)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(t, style: const TextStyle(color: Color(0xFF4E414A), height: 1.4))),
                  ],
                ),
              ),
            )).toList(),
          )
        ]),
      ),
    );
  }
}

/* ---------------------- "How It Could Go Next Time" ------------- */
class NextTimeCard extends StatelessWidget {
  const NextTimeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final suggestions = [
      "Try using 'I feel' statements instead of 'You never'",
      'Take a 30-second pause before responding when feeling defensive',
      "Ask clarifying questions: 'What I hear you saying is...'",
      'Acknowledge emotions before addressing issues',
    ];

    return _RoundedCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: const [
            Icon(Icons.check_circle_outline, color: Color(0xFF9C57D6)),
            SizedBox(width: 8),
            Text('How It Could Go Next Time', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          ]),
          const SizedBox(height: 12),
          Column(
            children: suggestions.asMap().entries.map((e) {
              final idx = e.key + 1;
              final text = e.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: const Color(0xFFFAF3FF),
                      child: Text('$idx', style: const TextStyle(color: Color(0xFF9C57D6), fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(text, style: const TextStyle(height: 1.4))),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 46,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                backgroundColor: Colors.transparent,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF9C57D6), Color(0xFFFF78A8)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: const Text('Practice This Conversation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }
}

/* -------------------- small reusable rounded card ------------------- */
class _RoundedCard extends StatelessWidget {
  final Widget child;
  const _RoundedCard({required this.child, super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
        border: Border.all(color: const Color(0xFFF1EAF0)),
      ),
      child: child,
    );
  }
}