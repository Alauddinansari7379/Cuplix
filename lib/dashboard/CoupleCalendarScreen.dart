import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CoupleCalendarScreen extends StatefulWidget {
  const CoupleCalendarScreen({Key? key}) : super(key: key);

  @override
  State<CoupleCalendarScreen> createState() => _CoupleCalendarScreenState();
}

class _CoupleCalendarScreenState extends State<CoupleCalendarScreen> {
  DateTime _focusedMonth = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  // simple local events & suggestions
  final Map<DateTime, String> _events = {};
  final List<String> _aiSuggestions = const [
    "Friday looks light — maybe plan a dinner?",
    "You've both had stressful weeks — book a short outing.",
    "Alex's energy is high this weekend — perfect for adventure!",
    "Consider a quiet evening together on Wednesday.",
  ];

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    final key = DateTime(today.year, today.month, today.day);
    _events[key] = "New Event";
  }

  // utility to strip time
  DateTime _dateKey(DateTime d) => DateTime(d.year, d.month, d.day);

  void _goToPreviousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  List<DateTime> _buildDaysForMonth(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final firstWeekday = first.weekday; // 1 (Mon)..7 (Sun)
    // we want Sunday at column 0, so compute offset
    final int leadingEmpty = (firstWeekday % 7); // Sun => 0, Mon => 1, ...

    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final List<DateTime> days = [];
    // prepend previous month days just to keep grid shape (but we'll render blanks)
    for (int i = 0; i < leadingEmpty; i++) {
      days.add(first.subtract(Duration(days: leadingEmpty - i)));
    }
    for (int i = 0; i < daysInMonth; i++) {
      days.add(DateTime(month.year, month.month, i + 1));
    }
    // pad to full weeks of 7 cells
    while (days.length % 7 != 0) {
      days.add(days.last.add(const Duration(days: 1)));
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF8F3FF);
    const cardBg = Colors.white;
    const purple = Color(0xFF7B3AED);

    final width = MediaQuery.of(context).size.width;
    final isWide = width > 600;
    final monthLabel = DateFormat('MMMM yyyy').format(_focusedMonth);

    final days = _buildDaysForMonth(_focusedMonth);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          'AI Couple Calendar',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (icon + title)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: const Icon(
                        Icons.calendar_month,
                        color: purple,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'AI Couple Calendar',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF24123A),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Anticipatory relationship management',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF8B7E99),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Calendar card
                Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // month header + buttons (NO overflow now)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            monthLabel,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF24123A),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // horizontal scroll so it never overflows
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _smallOutlinedButton(
                                    'Previous', _goToPreviousMonth),
                                const SizedBox(width: 8),
                                _smallOutlinedButton('Next', _goToNextMonth),
                                const SizedBox(width: 8),
                                _smallFilledButton('+  Add Event', () {
                                  final key = _dateKey(_selectedDay);
                                  setState(() {
                                    _events[key] = 'New Event';
                                  });
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Days-of-week row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          _DowLabel('Sun'),
                          _DowLabel('Mon'),
                          _DowLabel('Tue'),
                          _DowLabel('Wed'),
                          _DowLabel('Thu'),
                          _DowLabel('Fri'),
                          _DowLabel('Sat'),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Calendar grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: days.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: 6,
                          crossAxisSpacing: 6,
                          childAspectRatio: isWide ? 1 : 0.95,
                        ),
                        itemBuilder: (context, index) {
                          final day = days[index];
                          final inCurrentMonth =
                              day.month == _focusedMonth.month &&
                                  day.year == _focusedMonth.year;
                          final isSelected =
                              _dateKey(day) == _dateKey(_selectedDay);
                          final hasEvent =
                          _events.containsKey(_dateKey(day));

                          if (!inCurrentMonth) {
                            // render blank cell to keep grid shape
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.transparent,
                              ),
                            );
                          }

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDay = day;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: isSelected
                                    ? const Color(0xFFF2E9FF)
                                    : const Color(0xFFF9F7FD),
                                border: Border.all(
                                  color: isSelected
                                      ? purple
                                      : const Color(0xFFE3DAF3),
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Text(
                                      '${day.day}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? purple
                                            : const Color(0xFF48305C),
                                      ),
                                    ),
                                  ),
                                  if (hasEvent)
                                    Positioned(
                                      right: 6,
                                      top: 6,
                                      child: Container(
                                        height: 6,
                                        width: 6,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: purple,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Selected day card
                _selectedDayCard(),

                const SizedBox(height: 18),

                // AI Suggestions
                _aiSuggestionsCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _selectedDayCard() {
    const purple = Color(0xFF7B3AED);
    const lightBlue = Color(0xFFE0EDFF);
    final title = DateFormat('EEEE, MMMM d').format(_selectedDay);
    final key = _dateKey(_selectedDay);
    final eventTitle = _events[key] ?? 'New Event';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time, color: purple),
              const SizedBox(width: 8),
              Text(
                title,
                style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: lightBlue,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.sentiment_satisfied_alt,
                      color: purple),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eventTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF24123A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Date',
                      style: TextStyle(color: Color(0xFF8B7E99), fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _aiSuggestionsCard() {
    const purple = Color(0xFF7B3AED);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: const [
              Icon(Icons.bolt, color: purple),
              SizedBox(width: 8),
              Text(
                'AI Suggestions',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._aiSuggestions.map(
                (s) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFBEFFF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE4C6FF)),
              ),
              child: Row(
                children: [
                  Container(
                    height: 28,
                    width: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                    const Icon(Icons.favorite, size: 16, color: purple),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      s,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF4A355C),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 46,
            child: ElevatedButton(
              onPressed: () {
                // TODO: integrate with real calendar later
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Event added to calendar (demo)'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                elevation: 0,
                foregroundColor: Colors.white,
                backgroundColor: Colors.transparent,
              ).copyWith(
                backgroundColor: MaterialStateProperty.resolveWith(
                      (states) => null,
                ),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFBA49F3), Color(0xFFF06292)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: const Text(
                    'Add to Calendar',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// tiny widgets for header/buttons

class _DowLabel extends StatelessWidget {
  final String text;
  const _DowLabel(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9A8EA8),
          ),
        ),
      ),
    );
  }
}

Widget _smallOutlinedButton(String label, VoidCallback onTap) {
  return OutlinedButton(
    onPressed: onTap,
    style: OutlinedButton.styleFrom(
      side: const BorderSide(color: Color(0xFFE0D3F5)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    child: Text(
      label,
      style: const TextStyle(fontSize: 12, color: Color(0xFF4B2E75)),
    ),
  );
}

Widget _smallFilledButton(String label, VoidCallback onTap) {
  return ElevatedButton(
    onPressed: onTap,
    style: ElevatedButton.styleFrom(
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      backgroundColor: const Color(0xFF7B3AED),
      foregroundColor: Colors.white,
    ),
    child: Text(
      label,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    ),
  );
}
