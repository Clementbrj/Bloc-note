import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/note.dart';
import '../services/supabase_storage_service.dart';

// Écran pour créer ou modifier une note
class EditNoteScreen extends StatefulWidget {
  final Note? note;
  const EditNoteScreen({super.key, this.note});

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final SupabaseStorageService storage = SupabaseStorageService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late String _selectedCategory;
  bool _isPreview = false;

  final List<String> _categories = Note.allowedCategories;

  @override
  void initState() {
    super.initState();
        // Initialisation des contrôleurs et catégorie sélectionnée
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _selectedCategory = (widget.note != null &&
            _categories.contains(widget.note!.category))
        ? widget.note!.category
        : _categories.first;
  }

  @override
  void dispose() {
     // Libération des ressources des contrôleurs
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
  // Sauvegarde ou mise à jour de la note
  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final now = DateTime.now();

    final note = widget.note == null
        ? Note(
            title: title,
            content: content,
            createdAt: now,
            category: _selectedCategory,
          )
        : Note(
            id: widget.note!.id,
            title: title,
            content: content,
            createdAt: widget.note!.createdAt,
            category: _selectedCategory,
          );

    if (widget.note == null) {
      await storage.addNote(note);
    } else {
      await storage.updateNote(note);
    }

    Navigator.of(context).pop(true);
  }
  // Suppression de la note avec confirmation
  Future<void> _deleteNote() async {
    if (widget.note == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la note ?'),
        content: const Text('Cette action est irréversible.'),
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
      await storage.deleteNote(widget.note!.id!);
      Navigator.of(context).pop(true);
    }
  }
  // Champ de saisie du titre
  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(labelText: 'Titre'),
      validator: (val) => val == null || val.isEmpty ? 'Le titre est requis' : null,
    );
  }
  // Sélecteur de catégorie
  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      items: _categories
          .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
          .toList(),
      onChanged: (val) {
        if (val != null) {
          setState(() => _selectedCategory = val);
        }
      },
      decoration: const InputDecoration(labelText: 'Catégorie'),
    );
  }
 // Éditeur de contenu ou aperçu Markdown
  Widget _buildContentEditor() {
    return _isPreview
        ? Markdown(data: _contentController.text, selectable: true)
        : TextFormField(
            controller: _contentController,
            decoration: const InputDecoration(labelText: 'Contenu'),
            maxLines: null,
            expands: true,
            keyboardType: TextInputType.multiline,
            validator: (val) => val == null || val.isEmpty ? 'Le contenu est requis' : null,
          );
  }
  // Bouton de sauvegarde
  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveNote,
      child: const Text('Sauvegarder'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier la note' : 'Nouvelle note'),
        actions: [
          IconButton(
            icon: Icon(_isPreview ? Icons.edit : Icons.preview),
            tooltip: _isPreview ? 'Modifier' : 'Aperçu Markdown',
            onPressed: () => setState(() => _isPreview = !_isPreview),
          ),
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
              _buildTitleField(),
              const SizedBox(height: 16),
              _buildCategoryDropdown(),
              const SizedBox(height: 16),
              Expanded(child: _buildContentEditor()),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [_buildSaveButton()],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
