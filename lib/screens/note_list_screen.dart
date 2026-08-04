import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/sample_notes.dart';
import '../models/note.dart';
import '../providers/note_providers.dart';
import 'note_editor_screen.dart';
import '../theme/app_theme.dart';

class NoteListScreen extends ConsumerStatefulWidget {
  const NoteListScreen({super.key});

  @override
  ConsumerState<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends ConsumerState<NoteListScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    Future.microtask(_seedNotesIfNeeded);
    Future.microtask(_removeDummySeedCategories);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _seedNotesIfNeeded() async {
    final repository = ref.read(noteRepositoryProvider);
    final notes = await repository.getAll();
    if (notes.isNotEmpty) {
      return;
    }

    for (final note in sampleNotes) {
      await repository.save(note);
    }
    ref.invalidate(allNotesProvider);
    ref.invalidate(notesProvider);
  }

  Future<void> _removeDummySeedCategories() async {
    const seededNoteIds = {
      'project-space',
      'journal-autumn',
      'character-elias',
      'dialogue-snips',
      'floating-city',
      'grocery-list',
    };
    final repository = ref.read(noteRepositoryProvider);
    final notes = await repository.getAll();
    var changed = false;
    for (final note in notes) {
      if (seededNoteIds.contains(note.id) && note.tags.isNotEmpty) {
        await repository.save(note.copyWith(tags: const []));
        changed = true;
      }
    }
    if (changed) {
      ref.invalidate(allNotesProvider);
      ref.invalidate(notesProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesValue = ref.watch(notesProvider);

    return Scaffold(
      backgroundColor: AppTheme.pageBackground(context),
      drawer: const _CategoryDrawer(),
      body: Builder(
        builder: (context) {
          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _TopAppBar(
                      onMenuPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 32, 20, 144),
                    sliver: notesValue.when(
                      data: (notes) => _NotesBody(notes: notes),
                      loading: () => const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (error, stackTrace) => SliverFillRemaining(
                        child: Center(child: Text(error.toString())),
                      ),
                    ),
                  ),
                ],
              ),
              _BottomSearchBar(controller: _searchController),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryDrawer extends StatelessWidget {
  const _CategoryDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.pageBackground(context),
      child: const SafeArea(
        child: _CategorySidebarContent(),
      ),
    );
  }
}

class _CategorySidebarContent extends ConsumerWidget {
  const _CategorySidebarContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesValue = ref.watch(allNotesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.container(context),
        border: Border(
          right: BorderSide(color: AppTheme.outline.withValues(alpha: 0.08)),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
      child: notesValue.when(
        data: (notes) {
          final categories = notes
              .expand((note) => note.tags)
              .where((tag) => tag.trim().isNotEmpty)
              .toSet()
              .toList()
            ..sort();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Categories',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: _CategoryItem(
                  label: 'All Notes',
                  selected: selectedCategory == null,
                  onTap: () {
                    ref.read(selectedCategoryProvider.notifier).state = null;
                    Scaffold.maybeOf(context)?.closeDrawer();
                  },
                ),
              ),
              const SizedBox(height: 8),
              ...categories.map(
                (category) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _CategoryItem(
                      label: category,
                      selected: selectedCategory == category,
                      onTap: () {
                        ref.read(selectedCategoryProvider.notifier).state =
                            category;
                        Scaffold.maybeOf(context)?.closeDrawer();
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Text(error.toString()),
      ),
    );
  }
}

class _TopAppBar extends ConsumerWidget {
  const _TopAppBar({required this.onMenuPressed});

  final VoidCallback onMenuPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: onMenuPressed,
              icon: const Icon(Icons.subject),
              color: AppTheme.primary,
              style: IconButton.styleFrom(
                fixedSize: const Size(40, 40),
                backgroundColor: Colors.transparent,
                shape: const CircleBorder(),
              ),
            ),
            IconButton(
              tooltip: isDark ? 'Light mode' : 'Dark mode',
              onPressed: () {
                ref.read(themeModeProvider.notifier).toggle();
              },
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              color: AppTheme.primary,
              style: IconButton.styleFrom(
                fixedSize: const Size(40, 40),
                backgroundColor: Colors.transparent,
                shape: const CircleBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppTheme.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: selected
                      ? AppTheme.onPrimary
                      : AppTheme.textSecondary(context),
                  letterSpacing: 0,
                ),
          ),
        ),
      ),
    );
  }
}

