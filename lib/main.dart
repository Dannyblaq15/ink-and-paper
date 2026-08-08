import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'providers/note_providers.dart';
import 'screens/note_list_screen.dart';
import 'splash/splash_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<Map>(notesBoxName);
  await Hive.openBox(settingsBoxName);

  runApp(const ProviderScope(child: InkAndPaperApp()));
}

class InkAndPaperApp extends ConsumerWidget {
  const InkAndPaperApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ink & Paper',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: kIsWeb
          ? const NoteListScreen()
          : const SplashScreen(home: NoteListScreen()),
    );
  }
}
