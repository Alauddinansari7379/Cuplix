// lib/sensor/sensor_tracking_screen.dart
import 'package:flutter/material.dart';

class SensorTrackingScreen extends StatefulWidget {
  const SensorTrackingScreen({Key? key}) : super(key: key);

  @override
  State<SensorTrackingScreen> createState() => _SensorTrackingScreenState();
}

class _SensorTrackingScreenState extends State<SensorTrackingScreen> {
  bool _trackingActive = true;
  double _stressLevel = 0.47; // 47%

  @override
  Widget build(BuildContext context) {
    const primaryText = Color(0xFF2C2139);
    const mutedText = Color(0xFF9A8EA0);
    const bgColor = Color(0xFFFBF8FB);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          'Sensor Tracking',
          style: TextStyle(
            color: primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Real-time emotional and conflict detection',
                style: TextStyle(color: mutedText),
              ),
              const SizedBox(height: 18),

              // -------- Tracking Status --------
              _roundedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.show_chart,
                            color: Color(0xFFaf57db)),
                        const SizedBox(width: 8),
                        const Text(
                          'Tracking Status',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryText,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4EFFA),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _trackingActive = !_trackingActive;
                              });
                            },
                            icon: const Icon(Icons.pause_rounded,
                                size: 18, color: primaryText),
                            label: Text(
                              _trackingActive ? 'Pause' : 'Resume',
                              style: const TextStyle(
                                color: primaryText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _trackingActive
                          ? 'Actively monitoring'
                          : 'Tracking paused',
                      style: const TextStyle(color: mutedText),
                    ),
                    const SizedBox(height: 16),

                    // three tiles
                    _sensorTile(
                      icon: Icons.mic_none_rounded,
                      title: 'Voice Analysis',
                      status: _trackingActive ? 'Active' : 'Paused',
                    ),
                    const SizedBox(height: 12),
                    _sensorTile(
                      icon: Icons.monitor_heart_outlined,
                      title: 'Movement Tracking',
                      status: _trackingActive ? 'Active' : 'Paused',
                    ),
                    const SizedBox(height: 12),
                    _sensorTile(
                      icon: Icons.location_on_outlined,
                      title: 'Location Context',
                      status: _trackingActive ? 'Active' : 'Paused',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // -------- Emotional State Monitoring --------
              _roundedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Emotional State Monitoring',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Current Stress Level'),
                        Text(
                          '${(_stressLevel * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: primaryText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: SizedBox(
                        height: 10,
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.purple.shade400,
                                    Colors.purple.shade400,
                                    Colors.amber.shade400,
                                  ],
                                ),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: 1 - _stressLevel,
                              alignment: Alignment.centerRight,
                              child: Container(
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Low'),
                        Text('Medium'),
                        Text('High'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        _rangeChip(
                          label: '0-40%\nCalm',
                          color: const Color(0xFFE7FFF3),
                        ),
                        const SizedBox(width: 8),
                        _rangeChip(
                          label: '41-70%\nModerate',
                          color: const Color(0xFFFFF7E5),
                        ),
                        const SizedBox(width: 8),
                        _rangeChip(
                          label: '71-100%\nHigh',
                          color: const Color(0xFFFFE7E9),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // -------- Recent Conflicts --------
              _roundedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Recent Conflicts',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryText,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No recent conflicts detected',
                      style: TextStyle(color: mutedText),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // -------- AI Insights --------
              _roundedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'AI Insights',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryText,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Your conflict resolution time has improved by 25% this month. Keep up the great work!',
                      style: TextStyle(color: mutedText, height: 1.4),
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

  // small sensor tile (Voice / Movement / Location)
  Widget _sensorTile({
    required IconData icon,
    required String title,
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFF1E5FF),
            child: Icon(icon, color: const Color(0xFFaf57db)),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                status,
                style: const TextStyle(
                  color: Color(0xFF9A8EA0),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // range chips (Calm / Moderate / High)
  Widget _rangeChip({required String label, required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }
}

// Reusable rounded card (same pattern as profile screen)
Widget _roundedCard({required Widget child}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFEEE6F0)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );
}
