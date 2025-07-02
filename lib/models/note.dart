class Note {
  final int? id;
  final String title;
  final String content;
  final DateTime createdAt;
  final String category;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.category,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'category': category,
  };

  factory Note.fromMap(Map<String, dynamic> map) => Note(
    id: map['id'],
    title: map['title'],
    content: map['content'],
    createdAt: DateTime.parse(map['createdAt']),
    category: map['category'] ?? '',
  );

  static const List<String> allowedCategories = [
    'Low',
    'Medium',
    'High',
    'Very High',
    'Hard',
    'New Age',
    'Sans catégorie', // Ajoutée à la liste des catégories autorisées
  ];
}
