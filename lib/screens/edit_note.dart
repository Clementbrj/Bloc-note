import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/note.dart';
import '../services/supabase_storage_service.dart';

class EditNoteScreen extends StatefulWidget {
  final Note? note; // Note existante ou null (nouvelle)
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
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
    _selectedCategory =
        widget.note != null && _categories.contains(widget.note!.category)
            ? widget.note!.category
            : _categories.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // Création ou mise à jour
  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utilisateur non connecté.')),
      );
      return;
    }

    final note =
        widget.note == null
            ? Note(
              userId: user.id,
              title: _titleController.text.trim(),
              content: _contentController.text.trim(),
              createdAt: DateTime.now(),
              category: _selectedCategory,
            )
            : Note(
              id: widget.note!.id,
              userId: widget.note!.userId,
              title: _titleController.text.trim(),
              content: _contentController.text.trim(),
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

  // Suppression avec confirmation
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

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Titre',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator:
          (val) => val == null || val.isEmpty ? 'Le titre est requis' : null,
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Catégorie',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      items:
          _categories
              .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
              .toList(),
      onChanged: (val) {
        if (val != null) setState(() => _selectedCategory = val);
      },
    );
  }

  Widget _buildContentEditor() {
    return _isPreview
        ? Card(
          margin: const EdgeInsets.only(top: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Markdown(data: _contentController.text, selectable: true),
          ),
        )
        : TextFormField(
          controller: _contentController,
          decoration: InputDecoration(
            labelText: 'Contenu',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            alignLabelWithHint: true,
          ),
          maxLines: null,
          expands: true,
          keyboardType: TextInputType.multiline,
          validator:
              (val) =>
                  val == null || val.isEmpty ? 'Le contenu est requis' : null,
        );
  }

  Widget _buildSaveButton() {
    return ElevatedButton.icon(
      onPressed: _saveNote,
      icon: const Icon(Icons.save),
      label: const Text('Sauvegarder'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
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
            icon: Icon(_isPreview ? Icons.edit : Icons.visibility),
            tooltip: _isPreview ? 'Mode édition' : 'Mode aperçu',
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
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: _buildSaveButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
