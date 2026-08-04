import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/note.dart';
import '../providers/note_providers.dart';
import '../theme/app_theme.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  const NoteEditorScreen({super.key, this.noteId});

  final String? noteId;

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  final _uuid = const Uuid();
  late final TextEditingController _titleController;
  late final TextEditingController _categoryController;
  final List<_EditableBlock> _blocks = [];
  final List<String> _tags = [];
  Timer? _saveTimer;
  Note? _note;
  int _activeBlockIndex = 0;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _categoryController = TextEditingController();
    _loadNote();
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _titleController.dispose();
    _categoryController.dispose();
    for (final block in _blocks) {
      block.dispose();
    }
    super.dispose();
  }

  Future<void> _loadNote() async {
    final repository = ref.read(noteRepositoryProvider);
    final noteId = widget.noteId;
    final existingNote =
        noteId == null ? null : await repository.getById(noteId);
    final now = DateTime.now().toUtc();

    _note = existingNote ??
        Note(
          id: _uuid.v4(),
          title: '',
          content: const [],
          tags: const [],
          createdAt: now,
          updatedAt: now,
        );

    _titleController.text = _note!.title;
    _tags
      ..clear()
      ..addAll(_note!.tags);
    for (final block in _blocks) {
      block.dispose();
    }
    _blocks
      ..clear()
      ..addAll(
        _note!.content.map(
          (block) => _EditableBlock.fromNoteBlock(
            block.copyWithCleanText(_cleanLegacyMarkup(block.text)),
          ),
        ),
      );
    if (_blocks.isEmpty) {
      _blocks.add(_EditableBlock.empty());
    }

    if (mounted) {
      setState(() {});
    }
  }

  String _cleanLegacyMarkup(String value) {
    var text = value.trim();
    var changed = true;
    while (changed) {
      changed = false;
      for (final prefix in ['> ', '- ', '# ']) {
        if (text.startsWith(prefix)) {
          text = text.substring(prefix.length).trimLeft();
          changed = true;
        }
      }
      for (final pair in const [
        ['**', '**'],
        ['_', '_'],
        ['<u>', '</u>'],
      ]) {
        if (text.startsWith(pair[0]) && text.endsWith(pair[1])) {
          text = text.substring(pair[0].length, text.length - pair[1].length);
          changed = true;
        }
      }
    }
    return text
        .replaceAll('**', '')
        .replaceAll('<u>', '')
        .replaceAll('</u>', '')
        .replaceAll(RegExp(r'(^|\n)\s*[>#-]\s+'), r'$1')
        .trim();
  }

  void _queueSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 900), _save);
  }

  Future<void> _save() async {
    final current = _note;
    if (current == null) {
      return;
    }

    final content = _blocks
        .map((block) => block.toNoteBlock())
        .where((block) => block.text.trim().isNotEmpty)
        .toList();
    final updated = current.copyWith(
      title: _titleController.text.trim(),
      content: content,
      tags: List.unmodifiable(_tags),
      updatedAt: DateTime.now().toUtc(),
    );
    await ref.read(noteRepositoryProvider).save(updated);
    _note = updated;
    ref.invalidate(allNotesProvider);
    ref.invalidate(notesProvider);
  }

  Future<void> _done() async {
    _saveTimer?.cancel();
    await _save();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  _EditableBlock get _activeBlock {
    if (_blocks.isEmpty) {
      _blocks.add(_EditableBlock.empty());
      _activeBlockIndex = 0;
    }
    return _blocks[_activeBlockIndex.clamp(0, _blocks.length - 1)];
  }

  void _setActiveBlock(int index) {
    _activeBlockIndex = index;
  }

  void _toggleBold() {
    setState(() => _activeBlock.bold = !_activeBlock.bold);
    _queueSave();
  }

  void _toggleItalic() {
    setState(() => _activeBlock.italic = !_activeBlock.italic);
    _queueSave();
  }

  void _toggleUnderline() {
    setState(() => _activeBlock.underline = !_activeBlock.underline);
    _queueSave();
  }

  void _setBlockType(NoteBlockType type) {
    setState(() => _activeBlock.type = type);
    _queueSave();
  }

  void _addCategory() {
    final tag = _categoryController.text.trim();
    if (tag.isEmpty) {
      return;
    }
    if (_tags.any((existing) => existing.toLowerCase() == tag.toLowerCase())) {
      _categoryController.clear();
      return;
    }
    setState(() {
      _tags.add(tag);
      _categoryController.clear();
    });
    _queueSave();
  }

  void _removeCategory(String tag) {
    setState(() => _tags.remove(tag));
    _queueSave();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 640;

    return Scaffold(
      backgroundColor: AppTheme.pageBackground(context),
      body: Stack(
        children: [
          Column(
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, isCompact ? 10 : 16, 24, 8),
                  child: isCompact
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IconButton(
                              onPressed: () => Navigator.of(context).maybePop(),
                              icon: const Icon(Icons.arrow_back),
                              color: AppTheme.primary,
                              style: IconButton.styleFrom(
                                fixedSize: const Size(48, 48),
                                shape: const CircleBorder(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextField(
                                    controller: _titleController,
                                    onChanged: (_) => _queueSave(),
                                    maxLines: 2,
                                    minLines: 1,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Untitled Note',
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 6,
                                      ),
                                    ),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  _CategoryEditor(
                                    tags: _tags,
                                    controller: _categoryController,
                                    onAdd: _addCategory,
                                    onRemove: _removeCategory,
                                    compact: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IconButton(
                              onPressed: () => Navigator.of(context).maybePop(),
                              icon: const Icon(Icons.arrow_back),
                              color: AppTheme.primary,
                              style: IconButton.styleFrom(
                                fixedSize: const Size(48, 48),
                                shape: const CircleBorder(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: TextField(
                                  controller: _titleController,
                                  onChanged: (_) => _queueSave(),
                                  maxLines: 2,
                                  minLines: 1,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Untitled Note',
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Flexible(
                              child: Align(
                                alignment: Alignment.topRight,
                                child: _CategoryEditor(
                                  tags: _tags,
                                  controller: _categoryController,
                                  onAdd: _addCategory,
                                  onRemove: _removeCategory,
                                  compact: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    isCompact ? 12 : 32,
                    20,
                    144,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 768),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 560),
                        padding: EdgeInsets.all(isCompact ? 24 : 32),
                        color: AppTheme.pageBackground(context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ..._blocks.asMap().entries.map(
                                  (entry) => _BlockField(
                                    key: ValueKey(entry.value.id),
                                    block: entry.value,
                                    onFocus: () => _setActiveBlock(entry.key),
                                    onChanged: _queueSave,
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          _FloatingToolbar(
            onBold: _toggleBold,
            onItalic: _toggleItalic,
            onUnderline: _toggleUnderline,
            onParagraph: () => _setBlockType(NoteBlockType.paragraph),
            onList: () => _setBlockType(NoteBlockType.bulletedList),
            onQuote: () => _setBlockType(NoteBlockType.blockquote),
            onDone: _done,
          ),
        ],
      ),
    );
  }
}

class _EditableBlock {
  _EditableBlock({
    required this.type,
    required String text,
    required this.bold,
    required this.italic,
    required this.underline,
  })  : id = const Uuid().v4(),
        controller = TextEditingController(text: text),
        focusNode = FocusNode();

  factory _EditableBlock.empty() {
    return _EditableBlock(
      type: NoteBlockType.paragraph,
      text: '',
      bold: false,
      italic: false,
      underline: false,
    );
  }

  factory _EditableBlock.fromNoteBlock(NoteBlock block) {
    return _EditableBlock(
      type: block.type,
      text: block.text,
      bold: block.bold,
      italic: block.italic,
      underline: block.underline,
    );
  }

  final String id;
  NoteBlockType type;
  bool bold;
  bool italic;
  bool underline;
  final TextEditingController controller;
  final FocusNode focusNode;

  NoteBlock toNoteBlock() {
    return NoteBlock(
      type: type,
      text: controller.text.trim(),
      bold: bold,
      italic: italic,
      underline: underline,
    );
  }

  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }
}

extension on NoteBlock {
  NoteBlock copyWithCleanText(String text) {
    return NoteBlock(
      type: type,
      text: text,
      bold: bold,
      italic: italic,
      underline: underline,
    );
  }
}

class _CategoryEditor extends StatelessWidget {
  const _CategoryEditor({
    required this.tags,
    required this.controller,
    required this.onAdd,
    required this.onRemove,
    this.compact = false,
  });

  final List<String> tags;
  final TextEditingController controller;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ...tags.map(
          (tag) => InputChip(
            label: Text(tag),
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
            onDeleted: () => onRemove(tag),
            backgroundColor: AppTheme.primaryContainer.withValues(alpha: 0.16),
            deleteIconColor: AppTheme.primary,
            labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.primary,
                ),
            side: BorderSide(color: AppTheme.outline.withValues(alpha: 0.08)),
            shape: const StadiumBorder(),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: compact ? 132 : 180,
            maxWidth: compact ? 184 : 240,
          ),
          child: Container(
            height: compact ? 36 : 40,
            padding: EdgeInsets.only(left: compact ? 12 : 14, right: 4),
            decoration: BoxDecoration(
              color: AppTheme.variant(context).withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(999),
              border:
                  Border.all(color: AppTheme.outline.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    onSubmitted: (_) => onAdd(),
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      hintText: 'Add category',
                      hintStyle:
                          Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: AppTheme.textSecondary(context)
                                    .withValues(alpha: 0.7),
                                letterSpacing: 0,
                              ),
                    ),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppTheme.textPrimary(context),
                          letterSpacing: 0,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add),
                  color: AppTheme.primary,
                  iconSize: compact ? 16 : 18,
                  style: IconButton.styleFrom(
                    fixedSize: Size(compact ? 28 : 32, compact ? 28 : 32),
                    minimumSize: Size(compact ? 28 : 32, compact ? 28 : 32),
                    padding: EdgeInsets.zero,
                    shape: const CircleBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BlockField extends StatelessWidget {
  const _BlockField({
    super.key,
    required this.block,
    required this.onFocus,
    required this.onChanged,
  });

  final _EditableBlock block;
  final VoidCallback onFocus;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: block.bold ? FontWeight.w700 : FontWeight.w400,
          fontStyle: block.italic ? FontStyle.italic : FontStyle.normal,
          decoration:
              block.underline ? TextDecoration.underline : TextDecoration.none,
        );
    final field = TextField(
      controller: block.controller,
      focusNode: block.focusNode,
      onTap: onFocus,
      onChanged: (_) => onChanged(),
      minLines: 1,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: 'Start writing...',
        hintStyle: baseStyle?.copyWith(
          color: AppTheme.textSecondary(context).withValues(alpha: 0.6),
        ),
      ),
      style: baseStyle,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: switch (block.type) {
        NoteBlockType.paragraph => field,
        NoteBlockType.bulletedList => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12, right: 12),
                child: Text('•', style: baseStyle),
              ),
              Expanded(child: field),
            ],
          ),
        NoteBlockType.blockquote => Container(
            padding: const EdgeInsets.only(left: 16),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: AppTheme.primary, width: 4),
              ),
            ),
            child: field,
          ),
      },
    );
  }
}

class _FloatingToolbar extends StatelessWidget {
  const _FloatingToolbar({
    required this.onBold,
    required this.onItalic,
    required this.onUnderline,
    required this.onParagraph,
    required this.onList,
    required this.onQuote,
    required this.onDone,
  });

  final VoidCallback onBold;
  final VoidCallback onItalic;
  final VoidCallback onUnderline;
  final VoidCallback onParagraph;
  final VoidCallback onList;
  final VoidCallback onQuote;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 32,
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.9,
          ),
          padding: const EdgeInsets.all(8),
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
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ToolbarGroup(
                  actions: [
                    _ToolbarAction(icon: Icons.format_bold, onPressed: onBold),
                    _ToolbarAction(
                      icon: Icons.format_italic,
                      onPressed: onItalic,
                    ),
                    _ToolbarAction(
                      icon: Icons.format_underlined,
                      onPressed: onUnderline,
                    ),
                  ],
                ),
                const _ToolbarDivider(),
                _ToolbarGroup(
                  actions: [
                    _ToolbarAction(icon: Icons.title, onPressed: onParagraph),
                    _ToolbarAction(
                      icon: Icons.format_list_bulleted,
                      onPressed: onList,
                    ),
                    _ToolbarAction(
                      icon: Icons.format_quote,
                      onPressed: onQuote,
                    ),
                  ],
                ),
                const _ToolbarDivider(),
                FilledButton.icon(
                  onPressed: onDone,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.onPrimary,
                    minimumSize: const Size(0, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shape: const StadiumBorder(),
                  ),
                  icon: const Icon(Icons.check, size: 18),
                  label: Text(
                    'Done',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppTheme.onPrimary,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolbarAction {
  const _ToolbarAction({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;
}

class _ToolbarGroup extends StatelessWidget {
  const _ToolbarGroup({required this.actions});

  final List<_ToolbarAction> actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.pageBackground(context),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.outline.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: actions
            .map(
              (action) => IconButton(
                onPressed: action.onPressed,
                icon: Icon(action.icon),
                color: AppTheme.textSecondary(context),
                style: IconButton.styleFrom(
                  fixedSize: const Size(40, 40),
                  shape: const CircleBorder(),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ToolbarDivider extends StatelessWidget {
  const _ToolbarDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: AppTheme.outline.withValues(alpha: 0.2),
    );
  }
}
