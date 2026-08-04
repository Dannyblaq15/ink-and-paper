import 'dart:io';

import 'package:hive/hive.dart';
import 'package:ink_and_paper/models/note.dart';
import 'package:ink_and_paper/repositories/hive_note_repository.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late Box<Map> box;
  late HiveNoteRepository repository;

  setUp(() async {
    tempDir =
        await Directory.systemTemp.createTemp('hive_note_repository_test_');
    Hive.init(tempDir.path);
    box = await Hive.openBox<Map>('notes_test');
    await box.clear();
    repository = HiveNoteRepository(box);
  });

  tearDown(() async {
    await box.close();
    await tempDir.delete(recursive: true);
  });

  test('saves, loads, searches, and deletes a note', () async {
    final createdAt = DateTime.utc(2026, 8, 3, 12);
    final note = Note(
      id: 'note-1',
      title: 'The Architecture of Stillness',
      content: const [
        NoteBlock(
          type: NoteBlockType.paragraph,
          text:
              'Stillness creates space where clarity can construct new perspectives.',
        ),
        NoteBlock(
          type: NoteBlockType.blockquote,
          text: 'A quiet room for your thoughts to build outward.',
        ),
      ],
      tags: const ['Journal'],
      createdAt: createdAt,
      updatedAt: createdAt,
    );

    await repository.save(note);

    expect(await repository.getById('note-1'), isNotNull);
    expect((await repository.getAll()).single.title,
        'The Architecture of Stillness');
    expect((await repository.search('clarity')).single.id, 'note-1');
    expect((await repository.search('journal')).single.id, 'note-1');

    await repository.delete('note-1');

    expect(await repository.getById('note-1'), isNull);
  });
}
