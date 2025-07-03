import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import '../models/note.dart';
import '../services/storage_services.dart';
import '../services/supabase_storage_service.dart';
import 'edit_note.dart';
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

  static const List<String> categoriesFilter = [
    'All',
    'Low',
    'Medium',
    'High',
    'Very High',
    'Hard',
    'New Age',
  ];

  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    user = supabase.auth.currentUser;
    _loadNotes();
  }

  void _loadNotes() {
    notesFuture = (_selectedCategory == 'All')
        ? storage.getAllNotes()
        : storage.getAllNotes(category: _selectedCategory);
  }

  void refreshNotes() => setState(_loadNotes);

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  Future<void> shareNoteText(Note note) async {
    final content = '''
Titre : ${note.title}
Catégorie : ${note.category}
Date : ${_formatDate(note.createdAt)}

${note.content}
''';
    await Share.share(content, subject: note.title);
  }

  Future<void> downloadNote(Note note) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Titre : ${note.title}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text('Catégorie : ${note.category}', style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
              pw.Text('Date : ${_formatDate(note.createdAt)}', style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text(note.content, style: pw.TextStyle(fontSize: 12)),
            ],
          ),
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final safeFileName = note.title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      final filePath = '${dir.path}/$safeFileName.pdf';
      final file = File(filePath);

      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Note téléchargée :\n$filePath')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors du téléchargement : $e')));
    }
  }

  Future<void> _handleAuthAction() async {
    if (user != null) {
      await supabase.auth.signOut();
      setState(() => user = null);
    }
    Navigator.of(context).pushReplacementNamed('/login');
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButton<String>(
        isExpanded: true,
        value: _selectedCategory,
        items: categoriesFilter.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
        onChanged: (value) {
          if (value == null) return;
          setState(() {
            _selectedCategory = value;
            refreshNotes();
          });
        },
      ),
    );
  }

  Widget _buildNoteCard(Note note) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListTile(
        title: Text(note.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.content.length > 50 ? '${note.content.substring(0, 50)}...' : note.content,
            ),
            Text(
              'Catégorie : ${note.category}',
              style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
            ),
          ],
        ),
        trailing: SizedBox(
          width: 120,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatDate(note.createdAt),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                children: [
                  IconButton(
                    icon: const Icon(Icons.share),
                    tooltip: 'Partager la note',
                    onPressed: () => shareNoteText(note),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                  IconButton(
                    icon: const Icon(Icons.download),
                    tooltip: 'Télécharger la note',
                    onPressed: () => downloadNote(note),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ),
        ),
        onTap: () async {
          final noteWasUpdated = await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => EditNoteScreen(note: note)),
          );
          if (noteWasUpdated == true) refreshNotes();
        },
      ),
    );
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
            onPressed: _handleAuthAction,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: _buildDropdown(),
        ),
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

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) => _buildNoteCard(snapshot.data![index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditNoteScreen()));
          refreshNotes();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
