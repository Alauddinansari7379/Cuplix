class JournalEntry {
  final String id;
  final String userId;
  final String content;
  final String mood;
  final String? imageUrl;
  final DateTime createdAt;

  JournalEntry({
    required this.id,
    required this.userId,
    required this.content,
    required this.mood,
    this.imageUrl,
    required this.createdAt,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> j) {
    return JournalEntry(
      id: j['id']?.toString() ?? '',
      userId: j['userId']?.toString() ?? '',
      content: j['content']?.toString() ?? '',
      mood: j['mood']?.toString() ?? '',
      imageUrl: (j['imageUrl'] == null || j['imageUrl'].toString().isEmpty) ? null : j['imageUrl'].toString(),
      createdAt: DateTime.tryParse(j['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
//Aluddin
//Somenath