class _NotesBody extends ConsumerWidget {
  const _NotesBody({required this.notes});

  final List<Note> notes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinnedNotes = notes.where((note) => note.pinned).toList();
    final recentNotes = notes.where((note) => !note.pinned).toList();

    return SliverList(
      delegate: SliverChildListDelegate([
        if (pinnedNotes.isNotEmpty) ...[
          _SectionTitle(
            title: 'Pinned',
            icon: Icons.push_pin,
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 960
                  ? 3
                  : constraints.maxWidth >= 640
                      ? 2
                      : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: columns == 1 ? 1.55 : 1.35,
                ),
                itemCount: pinnedNotes.length,
                itemBuilder: (context, index) => _PinnedNoteCard(
                  note: pinnedNotes[index],
                  dateLabel: 'Pinned',
                  onLongPress: () =>
                      _togglePinned(context, ref, pinnedNotes[index]),
                ),
              );
            },
          ),
          const SizedBox(height: 80),
        ],
        const _SectionTitle(title: 'Recent Notes'),
        const SizedBox(height: 24),
        ...recentNotes.asMap().entries.map((entry) {
          const labels = ['Yesterday', 'Oct 24', 'Oct 20', 'Oct 18'];
          return Padding(
            padding: EdgeInsets.only(
                bottom: entry.key == recentNotes.length - 1 ? 0 : 16),
            child: _RecentNoteRow(
              note: entry.value,
              dateLabel: labels[entry.key.clamp(0, labels.length - 1)],
              onLongPress: () => _togglePinned(context, ref, entry.value),
            ),
          );
        }),
      ]),
    );
  }

  Future<void> _togglePinned(
    BuildContext context,
    WidgetRef ref,
    Note note,
  ) async {
    final updated = note.copyWith(
      pinned: !note.pinned,
      updatedAt: DateTime.now().toUtc(),
    );
    await ref.read(noteRepositoryProvider).save(updated);
    ref.invalidate(allNotesProvider);
    ref.invalidate(notesProvider);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(updated.pinned ? 'Pinned note' : 'Unpinned note'),
        duration: const Duration(milliseconds: 900),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.icon});

  final String title;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.headlineMedium;
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: AppTheme.primary, size: 24),
          const SizedBox(width: 8),
        ],
        Text(title, style: textStyle),
      ],
    );
  }
}

class _PinnedNoteCard extends StatelessWidget {
  const _PinnedNoteCard({
    required this.note,
    required this.dateLabel,
    required this.onLongPress,
  });

  final Note note;
  final String dateLabel;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.containerLowest(context),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => NoteEditorScreen(noteId: note.id),
            ),
          );
        },
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.outline.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TagPill(label: note.tags.firstOrNull ?? ''),
                  Text(
                    dateLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.textSecondary(context),
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                note.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Text(
                  note.plainTextContent,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary(context),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentNoteRow extends StatelessWidget {
  const _RecentNoteRow({
    required this.note,
    required this.dateLabel,
    required this.onLongPress,
  });

  final Note note;
  final String dateLabel;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.container(context),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => NoteEditorScreen(noteId: note.id),
            ),
          );
        },
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.outline.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontSize: 18,
                                height: 24 / 18,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      note.plainTextContent,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary(context),
                            fontSize: 14,
                            height: 20 / 14,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                dateLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.textSecondary(context),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.primary,
            ),
      ),
    );
  }
}

class _BottomSearchBar extends ConsumerWidget {
  const _BottomSearchBar({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 32,
      child: Center(
        child: Container(
          width: MediaQuery.sizeOf(context).width * 0.9,
          constraints: const BoxConstraints(maxWidth: 448),
          height: 64,
          padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
          decoration: BoxDecoration(
            color: AppTheme.containerHighest(context).withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppTheme.outline.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: AppTheme.textSecondary(context),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        onChanged: (value) {
                          ref.read(searchQueryProvider.notifier).state = value;
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search notes...',
                          hintStyle:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textSecondary(context)
                                        .withValues(alpha: 0.5),
                                  ),
                        ),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const NoteEditorScreen(),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: AppTheme.onPrimary,
                  minimumSize: const Size(72, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  shape: const StadiumBorder(),
                ),
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
