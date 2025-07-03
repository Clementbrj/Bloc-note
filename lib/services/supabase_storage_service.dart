import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/note.dart';

class SupabaseStorageService {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Récupère toutes les notes de l'utilisateur, avec un filtre optionnel par catégorie.
  Future<List<Note>> getAllNotes({String? category}) async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    PostgrestFilterBuilder query;

    // Appliquer un filtre sur la catégorie si spécifiée et différente de 'All'
    if (category != null && category != 'All') {
      query = supabase
          .from('notes')
          .select()
          .eq('user_id', user.id)
          .eq('category', category);
    } else {
      // Sinon, récupérer toutes les notes de l'utilisateur
      query = supabase
          .from('notes')
          .select()
          .eq('user_id', user.id);
    }

    // Trier les notes par date de création décroissante
    final response = await query.order('created_at', ascending: false);

    // Convertir la liste de maps en liste d'objets Note
    return response.map<Note>((row) => Note.fromMap(row)).toList();
  }

  /// Ajoute une nouvelle note pour l'utilisateur connecté.
  Future<void> addNote(Note note) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase.from('notes').insert({
      'user_id': user.id,
      'title': note.title,
      'content': note.content,
      'category': note.category,
      'created_at': note.createdAt.toIso8601String(),
    });
  }

  /// Supprime une note via son identifiant.
  Future<void> deleteNote(String id) async {
    await supabase.from('notes').delete().eq('id', id);
  }

  /// Met à jour une note existante.
  Future<void> updateNote(Note note) async {
    await supabase.from('notes').update({
      'title': note.title,
      'content': note.content,
      'category': note.category,
    }).eq('id', note.id);
  }
}
