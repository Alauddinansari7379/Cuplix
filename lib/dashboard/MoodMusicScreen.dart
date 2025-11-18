// lib/mood/MoodMusicScreen.dart
import 'package:flutter/material.dart';

class MoodMusicScreen extends StatefulWidget {
  const MoodMusicScreen({Key? key}) : super(key: key);

  @override
  State<MoodMusicScreen> createState() => _MoodMusicScreenState();
}

class _MoodMusicScreenState extends State<MoodMusicScreen> {
  double _currentPosition = 105; // 1:45 of 4:32 (dummy)
  double _totalDuration = 272; // seconds
  double _volume = 0.7;
  bool _isPlaying = true;

  @override
  Widget build(BuildContext context) {
    const primaryText = Color(0xFF2C2139);
    const mutedText = Color(0xFF9A8EA0);

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFFDF8FF),
        foregroundColor: Colors.black,
        title: const Text(
          'AI Mood Music',
          style: TextStyle(
            color: primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Personalized playlists for emotional healing and connection',
                style: TextStyle(color: mutedText),
              ),
              const SizedBox(height: 16),

              // NOW PLAYING CARD
              _roundedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: const [
                        Icon(Icons.favorite_border,
                            color: Color(0xFFaf57db)),
                        SizedBox(width: 8),
                        Text(
                          'Now Playing',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: primaryText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Artwork + text
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 96,
                          width: 96,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFF8E9FF),
                                Color(0xFFFDE3F2),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Icon(Icons.music_note,
                              size: 40, color: Color(0xFFaf57db)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Gentle Waves',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: primaryText,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Ambient Harmony',
                                style: TextStyle(color: mutedText),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Progress label row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatTime(_currentPosition.toInt()),
                          style: const TextStyle(color: mutedText),
                        ),
                        Text(
                          _formatTime(_totalDuration.toInt()),
                          style: const TextStyle(color: mutedText),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Progress slider
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 5,
                        inactiveTrackColor: const Color(0xFFF0E6F7),
                        activeTrackColor: const Color(0xFFf06292),
                        thumbColor: const Color(0xFFaf57db),
                      ),
                      child: Slider(
                        min: 0,
                        max: _totalDuration,
                        value: _currentPosition.clamp(0, _totalDuration),
                        onChanged: (v) {
                          setState(() => _currentPosition = v);
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Controls row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _circleIconButton(
                          icon: Icons.bolt,
                          onTap: () {},
                        ),
                        _circleMainButton(
                          icon: _isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          onTap: () {
                            setState(() => _isPlaying = !_isPlaying);
                          },
                        ),
                        _circleIconButton(
                          icon: Icons.people_outline,
                          onTap: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Volume slider
                    const Text(
                      'Volume',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: primaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.volume_up,
                            size: 18, color: mutedText),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 5,
                              inactiveTrackColor: Color(0xFFF0E6F7),
                              activeTrackColor: Color(0xFFaf57db),
                              thumbColor: Color(0xFFaf57db),
                            ),
                            child: Slider(
                              min: 0,
                              max: 1,
                              value: _volume,
                              onChanged: (v) {
                                setState(() => _volume = v);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // RECOMMENDED PLAYLISTS
              const _SectionTitle(
                icon: Icons.bolt,
                title: 'Recommended for Your Mood',
              ),
              const SizedBox(height: 12),
              _playlistTile(
                title: 'Reconnection Evening',
                description:
                'Gentle melodies to rebuild emotional closeness',
                duration: '35 min',
                tracks: '8 tracks',
                highlighted: true,
              ),
              const SizedBox(height: 10),
              _playlistTile(
                title: 'Post-Argument Calm',
                description:
                'Soothing sounds to reduce tension and stress',
                duration: '28 min',
                tracks: '6 tracks',
              ),
              const SizedBox(height: 10),
              _playlistTile(
                title: 'Intimacy Moments',
                description:
                'Romantic ambient music for special connection',
                duration: '42 min',
                tracks: '10 tracks',
              ),
              const SizedBox(height: 10),
              _playlistTile(
                title: 'Deep Focus',
                description:
                'Concentration-enhancing ambient sounds',
                duration: '50 min',
                tracks: '12 tracks',
              ),

              const SizedBox(height: 22),

              // MOOD-BASED SUGGESTIONS
              const _SectionTitle(
                icon: Icons.nightlight_round,
                title: 'Mood-Based Suggestions',
              ),
              const SizedBox(height: 12),
              _moodSuggestion(
                icon: Icons.nightlight_round,
                title: 'Stressful Day',
                subtitle: "Try the 'Calm Down' playlist",
              ),
              const SizedBox(height: 10),
              _moodSuggestion(
                icon: Icons.favorite_border,
                title: 'Feeling Distant',
                subtitle: "Play 'Reconnection Evening'",
              ),
              const SizedBox(height: 10),
              _moodSuggestion(
                icon: Icons.music_note,
                title: 'Romantic Moment',
                subtitle: "Listen to 'Intimacy Moments'",
              ),

              const SizedBox(height: 18),

              // CONNECT TO SPOTIFY BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                  ).copyWith(
                    backgroundColor: MaterialStateProperty.resolveWith(
                          (states) => null,
                    ),
                    shadowColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFb640ef), Color(0xFFe46791)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: const Text(
                        'Connect to Spotify',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  // ----- helpers -----

  static String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(1, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F3FF),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Icon(icon, color: const Color(0xFFaf57db)),
      ),
    );
  }

  Widget _circleMainButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Container(
        height: 60,
        width: 60,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFFb640ef), Color(0xFFe46791)],
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 32),
      ),
    );
  }
}

// --------- small reusable widgets ----------

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    const primaryText = Color(0xFF2C2139);
    return Row(
      children: [
        Container(
          height: 32,
          width: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFF6E8FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFFaf57db), size: 18),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryText,
          ),
        ),
      ],
    );
  }
}

Widget _playlistTile({
  required String title,
  required String description,
  required String duration,
  required String tracks,
  bool highlighted = false,
}) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: highlighted ? const Color(0xFFF8F3FF) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: highlighted ? const Color(0xFFd9b4ff) : const Color(0xFFEDE5F5),
      ),
    ),
    child: Row(
      children: [
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              colors: [Color(0xFFF8E9FF), Color(0xFFFDE3F2)],
            ),
          ),
          child: const Icon(Icons.music_note, color: Color(0xFFaf57db)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF2C2139),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(color: Color(0xFF9A8EA0)),
              ),
              const SizedBox(height: 4),
              Text(
                '$duration   •   $tracks',
                style: const TextStyle(
                  color: Color(0xFFB5A8C5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _moodSuggestion({
  required IconData icon,
  required String title,
  required String subtitle,
}) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFEDE5F5)),
    ),
    child: Row(
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF5E9FF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: const Color(0xFFaf57db)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C2139),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFF9A8EA0)),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _roundedCard({required Widget child}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
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
