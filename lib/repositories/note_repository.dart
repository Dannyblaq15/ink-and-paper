import '../models/note.dart';

abstract class NoteRepository {
  Future<List<Note>> getAll();

  Future<Note?> getById(String id);

  Future<void> save(Note note);

  Future<void> delete(String id);

  Future<List<Note>> search(String query);
}
