import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../models/note.dart';
import '../repositories/hive_note_repository.dart';
import '../repositories/note_repository.dart';

const notesBoxName = 'notes';
const settingsBoxName = 'settings';
const _themeModeKey = 'themeMode';

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  final box = Hive.box<Map>(notesBoxName);
  return HiveNoteRepository(box);
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(Hive.box(settingsBoxName)),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._box) : super(_readThemeMode(_box));

  final Box _box;

  static ThemeMode _readThemeMode(Box box) {
    final value = box.get(_themeModeKey) as String?;
    return value == ThemeMode.dark.name ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _box.put(_themeModeKey, mode.name);
  }

  Future<void> toggle() async {
    await setThemeMode(
        state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }
}

final allNotesProvider = FutureProvider<List<Note>>((ref) async {
  final repository = ref.watch(noteRepositoryProvider);
  return repository.getAll();
});

final notesProvider = FutureProvider<List<Note>>((ref) async {
  final repository = ref.watch(noteRepositoryProvider);
  final query = ref.watch(searchQueryProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final notes = await repository.search(query);

  if (selectedCategory == null) {
    return notes;
  }

  return notes.where((note) => note.tags.contains(selectedCategory)).toList();
});
