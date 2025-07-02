import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/storage_services.dart';
import 'edit_note.dart';
import 'note_detail.dart'; // ✅ Import ajouté

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService storage = StorageService();
  late Future<List<Note>> notesFuture;

  @override
  void initState() {
    super.initState();
    notesFuture = storage.getAllNotes();
  }

  void refreshNotes() {
    setState(() {
      notesFuture = storage.getAllNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes notes')),
      body: FutureBuilder<List<Note>>(
        future: notesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune note pour le moment.'));
          }

          final notes = snapshot.data!;

          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return ListTile(
                title: Text(note.title),
                subtitle: Text(
                  note.content.length > 50
                      ? '${note.content.substring(0, 50)}...'
                      : note.content,
                ),
                trailing: Text(
                  '${note.createdAt.day}/${note.createdAt.month}/${note.createdAt.year}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onTap: () async {
                  final noteWasDeleted = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) => NoteDetailScreen(
                            note: note,
                          ), // ✅ Aller vers NoteDetail
                    ),
                  );

                  if (noteWasDeleted == true) {
                    refreshNotes(); // ✅ Rafraîchir la liste si la note a été supprimée
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const EditNoteScreen()));
          refreshNotes();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
