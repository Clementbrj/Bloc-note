import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/storage_services.dart';

class NoteDetailScreen extends StatelessWidget {
  final Note note;
  final StorageService storage = StorageService();

  NoteDetailScreen({super.key, required this.note});

  Future<void> _deleteNote(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: const Text('Voulez-vous vraiment supprimer cette note ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Supprimer'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await storage.deleteNote(note.id!);
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red), // ← un X rouge
            tooltip: 'Supprimer la note',
            onPressed: () => _deleteNote(context),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(note.content),
      ),
    );
  }
}
