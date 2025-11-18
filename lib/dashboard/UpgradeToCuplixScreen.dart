// lib/subscription/upgrade_to_cuplix_screen.dart
import 'package:flutter/material.dart';

class UpgradeToCuplixScreen extends StatefulWidget {
  const UpgradeToCuplixScreen({Key? key}) : super(key: key);

  @override
  State<UpgradeToCuplixScreen> createState() => _UpgradeToCuplixScreenState();
}

class _UpgradeToCuplixScreenState extends State<UpgradeToCuplixScreen> {
  bool _isAnnual = true;

  static const _bgColor = Color(0xFFFBF8FB);
  static const _primaryText = Color(0xFF241B35);
  static const _mutedText = Color(0xFF9A8EA0);
  static const _purple = Color(0xFFaf57db);
  static const _pink = Color(0xFFe46791);
  static const _gold = Color(0xFFF2B300);

  @override
  Widget build(BuildContext context) {
    const headerGradient = LinearGradient(
      colors: [_purple, _pink],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
      backgroundColor: _bgColor,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: _primaryText),
        onPressed: () => Navigator.pop(context),
      ),
    ),

    body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Big title + subtitle
              Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      gradient: headerGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.cabin, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upgrade to Cuplix+',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: _primaryText,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Get full access to all premium features. Start with a 14-day free trial, no credit card required.',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: _mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Free Trial card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFBEFFF), Color(0xFFFFF7FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.calendar_month,
                          color: _purple, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Free Trial Active',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: _primaryText,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '10 days remaining in your free trial',
                            style: TextStyle(
                              fontSize: 13,
                              color: _mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _GradientPillButton(
                      label: 'Upgrade Now',
                      onTap: () {
                        // TODO: start upgrade flow
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Billing toggle
              Center(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2EDF8),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  width: 240,
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isAnnual = false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color:
                              !_isAnnual ? Colors.white : Colors.transparent,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Monthly',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: !_isAnnual
                                    ? _primaryText
                                    : _mutedText,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isAnnual = true),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color:
                              _isAnnual ? Colors.white : Colors.transparent,
                            ),
                            alignment: Alignment.center,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Text(
                                  'Annual',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _isAnnual
                                        ? _primaryText
                                        : _mutedText,
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: -10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _gold,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: const Text(
                                      'Save 25%',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // Free plan card
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE7DFF0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Free Forever',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _primaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        Text(
                          '\$0',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: _primaryText,
                          ),
                        ),
                        SizedBox(width: 4),
                        Padding(
                          padding: EdgeInsets.only(bottom: 3),
                          child: Text(
                            '/month',
                            style: TextStyle(
                              fontSize: 13,
                              color: _mutedText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Perfect for couples getting started',
                      style: TextStyle(
                        fontSize: 13,
                        color: _mutedText,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const _FeatureBullet('Basic Dashboard'),
                    const _FeatureBullet('Text Chat with AI'),
                    const _FeatureBullet('Simple Journaling'),
                    const _FeatureBullet('Partner Connection'),
                    const _FeatureBullet('Basic Insights'),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 44,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_purple, _pink],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                      ),
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          'Current Plan',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Cuplix+ paid plan card
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFF3D792)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        const Text(
                          'Cuplix+',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: _primaryText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              '\$9',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                color: _primaryText,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Padding(
                              padding: EdgeInsets.only(bottom: 3),
                              child: Text(
                                '/month',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _mutedText,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 3),
                              child: Text(
                                _isAnnual ? '(billed annually)' : 'billed monthly',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: _mutedText,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Unlock all premium features',
                          style: TextStyle(
                            fontSize: 13,
                            color: _mutedText,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const _FeatureBullet('All Free Features'),
                        const _FeatureBullet('Voice Companion Therapy'),
                        const _FeatureBullet('Real-Time Conflict Mediation'),
                        const _FeatureBullet('Advanced Analytics'),
                        const _FeatureBullet('Sleep & Stress Tracking'),
                        const _FeatureBullet('Mood Music Therapy'),
                        const _FeatureBullet('Mirror Mode Simulation'),
                        const _FeatureBullet('Gift Marketplace'),
                        const _FeatureBullet('Priority Support'),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: handle upgrade tap
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF4B000),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Upgrade',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(Icons.arrow_forward,
                                    size: 18, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: -14,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _gold,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Text(
                          'MOST POPULAR',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Premium Features Included
              const Text(
                'Premium Features Included',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _primaryText,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE7DFF0)),
                ),
                child: Column(
                  children: const [
                    _PremiumRow(
                      icon: Icons.headphones,
                      title: 'Voice Companion Therapy',
                      subtitle:
                      '24/7 AI relationship therapist with voice interaction',
                    ),
                    SizedBox(height: 10),
                    _PremiumRow(
                      icon: Icons.bolt,
                      title: 'Real-Time Conflict Mediation',
                      subtitle:
                      'Live intervention during heated discussions',
                    ),
                    SizedBox(height: 10),
                    _PremiumRow(
                      icon: Icons.insights,
                      title: 'Advanced Analytics',
                      subtitle:
                      'Deep emotional interaction visualization',
                    ),
                    SizedBox(height: 10),
                    _PremiumRow(
                      icon: Icons.auto_awesome,
                      title: 'Mirror Mode',
                      subtitle:
                      "Practice conversations with your partner's AI twin",
                    ),
                    SizedBox(height: 10),
                    _PremiumRow(
                      icon: Icons.card_giftcard,
                      title: 'Gift Marketplace',
                      subtitle:
                      'AI-recommended gifts and experiences',
                    ),
                    SizedBox(height: 10),
                    _PremiumRow(
                      icon: Icons.favorite_outline,
                      title: 'Priority Support',
                      subtitle:
                      'Faster response times and dedicated assistance',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Money back guarantee
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE7DFF0)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.shield_outlined,
                        color: _purple, size: 32),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '30-Day Money-Back Guarantee',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: _primaryText,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Not satisfied? Get a full refund within 30 days of your purchase. No questions asked.',
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              color: _mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small purple gradient pill button used in Free Trial card
class _GradientPillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _GradientPillButton({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFaf57db), Color(0xFFe46791)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Bullet with check-mark used in plan feature lists
class _FeatureBullet extends StatelessWidget {
  final String text;

  const _FeatureBullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_rounded,
              size: 18, color: Color(0xFFaf57db)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4B3C5D),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Row for premium features section
class _PremiumRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _PremiumRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 38,
          width: 38,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF6E7FF), Color(0xFFD096FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: Colors.white),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF241B35),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: Color(0xFF9A8EA0),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
