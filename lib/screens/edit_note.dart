import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/storage_services.dart';
import '../services/supabase_storage_service.dart'; 
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

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final now = DateTime.now();

    final note =
        widget.note == null
            ? Note(title: title, content: content, createdAt: now)
            : Note(
              id: widget.note!.id,
              title: title,
              content: content,
              createdAt: widget.note!.createdAt,
            );

    if (widget.note == null) {
      await storage.addNote(note);
    } else {
      await storage.updateNote(note);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier la note' : 'Nouvelle note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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
              Expanded(
                child: TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(labelText: 'Contenu'),
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
              ElevatedButton(
                onPressed: _saveNote,
                child: const Text('Sauvegarder'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
