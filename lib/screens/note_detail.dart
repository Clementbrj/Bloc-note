import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/note.dart';
import '../services/storage_services.dart';
import '../services/supabase_storage_service.dart'; 

class NoteDetailScreen extends StatelessWidget {
  final Note note;
  final SupabaseStorageService storage = SupabaseStorageService();

  NoteDetailScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(note.title)), // Affiche le titre de la note dans la barre d'app
      body: Padding(
        padding: const EdgeInsets.all(16),  // Ajoute un padding autour du contenu
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Aligne le contenu à gauche
          children: [
            Text(
              'Catégorie: ${note.category}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Créé le : ${note.createdAt.toLocal().toString().split(' ')[0]}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16), // Espace avant le contenu markdown
            Expanded(child: Markdown(data: note.content, selectable: true)),
          ],
        ),
      ),
    );
  }
}
