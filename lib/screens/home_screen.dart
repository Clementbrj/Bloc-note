import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/storage_services.dart';
import 'edit_note.dart';
import 'note_detail.dart'; // ✅ Import ajouté
import '../services/supabase_storage_service.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
final storage = SupabaseStorageService();
 final supabase = Supabase.instance.client; 
  late Future<List<Note>> notesFuture;
    User? user;

  @override
  void initState() {
    super.initState();
    notesFuture = storage.getAllNotes();
        user = supabase.auth.currentUser;
  }

  void refreshNotes() {
    setState(() {
      notesFuture = storage.getAllNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      
      appBar: AppBar(
  title: const Text('Mes notes'),
  actions: [
 IconButton(
            icon: Icon(user != null ? Icons.logout : Icons.login),
            tooltip: user != null ? 'Se déconnecter' : 'Se connecter',
            onPressed: () async {
              if (user != null) {
                await supabase.auth.signOut();
                setState(() {
                  user = null;
                });
                Navigator.of(context).pushReplacementNamed('/login');
              } else {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
  ],
),
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
                          ), 
                    ),
                  );

                  if (noteWasDeleted == true) {
                    refreshNotes(); 
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
