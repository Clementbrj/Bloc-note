class Note {
  final String?
  id; // Identifiant unique (UUID pour Supabase ou int pour SQLite)
  final String userId; // ID de l'utilisateur (nécessaire pour Supabase)
  final String title; // Titre de la note
  final String content; // Contenu de la note
  final DateTime createdAt; // Date de création de la note
  final String category; // Catégorie de la note

  // Constructeur
  Note({
    this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.category,
  });

  /// Convertit une Note en Map pour l'enregistrement dans la base de données
  Map<String, dynamic> toMap() => {
    'id': id,
    'user_id': userId,
    'title': title,
    'content': content,
    'created_at': createdAt.toIso8601String(),
    'category': category,
  };

  /// Crée une instance de Note à partir d'une Map (depuis Supabase ou SQLite)
  factory Note.fromMap(Map<String, dynamic> map) => Note(
    id: map['id']?.toString(),
    userId: map['user_id']?.toString() ?? '', // vide si SQLite local
    title: map['title'] ?? '',
    content: map['content'] ?? '',
    createdAt: DateTime.parse(
      map['created_at'] ?? map['createdAt'],
    ), // SQLite vs Supabase
    category: map['category'] ?? 'Sans catégorie',
  );

  /// Liste des catégories disponibles
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
