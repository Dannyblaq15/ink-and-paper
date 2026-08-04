import 'package:hive/hive.dart';

import '../models/note.dart';
import 'note_repository.dart';

class HiveNoteRepository implements NoteRepository {
  HiveNoteRepository(this._box);

  final Box<Map> _box;

  @override
  Future<List<Note>> getAll() async {
    final notes = _box.values
        .map((value) => Note.fromJson(Map<String, dynamic>.from(value)))
        .toList();
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }

  @override
  Future<Note?> getById(String id) async {
    final value = _box.get(id);
    if (value == null) {
      return null;
    }
    return Note.fromJson(Map<String, dynamic>.from(value));
  }

  @override
  Future<void> save(Note note) async {
    await _box.put(note.id, note.toJson());
  }

  @override
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  @override
  Future<List<Note>> search(String query) async {
    final normalizedQuery = query.trim().toLowerCase();
    final notes = await getAll();
    if (normalizedQuery.isEmpty) {
      return notes;
    }

    return notes.where((note) {
      final searchableText = [
        note.title,
        note.plainTextContent,
        ...note.tags,
      ].join(' ').toLowerCase();
      return searchableText.contains(normalizedQuery);
    }).toList();
  }
}
