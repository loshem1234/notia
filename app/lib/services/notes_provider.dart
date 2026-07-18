import 'package:flutter/foundation.dart';
import '../models/note.dart';
import '../services/database_service.dart';
import '../services/api_service.dart';

class NotesProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  final ApiService _api = ApiService();
  
  List<Note> _notes = [];
  bool _isLoading = false;
  String _searchQuery = '';
  
  List<Note> get notes {
    if (_searchQuery.isEmpty) {
      return _notes;
    }
    return _notes.where((note) =>
      note.text.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      (note.category?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
    ).toList();
  }
  
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  
  // Initialize - load all notes from database
  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();
    
    _notes = await _db.getAllNotes();
    
    _isLoading = false;
    notifyListeners();
  }
  
  // Create a new note
  Future<Note> addNote(String text, {bool isDeveloped = false}) async {
    // 1. Save to database IMMEDIATELY (local-first)
    final note = Note(
      text: text,
      createdAt: DateTime.now(),
      isDeveloped: isDeveloped,
    );
    
    final savedNote = await _db.createNote(note);
    _notes.insert(0, savedNote);
    notifyListeners();
    
    // 2. Categorize in background (non-blocking)
    _categorizeNoteInBackground(savedNote);
    
    return savedNote;
  }
  
  Future<void> _categorizeNoteInBackground(Note note) async {
    try {
      final result = await _api.categorizeNote(
        text: note.text,
        isDeveloped: note.isDeveloped,
      );
      
      // Update note with category
      final updatedNote = note.copyWith(
        category: result['category'],
        categoryConfidence: result['confidence'],
      );
      
      await _db.updateNote(updatedNote);
      
      // Update in-memory list
      final index = _notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        _notes[index] = updatedNote;
        notifyListeners();
      }
    } catch (e) {
      // Silently fail - note is already saved locally
      debugPrint('Background categorization failed: $e');
    }
  }
  
  // Update a note
  Future<void> updateNote(Note note) async {
    await _db.updateNote(note);
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
      notifyListeners();
    }
  }
  
  // Delete a note
  Future<void> deleteNote(int id) async {
    await _db.deleteNote(id);
    _notes.removeWhere((note) => note.id == id);
    notifyListeners();
  }
  
  // Search
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
  
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }
  
  // Get categories with counts
  Map<String, int> getCategoryCounts() {
    final counts = <String, int>{};
    for (final note in _notes) {
      if (note.category != null) {
        counts[note.category!] = (counts[note.category!] ?? 0) + 1;
      }
    }
    return counts;
  }
}
