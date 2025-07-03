import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/note.dart';
import '../services/storage_services.dart';

// Créer / modifier une note
class EditNoteScreen extends StatefulWidget {
  final Note? note; // Créer / modifier si existante
  const EditNoteScreen({super.key, this.note});

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final StorageService storage = StorageService(); // Service sauvegarde/lecture
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _contentController;
  String? _selectedCategory;
  bool _isPreview = false; // Mode .md

  final List<String> _categories = Note.allowedCategories;

  @override
  void initState() {
    super.initState();
    // Pré-remplit si existante
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
    _selectedCategory =
        (widget.note != null &&
                Note.allowedCategories.contains(widget.note!.category))
            ? widget.note!.category
            : Note.allowedCategories.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // Save la note
  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final category = _selectedCategory ?? Note.allowedCategories.first;
    final now = DateTime.now();

    // crée note ou MAJ existante
    final note =
        (widget.note == null)
            ? Note(
              title: title,
              content: content,
              createdAt: now,
              category: category,
            )
            : Note(
              id: widget.note!.id,
              title: title,
              content: content,
              createdAt: widget.note!.createdAt,
              category: category,
            );

    if (widget.note == null) {
      await storage.insertNote(note); // Create
    } else {
      await storage.updateNote(note); // Update
    }

    Navigator.of(context).pop(true); // Notif note créer
  }

  // supprimer note
  Future<void> _deleteNote() async {
    if (widget.note == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Supprimer la note ?'),
            content: const Text('Cette action est irréversible.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false), // Annuler
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed:
                    () => Navigator.pop(context, true), // Confirmer suppression
                child: const Text('Supprimer'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await storage.deleteNote(widget.note!.id!); // Supprime dans la base
      Navigator.of(context).pop(true); // Ferme l’écran
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier la note' : 'Nouvelle note'),
        actions: [
          // aperçu markdown
          IconButton(
            icon: Icon(_isPreview ? Icons.edit : Icons.preview),
            tooltip: _isPreview ? 'Modifier' : 'Aperçu Markdown',
            onPressed: () => setState(() => _isPreview = !_isPreview),
          ),
          // supprimer si edit
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Supprimer la note',
              onPressed: _deleteNote,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Champ titre
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Titre'),
                validator:
                    (val) =>
                        val == null || val.isEmpty
                            ? 'Le titre est requis'
                            : null,
              ),
              const SizedBox(height: 16),

              // Choix de la cat
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items:
                    _categories
                        .map(
                          (cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)),
                        )
                        .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
                decoration: const InputDecoration(labelText: 'Catégorie'),
              ),
              const SizedBox(height: 16),

              // Champ contenu / aperçu markdown
              Expanded(
                child:
                    _isPreview
                        ? Markdown(
                          data: _contentController.text,
                          selectable: true,
                        )
                        : TextFormField(
                          controller: _contentController,
                          decoration: const InputDecoration(
                            labelText: 'Contenu',
                          ),
                          maxLines: null,
                          expands: true,
                          keyboardType: TextInputType.multiline,
                          validator:
                              (val) =>
                                  val == null || val.isEmpty
                                      ? 'Le contenu est requis'
                                      : null,
                        ),
              ),
              const SizedBox(height: 16),

              // Bouton save
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _saveNote,
                    child: const Text('Sauvegarder'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
