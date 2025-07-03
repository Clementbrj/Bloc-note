import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:faker/faker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import '../models/note.dart';
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
  String _searchQuery = ''; // champ de recherche
  int _currentPage = 0;
  static const int _notesPerPage = 10;
  List<Note> _currentNotes = [];
  Set<String> _selectedNoteIds = {};
  bool _selectAll = false;
  Timer? _pageDelay;

  @override
  void initState() {
    super.initState();
    user = supabase.auth.currentUser;
    _loadPage();
  }

  Future<void> _loadPage() async {
    List<Note> allNotes =
        _selectedCategory == 'All'
            ? await storage.getAllNotes()
            : await storage.getAllNotes(category: _selectedCategory);

    // filtre par recherche
    if (_searchQuery.isNotEmpty) {
      allNotes =
          allNotes
              .where(
                (note) =>
                    note.title.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    note.content.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
              )
              .toList();
    }

    final start = _currentPage * _notesPerPage;
    final end = (start + _notesPerPage).clamp(0, allNotes.length);

    setState(() {
      _currentNotes = allNotes.sublist(start, end);
      _selectedNoteIds.clear();
      _selectAll = false;
    });
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  Future<void> shareNoteText(Note note) async {
    final content =
        'Titre : ${note.title}\nCatégorie : ${note.category}\nDate : ${_formatDate(note.createdAt)}\n\n${note.content}';
    await Share.share(content, subject: note.title);
  }

  Future<void> downloadNote(Note note) async {
    final pdf = pw.Document();
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
                  'Date : ${_formatDate(note.createdAt)}',
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
    final file = File('${dir.path}/$safeFileName.pdf');
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Note téléchargée : ${file.path}')));
  }

  Future<void> _handleAuthAction() async {
    if (user != null) {
      await supabase.auth.signOut();
      setState(() => user = null);
    }
    Navigator.of(context).pushReplacementNamed('/login');
  }

  Future<void> _generateFakeNotes() async {
    final faker = Faker();
    final categories = categoriesFilter.where((c) => c != 'All').toList();
    for (int i = 0; i < 30; i++) {
      final note = Note(
        id: '',
        userId: user?.id ?? '',
        title: faker.lorem.sentence(),
        content: faker.lorem.sentences(5).join(' '),
        category: categories[faker.randomGenerator.integer(categories.length)],
        createdAt: DateTime.now().subtract(
          Duration(days: faker.randomGenerator.integer(365)),
        ),
      );
      await storage.addNote(note);
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('30 notes de test générées')));
    _currentPage = 0;
    await _loadPage();
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedCategory,
              items:
                  categoriesFilter
                      .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      )
                      .toList(),
              onChanged: (value) async {
                if (value == null) return;
                _selectedCategory = value;
                _currentPage = 0;
                await _loadPage();
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Rechercher...',
                isDense: true,
              ),
              onChanged: (value) async {
                _searchQuery = value;
                _currentPage = 0;
                await _loadPage();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(Note note) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: Checkbox(
          value: _selectedNoteIds.contains(note.id),
          onChanged: (checked) {
            setState(() {
              checked!
                  ? _selectedNoteIds.add(note.id!)
                  : _selectedNoteIds.remove(note.id!);
              _selectAll = _selectedNoteIds.length == _currentNotes.length;
            });
          },
        ),
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
              style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
            ),
          ],
        ),
        trailing: Wrap(
          spacing: 4,
          children: [
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Partager',
              onPressed: () => shareNoteText(note),
            ),
            IconButton(
              icon: const Icon(Icons.download),
              tooltip: 'Télécharger',
              onPressed: () => downloadNote(note),
            ),
          ],
        ),
        onTap: () async {
          final updated = await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => EditNoteScreen(note: note)));
          if (updated == true) await _loadPage();
        },
      ),
    );
  }

  Future<void> _confirmDeleteSelected() async {
    final count = _selectedNoteIds.length;
    if (count == 0) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Supprimer $count note${count > 1 ? 's' : ''} ?'),
            content: Text('Cette action est irréversible.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Supprimer'),
              ),
            ],
          ),
    );
    if (confirm == true) {
      for (final id in _selectedNoteIds) {
        await storage.deleteNote(id);
      }
      _selectedNoteIds.clear();
      await _loadPage();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$count note${count > 1 ? 's' : ''} supprimée${count > 1 ? 's' : ''}',
          ),
        ),
      );
    }
  }

  Widget _buildPaginationControls(int totalNotes) {
    final totalPages = (totalNotes / _notesPerPage).ceil();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed:
              _currentPage > 0
                  ? () async {
                    _pageDelay?.cancel();
                    _pageDelay = Timer(const Duration(seconds: 2), () async {
                      setState(() => _currentPage--);
                      await _loadPage();
                    });
                  }
                  : null,
        ),
        Text('Page ${_currentPage + 1} / $totalPages'),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed:
              _currentPage < totalPages - 1
                  ? () async {
                    _pageDelay?.cancel();
                    _pageDelay = Timer(const Duration(seconds: 2), () async {
                      setState(() => _currentPage++);
                      await _loadPage();
                    });
                  }
                  : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            tooltip: 'Notes de test',
            onPressed: _generateFakeNotes,
          ),
          IconButton(
            icon: Icon(user != null ? Icons.logout : Icons.login),
            onPressed: _handleAuthAction,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: _buildDropdown(),
        ),
      ),
      body: FutureBuilder<List<Note>>(
        future: storage.getAllNotes(category: _selectedCategory),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text('Erreur: ${snapshot.error}'));
          final allNotes = snapshot.data ?? [];
          final totalNotes = allNotes.length;

          return Column(
            children: [
              if (_currentNotes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _selectAll,
                        onChanged: (checked) {
                          setState(() {
                            _selectAll = checked ?? false;
                            _selectAll
                                ? _selectedNoteIds =
                                    _currentNotes.map((n) => n.id!).toSet()
                                : _selectedNoteIds.clear();
                          });
                        },
                      ),
                      const Text('Tout sélectionner'),
                      const Spacer(),
                      if (_selectedNoteIds.isNotEmpty)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.delete),
                          label: Text('Supprimer (${_selectedNoteIds.length})'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: _confirmDeleteSelected,
                        ),
                    ],
                  ),
                ),
              Expanded(
                child:
                    _currentNotes.isEmpty
                        ? const Center(child: Text('Aucune note disponible'))
                        : ListView.builder(
                          itemCount: _currentNotes.length,
                          itemBuilder:
                              (context, index) =>
                                  _buildNoteCard(_currentNotes[index]),
                        ),
              ),
              _buildPaginationControls(totalNotes),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nouvelle note',
        child: const Icon(Icons.add),
        onPressed: () async {
          final created = await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const EditNoteScreen()));
          if (created == true) await _loadPage();
        },
      ),
    );
  }
}
