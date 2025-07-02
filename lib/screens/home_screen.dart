import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw; // <-- Import pdf
import 'package:pdf/pdf.dart'; // <-- Pour PdfColors

import '../models/note.dart';
import '../services/storage_services.dart';
import 'edit_note.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService storage = StorageService();
  late Future<List<Note>> notesFuture;

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
    notesFuture = storage.getAllNotes();
  }

  void refreshNotes() {
    setState(() {
      if (_selectedCategory == 'All') {
        notesFuture = storage.getAllNotes();
      } else {
        notesFuture = storage.getAllNotes(category: _selectedCategory);
      }
    });
  }

  Future<void> shareNoteText(Note note) async {
    final formattedDate =
        '${note.createdAt.day.toString().padLeft(2, '0')}/${note.createdAt.month.toString().padLeft(2, '0')}/${note.createdAt.year}';

    final content = '''
Titre : ${note.title}
Catégorie : ${note.category}
Date : $formattedDate

${note.content}
''';

    await Share.share(content, subject: note.title);
  }

  Future<void> downloadNote(Note note) async {
    try {
      final pdf = pw.Document();

      final formattedDate =
          '${note.createdAt.day.toString().padLeft(2, '0')}/${note.createdAt.month.toString().padLeft(2, '0')}/${note.createdAt.year}';

      // Construction du contenu PDF
      pdf.addPage(
        pw.Page(
          build:
              (context) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Titre : ${note.title}',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Catégorie : ${note.category}',
                    style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
                  ),
                  pw.Text(
                    'Date : $formattedDate',
                    style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
                  ),
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

      // Sauvegarde le PDF en bytes
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Note téléchargée :\n $filePath')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du téléchargement : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes notes'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedCategory,
              items:
                  categoriesFilter.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
                  }).toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedCategory = value;
                  refreshNotes();
                });
              },
            ),
          ),
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

          final notes = snapshot.data!;

          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: Text(note.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.content.length > 50
                            ? '${note.content.substring(0, 50)}...'
                            : note.content,
                      ),
                      Text(
                        'Catégorie : ${note.category}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey,
                        ),
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
                          '${note.createdAt.day}/${note.createdAt.month}/${note.createdAt.year}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
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
                      MaterialPageRoute(
                        builder: (_) => EditNoteScreen(note: note),
                      ),
                    );
                    if (noteWasUpdated == true) {
                      refreshNotes();
                    }
                  },
                ),
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
