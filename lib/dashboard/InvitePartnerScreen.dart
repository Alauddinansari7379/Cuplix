import 'package:cuplix/apiInterface/ApiInterface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../apiInterface/ApIHelper.dart';
import '../utils/SharedPreferences.dart';

class InvitePartnerScreen extends StatefulWidget {
  const InvitePartnerScreen({Key? key}) : super(key: key);

  @override
  State<InvitePartnerScreen> createState() => _InvitePartnerScreenState();
}

class _InvitePartnerScreenState extends State<InvitePartnerScreen> {
  String? _generatedCode;
  final TextEditingController _partnerCodeController = TextEditingController();
  bool _isGenerating = false;
  bool _isConnecting = false; // <-- added

  @override
  void dispose() {
    _partnerCodeController.dispose();
    super.dispose();
  }

  // ------------ Helpers ------------

  Future<String> _getAuthToken() async {
    final token = await SharedPrefs.getAccessToken();
    return token ?? '';
  }

  bool get _hasCode =>
      _generatedCode != null && _generatedCode!.trim().isNotEmpty;

  String get _shareMessage =>
      'Here is my Cuplix invite code: $_generatedCode\n\nUse this to connect with me in the app.';

  void _requireCodeFirst() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generate your invite code first')),
    );
  }

  Future<void> _copyShareMessage(String where) async {
    await Clipboard.setData(ClipboardData(text: _shareMessage));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Invite message copied. Open $where and paste it to share.',
        ),
      ),
    );
  }

  // ------------ Generate invite (API) ------------

  Future<void> _onGenerateInvite() async {
    if (_isGenerating) return;
    setState(() => _isGenerating = true);

    final token = await _getAuthToken();
    if (token.isEmpty) {
      setState(() => _isGenerating = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please log in again')));
      return;
    }

    final res = await ApiHelper.postWithAuth(
      url: ApiInterface.partnerConnections,
      token: token,
      body: const {},
      context: context,
      showLoader: true,
    );

    if (!mounted) return;
    setState(() => _isGenerating = false);

    if (res['success'] == true) {
      final data = res['data'] as Map<String, dynamic>;
      final code = data['inviteCode']?.toString();

      if (code != null && code.isNotEmpty) {
        setState(() => _generatedCode = code);

        Clipboard.setData(ClipboardData(text: code));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invite code "$code" copied to clipboard')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get invite code')),
        );
      }
    } else {
      final error = res['error'] ?? 'Something went wrong';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  // ------------ Share actions (clipboard only) ------------

  Future<void> _shareWhatsApp() async {
    if (!_hasCode) return _requireCodeFirst();
    await _copyShareMessage('WhatsApp');
  }

  Future<void> _shareEmail() async {
    if (!_hasCode) return _requireCodeFirst();
    await _copyShareMessage('your email app');
  }

  Future<void> _shareSms() async {
    if (!_hasCode) return _requireCodeFirst();
    await _copyShareMessage('your SMS app');
  }

  Future<void> _shareMore() async {
    if (!_hasCode) return _requireCodeFirst();
    await _copyShareMessage('any app');
  }

  // ------------ Connect with partner (CALL /accept API) ------------

  Future<void> _onConnect() async {
    final code = _partnerCodeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your partner\'s code')),
      );
      return;
    }

    if (_isConnecting) return;
    setState(() => _isConnecting = true);

    final token = await _getAuthToken();
    if (token.isEmpty) {
      setState(() => _isConnecting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please log in again')));
      return;
    }

    final res = await ApiHelper.postWithAuth(
      url: '${ApiInterface.partnerConnections}/accept',
      token: token,
      body: {"inviteCode": code},
      context: context,
      showLoader: true,
    );

    if (!mounted) return;
    setState(() => _isConnecting = false);

    if (res['success'] == true) {
      final data = res['data'] as Map<String, dynamic>?;

      // try to get partner details from response
      Map<String, dynamic>? partner =
          (data?['partner'] ?? data?['user2'] ?? data?['user1'])
              as Map<String, dynamic>?;

      final profile = partner?['profile'] as Map<String, dynamic>?;

      final partnerName = profile?['name']?.toString() ?? 'Alex Doe';
      final partnerRole = profile?['role']?.toString() ?? 'husband';

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You are now connected with your partner!'),
        ),
      );

      // return info to Dashboard
      Navigator.pop(context, {
        'connected': true,
        'partnerName': partnerName,
        'partnerRole': partnerRole,
      });
    } else {
      final error = res['error'] ?? 'Unable to connect with this invite code';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  bool get _canConnect =>
      _partnerCodeController.text.trim().length >= 4 && !_isConnecting;

  // ------------ UI ------------

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
              const Icon(
                Icons.favorite_outline,
                color: Color(0xFFaf57db),
                size: 40,
              ),
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
                style: TextStyle(color: Color(0xFF9A8EA0), fontSize: 14),
              ),
              const SizedBox(height: 26),

              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 44,
                          width: 44,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
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

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          gradient: gradient,
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                        ),
                        child: ElevatedButton(
                          onPressed: _isGenerating ? null : _onGenerateInvite,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(
                            _isGenerating
                                ? 'Generating...'
                                : 'Generate Invite Code',
                            style: const TextStyle(
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
                          horizontal: 14,
                          vertical: 10,
                        ),
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
                                fontSize: 20,
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
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Color(0xFFE3D7F0)),
                      const SizedBox(height: 8),
                      const Text(
                        'Share via:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF9A8EA0),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _shareWhatsApp,
                              icon: const Icon(Icons.whatshot),
                              label: const Text('WhatsApp'),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _shareEmail,
                              icon: const Icon(Icons.email_outlined),
                              label: const Text('Email'),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _shareSms,
                              icon: const Icon(Icons.sms_outlined),
                              label: const Text('SMS'),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _shareMore,
                              icon: const Icon(Icons.share_outlined),
                              label: const Text('More'),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

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

              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 44,
                          width: 44,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
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
                                horizontal: 16,
                                vertical: 14,
                              ),
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
                            decoration: const BoxDecoration(
                              gradient: gradient,
                              borderRadius: BorderRadius.all(
                                Radius.circular(24),
                              ),
                            ),
                            child: ElevatedButton(
                              onPressed: _canConnect ? _onConnect : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                disabledForegroundColor: Colors.white
                                    .withOpacity(0.7),
                                disabledBackgroundColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
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
          ),
        ],
      ),
      child: child,
    );
  }
}
