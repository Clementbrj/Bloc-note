import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/note.dart';

class SupabaseStorageService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<Note>> getAllNotes() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final response = await supabase
        .from('notes')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return response.map<Note>((row) => Note.fromMap(row)).toList();
  }

  Future<void> addNote(Note note) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase.from('notes').insert({
      'user_id': user.id,
      'title': note.title,
      'content': note.content,
      'created_at': note.createdAt.toIso8601String(),
    });
  }

  Future<void> deleteNote(String id) async {
    await supabase.from('notes').delete().eq('id', id);
  }

  Future<void> updateNote(Note note) async {
    await supabase.from('notes').update({
      'title': note.title,
      'content': note.content,
    }).eq('id', note.id);
  }
}
