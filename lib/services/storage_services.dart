import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/note.dart';

class StorageService {
  // Instance
  static final StorageService _instance = StorageService._internal();

  // Factory constructeur pour manipuler l'instance
  factory StorageService() => _instance;

  // Constructeur interne privé
  StorageService._internal();

  // Instance privée
  static Database? _database;

  // Créer la db, créer si db = null
  Future<Database> get database async {
    if (_database != null) return _database!; // DB existe
    _database = await _initDB(); // Créer la DB
    return _database!;
  }

  // Initialise la DB
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'notes.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  // Définition table Note (si création DB)
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        title TEXT NOT NULL,                   
        content TEXT NOT NULL,                 
        createdAt TEXT NOT NULL,               
        category TEXT                         
      )
    ''');
  }

  // MAJ DB (v1-v2)
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE notes ADD COLUMN category TEXT');
    }
  }

  // Créer note
  Future<int> insertNote(Note note) async {
    final db = await database;
    return await db.insert('notes', note.toMap());
  }

  // Read note
  Future<List<Note>> getAllNotes({String? category}) async {
    final db = await database;
    List<Map<String, dynamic>> result;

    // Tri par cat
    if (category == null || category == 'All') {
      result = await db.query('notes', orderBy: 'createdAt DESC');
    } else {
      result = await db.query(
        'notes',
        where: 'category = ?',
        whereArgs: [category],
        orderBy: 'createdAt DESC',
      );
    }

    return result.map((map) => Note.fromMap(map)).toList();
  }

  // MAJ note
  Future<int> updateNote(Note note) async {
    final db = await database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id], // Mise à jour où id correspond
    );
  }

  // Del note
  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}
