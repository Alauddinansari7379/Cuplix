import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InvitePartnerScreen extends StatefulWidget {
  const InvitePartnerScreen({Key? key}) : super(key: key);

  @override
  State<InvitePartnerScreen> createState() => _InvitePartnerScreenState();
}

class _InvitePartnerScreenState extends State<InvitePartnerScreen> {
  String? _generatedCode;
  final TextEditingController _partnerCodeController = TextEditingController();

  @override
  void dispose() {
    _partnerCodeController.dispose();
    super.dispose();
  }

  // simple random 6-character code
  String _createRandomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rnd = Random();
    return List.generate(6, (_) => chars[rnd.nextInt(chars.length)]).join();
  }

  void _onGenerateInvite() {
    final code = _createRandomCode();
    setState(() => _generatedCode = code);

    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Invite code "$code" copied to clipboard')),
    );
  }

  void _onConnect() {
    final code = _partnerCodeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your partner\'s code')),
      );
      return;
    }

    // TODO: call your backend connect-partner API with [code]
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Attempting to connect with code: $code')),
    );
  }

  bool get _canConnect => _partnerCodeController.text.trim().length >= 4;

  @override
  Widget build(BuildContext context) {
    const gradient = LinearGradient(
      colors: [Color(0xFFaf57db), Color(0xFFe46791)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFBFF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2C2139)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              const Icon(Icons.favorite_outline,
                  color: Color(0xFFaf57db), size: 40),
              const SizedBox(height: 10),
              const Text(
                'Connect with Your Partner',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2C2139),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Grow your relationship together',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF9A8EA0),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 26),

              // Share your invite code card
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 44,
                          width: 44,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFf5c2ff), Color(0xFFaf57db)],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_add_alt_1,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Share Your Invite Code',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Send this code to your partner so they can connect with you',
                                style: TextStyle(
                                  color: Color(0xFF9A8EA0),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Generate button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          gradient: gradient,
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                        ),
                        child: ElevatedButton(
                          onPressed: _onGenerateInvite,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text(
                            'Generate Invite Code',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (_generatedCode != null) ...[
                      const Text(
                        'Your invite code',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF9A8EA0),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F6F8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE0D6EA)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _generatedCode!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 3,
                                fontSize: 16,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 18),
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: _generatedCode!),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Code copied to clipboard'),
                                  ),
                                );
                              },
                            )
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // OR divider
              Row(
                children: const [
                  Expanded(child: Divider(color: Color(0xFFE3D7F0))),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: Color(0xFF9A8EA0),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Color(0xFFE3D7F0))),
                ],
              ),

              const SizedBox(height: 24),

              // Enter partner's code card
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 44,
                          width: 44,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFB9E4FF), Color(0xFFB06BF3)],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite_border,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Enter Partner's Code",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Have a code from your partner? Enter it here to connect',
                                style: TextStyle(
                                  color: Color(0xFF9A8EA0),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Invite Code',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _partnerCodeController,
                            onChanged: (_) => setState(() {}),
                            textCapitalization: TextCapitalization.characters,
                            decoration: InputDecoration(
                              hintText: 'XXXXXX',
                              filled: true,
                              fillColor: const Color(0xFFF8F6F8),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 44,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: gradient,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: ElevatedButton(
                              onPressed: _canConnect ? _onConnect : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                disabledForegroundColor:
                                Colors.white.withOpacity(0.7),
                                disabledBackgroundColor:
                                Colors.transparent,
                                padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: const Text(
                                'Connect',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDE3F4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: child,
    );
  }
}
