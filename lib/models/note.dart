class Note {
  final String? id;  // Identifiant unique
  final String title; // Titre de la note
  final String content; // Contenu de la note
  final DateTime createdAt; // Date de création
  final String category; // Catégorie de la note

// Constructeur
  Note({
    this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.category,
  });

 // Convertit l'objet en Map
  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'category': category,
  };

  // Crée un objet Note à partir d'une Map
  factory Note.fromMap(Map<String, dynamic> map) => Note(
      id: map['id'] as String?,
      title: map['title'] as String,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      category: map['category'] ?? '',
  );

  // Catégories autorisées
  static const List<String> allowedCategories = [
    'Low',
    'Medium',
    'High',
    'Very High',
    'Hard',
    'New Age',
    'Sans catégorie',
  ];
}
