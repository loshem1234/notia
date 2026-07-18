import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notia.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const realType = 'REAL';

    await db.execute('''
      CREATE TABLE notes (
        id $idType,
        text $textType,
        createdAt $textType,
        isDeveloped $intType,
        category TEXT,
        categoryConfidence $realType
      )
    ''');
    
    // Create index for faster searches
    await db.execute('CREATE INDEX idx_createdAt ON notes(createdAt DESC)');
    await db.execute('CREATE INDEX idx_category ON notes(category)');
  }

  // Create a new note
  Future<Note> createNote(Note note) async {
    final db = await instance.database;
    final id = await db.insert('notes', note.toMap());
    return note.copyWith(id: id);
  }

  // Read all notes
  Future<List<Note>> getAllNotes() async {
    final db = await instance.database;
    final result = await db.query(
      'notes',
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => Note.fromMap(map)).toList();
  }

  // Read a single note by ID
  Future<Note?> getNote(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return Note.fromMap(maps.first);
    }
    return null;
  }

  // Update a note
  Future<int> updateNote(Note note) async {
    final db = await instance.database;
    return db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // Delete a note
  Future<int> deleteNote(int id) async {
    final db = await instance.database;
    return db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Search notes
  Future<List<Note>> searchNotes(String query) async {
    final db = await instance.database;
    final result = await db.query(
      'notes',
      where: 'text LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => Note.fromMap(map)).toList();
  }

  // Get notes by category
  Future<List<Note>> getNotesByCategory(String category) async {
    final db = await instance.database;
    final result = await db.query(
      'notes',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => Note.fromMap(map)).toList();
  }

  // Close database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
