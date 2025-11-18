import 'package:flutter/material.dart';

class SleepStressScreen extends StatelessWidget {
  const SleepStressScreen({Key? key}) : super(key: key);

  static const Color _primary = Color(0xFF2C2139);
  static const Color _muted = Color(0xFF9A8EA0);

  @override
  Widget build(BuildContext context) {
    const gradient = LinearGradient(
      colors: [Color(0xFFaf57db), Color(0xFFe46791)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Biological Harmony',
          style: TextStyle(
            color: _primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Track sleep, stress, and emotional wellness',
                style: TextStyle(color: _muted),
              ),
              const SizedBox(height: 18),

              // ---------- Sleep Quality ----------
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.nights_stay_outlined,
                            color: Color(0xFFaf57db)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Sleep Quality',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: _primary,
                            ),
                          ),
                        ),
                        Text('Last night',
                            style: TextStyle(color: _muted, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Duration
                    _metricRow(
                      label: 'Duration',
                      value: '7.2 hrs',
                    ),
                    const SizedBox(height: 8),
                    _gradientBar(value: 0.9),
                    const SizedBox(height: 18),

                    // Quality
                    _metricRow(
                      label: 'Quality',
                      value: '85%',
                    ),
                    const SizedBox(height: 8),
                    _gradientBar(value: 0.85),
                    const SizedBox(height: 18),

                    const _miniMetric(label: 'Deep Sleep', value: '2.1 hrs'),
                    const SizedBox(height: 6),
                    const _miniMetric(label: 'REM Sleep', value: '1.8 hrs'),
                    const SizedBox(height: 6),
                    const _miniMetric(label: 'Weekly Avg', value: '6.8 hrs'),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ---------- Stress & HRV ----------
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.multiline_chart,
                            color: Color(0xFFaf57db)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Stress & HRV',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: _primary,
                            ),
                          ),
                        ),
                        Text('Today',
                            style: TextStyle(color: _muted, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Stress level
                    _metricRow(label: 'Stress Level', value: '42%'),
                    const SizedBox(height: 8),
                    _gradientBar(value: 0.42),
                    const SizedBox(height: 4),
                    const _axisLabels(left: 'Low', center: 'Medium', right: 'High'),
                    const SizedBox(height: 18),

                    // HRV
                    _metricRow(label: 'Heart Rate Variability', value: '65 ms'),
                    const SizedBox(height: 8),
                    _gradientBar(value: 0.65),
                    const SizedBox(height: 4),
                    const _axisLabels(left: 'Low', center: 'Optimal', right: 'High'),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ---------- Partner Insights ----------
              const Text(
                'Partner Insights',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _primary,
                ),
              ),
              const SizedBox(height: 12),
              _card(
                child: Column(
                  children: const [
                    _partnerInsightTile(
                      title: "Alex's Sleep Quality",
                      subtitle: 'Last night',
                      value: '72%',
                      progress: 0.72,
                    ),
                    SizedBox(height: 12),
                    _partnerInsightTile(
                      title: "Alex's Stress Level",
                      subtitle: 'Today',
                      value: '55%',
                      progress: 0.55,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ---------- AI Recommendations ----------
              const Text(
                'AI Recommendations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _primary,
                ),
              ),
              const SizedBox(height: 12),
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _recommendationItem(
                      icon: Icons.warning_amber_rounded,
                      iconColor: Color(0xFFFF9A9A),
                      text:
                      "Your partner's been sleeping less — low rest can affect patience. Try to keep today light.",
                    ),
                    const SizedBox(height: 10),
                    const _recommendationItem(
                      icon: Icons.check_circle_outline,
                      iconColor: Color(0xFFaf57db),
                      text:
                      'Consider a 10-minute meditation together this evening to reduce stress levels.',
                    ),
                    const SizedBox(height: 10),
                    const _recommendationItem(
                      icon: Icons.check_circle_outline,
                      iconColor: Color(0xFFaf57db),
                      text:
                      'Your sleep quality improved 7% this week — great progress!',
                    ),
                    const SizedBox(height: 18),

                    // Connect wearable button
                    Container(
                      height: 48,
                      decoration: const BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          // handle connect wearable
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          'Connect Wearable Device',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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

  // ---------- reusable widgets ----------

  static Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFECE3F2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  static Widget _metricRow({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: _primary,
            )),
        Text(value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: _primary,
            )),
      ],
    );
  }

  static Widget _gradientBar({required double value}) {
    value = value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth * value;
          return Stack(
            children: [
              Container(
                height: 10,
                color: const Color(0xFFF0E3FF),
              ),
              Container(
                height: 10,
                width: width,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFaf57db), Color(0xFFE96A98)],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _miniMetric extends StatelessWidget {
  final String label;
  final String value;

  const _miniMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: Color(0xFF9A8EA0), fontSize: 13)),
        Text(value,
            style: const TextStyle(
                color: Color(0xFF2C2139),
                fontWeight: FontWeight.w600,
                fontSize: 13)),
      ],
    );
  }
}

class _axisLabels extends StatelessWidget {
  final String left;
  final String center;
  final String right;

  const _axisLabels({
    required this.left,
    required this.center,
    required this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(left, style: const TextStyle(color: Color(0xFF9A8EA0), fontSize: 11)),
        Text(center, style: const TextStyle(color: Color(0xFF9A8EA0), fontSize: 11)),
        Text(right, style: const TextStyle(color: Color(0xFF9A8EA0), fontSize: 11)),
      ],
    );
  }
}

class _partnerInsightTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final double progress;

  const _partnerInsightTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF8FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            color: Color(0xFF9A8EA0), fontSize: 12)),
                  ],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF2C2139)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SleepStressScreen._gradientBar(value: progress),
        ],
      ),
    );
  }
}

class _recommendationItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  const _recommendationItem({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF8FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Color(0xFF4C3D5A), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
