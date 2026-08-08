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
    setState(() => _activeBlockIndex = index);
  }

  void _toggleBold() {
    setState(() => _activeBlock.controller.toggleBold());
    _queueSave();
  }

  void _toggleItalic() {
    setState(() => _activeBlock.controller.toggleItalic());
    _queueSave();
  }

  void _toggleUnderline() {
    setState(() => _activeBlock.controller.toggleUnderline());
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
                  padding: EdgeInsets.fromLTRB(
                    isCompact ? 12 : 16,
                    isCompact ? 10 : 16,
                    isCompact ? 12 : 16,
                    8,
                  ),
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
            boldSelected: _activeBlock.controller.activeStyle.bold,
            italicSelected: _activeBlock.controller.activeStyle.italic,
            underlineSelected: _activeBlock.controller.activeStyle.underline,
            paragraphSelected: _activeBlock.type == NoteBlockType.paragraph,
            listSelected: _activeBlock.type == NoteBlockType.bulletedList,
            quoteSelected: _activeBlock.type == NoteBlockType.blockquote,
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
    required List<NoteTextRun> runs,
  })  : id = const Uuid().v4(),
        controller = _StyledTextController(text: text, runs: runs),
        focusNode = FocusNode();

  factory _EditableBlock.empty() {
    return _EditableBlock(
      type: NoteBlockType.paragraph,
      text: '',
      runs: const [],
    );
  }

  factory _EditableBlock.fromNoteBlock(NoteBlock block) {
    return _EditableBlock(
      type: block.type,
      text: block.text,
      runs: block.runs,
    );
  }

  final String id;
  NoteBlockType type;
  final _StyledTextController controller;
  final FocusNode focusNode;

  NoteBlock toNoteBlock() {
    return NoteBlock(
      type: type,
      text: controller.text.trim(),
      runs: controller.runsForSavedText(),
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
      runs: runs,
    );
  }
}

class _TextRunStyle {
  const _TextRunStyle({
    this.bold = false,
    this.italic = false,
    this.underline = false,
  });

  final bool bold;
  final bool italic;
  final bool underline;

  bool get hasStyle => bold || italic || underline;

  _TextRunStyle copyWith({
    bool? bold,
    bool? italic,
    bool? underline,
  }) {
    return _TextRunStyle(
      bold: bold ?? this.bold,
      italic: italic ?? this.italic,
      underline: underline ?? this.underline,
    );
  }
}

class _StyledTextController extends TextEditingController {
  _StyledTextController({
    required String text,
    required List<NoteTextRun> runs,
  })  : _runs = runs.map(_StyledRange.fromNoteRun).toList(),
        super(text: text);

  List<_StyledRange> _runs;
  _TextRunStyle _typingStyle = const _TextRunStyle();
  TextEditingValue _previousValue = TextEditingValue.empty;

  void toggleBold() {
    _toggleStyle((style) => style.copyWith(bold: !style.bold));
  }

  void toggleItalic() {
    _toggleStyle((style) => style.copyWith(italic: !style.italic));
  }

  void toggleUnderline() {
    _toggleStyle((style) => style.copyWith(underline: !style.underline));
  }

  _TextRunStyle get activeStyle {
    final selection = value.selection;
    if (!selection.isValid || selection.isCollapsed) {
      return _typingStyle;
    }

    final start =
        selection.start < selection.end ? selection.start : selection.end;
    final end =
        selection.start < selection.end ? selection.end : selection.start;
    var bold = false;
    var italic = false;
    var underline = false;
    for (final run in _normalizedRuns(text)) {
      if (run.end <= start || run.start >= end) {
        continue;
      }
      bold = bold || run.style.bold;
      italic = italic || run.style.italic;
      underline = underline || run.style.underline;
    }
    return _TextRunStyle(bold: bold, italic: italic, underline: underline);
  }

  void _toggleStyle(_TextRunStyle Function(_TextRunStyle style) update) {
    final selection = value.selection;
    if (!selection.isValid || selection.isCollapsed) {
      _typingStyle = update(_typingStyle);
      return;
    }

    final start =
        selection.start < selection.end ? selection.start : selection.end;
    final end =
        selection.start < selection.end ? selection.end : selection.start;
    _applyStyleToRange(start, end, update);
  }

  List<NoteTextRun> runsForSavedText() {
    final leadingTrim = text.length - text.trimLeft().length;
    final savedText = text.trim();
    if (savedText.isEmpty) {
      return const [];
    }
    return _normalizedRuns(text)
        .map(
          (run) => NoteTextRun(
            start: (run.start - leadingTrim).clamp(0, savedText.length),
            end: (run.end - leadingTrim).clamp(0, savedText.length),
            bold: run.style.bold,
            italic: run.style.italic,
            underline: run.style.underline,
          ),
        )
        .where((run) => run.start < run.end && run.hasStyle)
        .toList();
  }

  @override
  set value(TextEditingValue newValue) {
    final oldValue = _previousValue;
    super.value = newValue;
    _syncRunsAfterEdit(oldValue, newValue);
    _previousValue = newValue;
  }

  void _syncRunsAfterEdit(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final delta = newValue.text.length - oldValue.text.length;
    if (delta == 0) {
      return;
    }

    final editStart = oldValue.selection.isValid
        ? oldValue.selection.start.clamp(0, oldValue.text.length)
        : 0;

    if (delta > 0) {
      final insertedStart = editStart;
      final insertedEnd = insertedStart + delta;
      _runs = _runs.map((run) {
        if (run.start >= insertedStart) {
          return run.shift(delta);
        }
        if (run.end > insertedStart) {
          return run.copyWith(end: run.end + delta);
        }
        return run;
      }).toList();
      if (_typingStyle.hasStyle) {
        _runs.add(_StyledRange(
          start: insertedStart,
          end: insertedEnd,
          style: _typingStyle,
        ));
      }
    } else {
      final deletedLength = -delta;
      final deletedStart = newValue.selection.isValid
          ? newValue.selection.start.clamp(0, newValue.text.length)
          : editStart.clamp(0, newValue.text.length);
      final deletedEnd = deletedStart + deletedLength;
      _runs = _runs
          .map((run) => run.afterDeletion(deletedStart, deletedEnd))
          .whereType<_StyledRange>()
          .toList();
    }

    _runs = _normalizedRuns(newValue.text);
  }

  void _applyStyleToRange(
    int start,
    int end,
    _TextRunStyle Function(_TextRunStyle style) update,
  ) {
    final segments = <_StyledRange>[];
    var cursor = start;
    for (final run in _normalizedRuns(text)) {
      if (run.end <= start || run.start >= end) {
        segments.add(run);
        continue;
      }
      if (run.start < start) {
        segments.add(run.copyWith(end: start));
      }
      if (cursor < run.start) {
        final nextStyle = update(const _TextRunStyle());
        if (nextStyle.hasStyle) {
          segments.add(
              _StyledRange(start: cursor, end: run.start, style: nextStyle));
        }
      }
      final overlapStart = run.start.clamp(start, end);
      final overlapEnd = run.end.clamp(start, end);
      final nextStyle = update(run.style);
      if (nextStyle.hasStyle) {
        segments.add(_StyledRange(
            start: overlapStart, end: overlapEnd, style: nextStyle));
      }
      cursor = overlapEnd;
      if (run.end > end) {
        segments.add(run.copyWith(start: end));
      }
    }
    if (cursor < end) {
      final nextStyle = update(const _TextRunStyle());
      if (nextStyle.hasStyle) {
        segments.add(_StyledRange(start: cursor, end: end, style: nextStyle));
      }
    }
    _runs = _mergeAdjacent(segments, text);
  }

  List<_StyledRange> _normalizedRuns(String value) {
    return _mergeAdjacent(
      _runs
          .where((run) => run.start < run.end && run.start < value.length)
          .map((run) => run.clampToText(value))
          .where((run) => run.style.hasStyle)
          .toList(),
      value,
    );
  }

  List<_StyledRange> _mergeAdjacent(List<_StyledRange> ranges, String value) {
    ranges.sort((a, b) => a.start.compareTo(b.start));
    final merged = <_StyledRange>[];
    for (final range in ranges) {
      final safe = range.clampToText(value);
      if (safe.start >= safe.end || !safe.style.hasStyle) {
        continue;
      }
      if (merged.isNotEmpty &&
          merged.last.end == safe.start &&
          merged.last.sameStyle(safe)) {
        merged[merged.length - 1] = merged.last.copyWith(end: safe.end);
      } else {
        merged.add(safe);
      }
    }
    return merged;
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final defaultStyle = style ?? DefaultTextStyle.of(context).style;
    final children = <TextSpan>[];
    var cursor = 0;
    for (final run in _normalizedRuns(text)) {
      if (cursor < run.start) {
        children.add(TextSpan(text: text.substring(cursor, run.start)));
      }
      children.add(
        TextSpan(
          text: text.substring(run.start, run.end),
          style: defaultStyle.copyWith(
            fontWeight: run.style.bold ? FontWeight.w700 : FontWeight.w400,
            fontStyle: run.style.italic ? FontStyle.italic : FontStyle.normal,
            decoration: run.style.underline
                ? TextDecoration.underline
                : TextDecoration.none,
          ),
        ),
      );
      cursor = run.end;
    }
    if (cursor < text.length) {
      children.add(TextSpan(text: text.substring(cursor)));
    }
    return TextSpan(style: defaultStyle, children: children);
  }
}

class _StyledRange {
  const _StyledRange({
    required this.start,
    required this.end,
    required this.style,
  });

  factory _StyledRange.fromNoteRun(NoteTextRun run) {
    return _StyledRange(
      start: run.start,
      end: run.end,
      style: _TextRunStyle(
        bold: run.bold,
        italic: run.italic,
        underline: run.underline,
      ),
    );
  }

  final int start;
  final int end;
  final _TextRunStyle style;

  _StyledRange copyWith({
    int? start,
    int? end,
    _TextRunStyle? style,
  }) {
    return _StyledRange(
      start: start ?? this.start,
      end: end ?? this.end,
      style: style ?? this.style,
    );
  }

  _StyledRange shift(int offset) {
    return copyWith(start: start + offset, end: end + offset);
  }

  _StyledRange clampToText(String text) {
    final safeStart = start.clamp(0, text.length);
    final safeEnd = end.clamp(safeStart, text.length);
    return copyWith(start: safeStart, end: safeEnd);
  }

  _StyledRange? afterDeletion(int deletedStart, int deletedEnd) {
    final deletedLength = deletedEnd - deletedStart;
    if (end <= deletedStart) {
      return this;
    }
    if (start >= deletedEnd) {
      return shift(-deletedLength);
    }
    final nextStart = start < deletedStart ? start : deletedStart;
    final nextEnd = end > deletedEnd ? end - deletedLength : deletedStart;
    if (nextStart >= nextEnd) {
      return null;
    }
    return copyWith(start: nextStart, end: nextEnd);
  }

  bool sameStyle(_StyledRange other) {
    return style.bold == other.style.bold &&
        style.italic == other.style.italic &&
        style.underline == other.style.underline;
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
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      TextField(
                        controller: controller,
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.center,
                        onSubmitted: (_) => onAdd(),
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 36,
                            vertical: 0,
                          ),
                          hintText: 'Add category',
                          hintStyle:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: AppTheme.textSecondary(context)
                                        .withValues(alpha: 0.7),
                                    letterSpacing: 0,
                                  ),
                        ),
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: AppTheme.textPrimary(context),
                                  letterSpacing: 0,
                                ),
                      ),
                      Positioned(
                        right: 0,
                        child: IconButton(
                          onPressed: onAdd,
                          icon: const Icon(Icons.add),
                          color: AppTheme.primary,
                          iconSize: compact ? 16 : 18,
                          style: IconButton.styleFrom(
                            fixedSize:
                                Size(compact ? 28 : 32, compact ? 28 : 32),
                            minimumSize:
                                Size(compact ? 28 : 32, compact ? 28 : 32),
                            padding: EdgeInsets.zero,
                            shape: const CircleBorder(),
                          ),
                        ),
                      ),
                    ],
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
    final baseStyle = Theme.of(context).textTheme.bodyLarge;
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
    required this.boldSelected,
    required this.italicSelected,
    required this.underlineSelected,
    required this.paragraphSelected,
    required this.listSelected,
    required this.quoteSelected,
  });

  final VoidCallback onBold;
  final VoidCallback onItalic;
  final VoidCallback onUnderline;
  final VoidCallback onParagraph;
  final VoidCallback onList;
  final VoidCallback onQuote;
  final VoidCallback onDone;
  final bool boldSelected;
  final bool italicSelected;
  final bool underlineSelected;
  final bool paragraphSelected;
  final bool listSelected;
  final bool quoteSelected;

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
                    _ToolbarAction(
                      icon: Icons.format_bold,
                      onPressed: onBold,
                      selected: boldSelected,
                    ),
                    _ToolbarAction(
                      icon: Icons.format_italic,
                      onPressed: onItalic,
                      selected: italicSelected,
                    ),
                    _ToolbarAction(
                      icon: Icons.format_underlined,
                      onPressed: onUnderline,
                      selected: underlineSelected,
                    ),
                  ],
                ),
                const _ToolbarDivider(),
                _ToolbarGroup(
                  actions: [
                    _ToolbarAction(
                      icon: Icons.title,
                      onPressed: onParagraph,
                      selected: paragraphSelected,
                    ),
                    _ToolbarAction(
                      icon: Icons.format_list_bulleted,
                      onPressed: onList,
                      selected: listSelected,
                    ),
                    _ToolbarAction(
                      icon: Icons.format_quote,
                      onPressed: onQuote,
                      selected: quoteSelected,
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
    this.selected = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool selected;
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
                color: action.selected
                    ? AppTheme.onPrimary
                    : AppTheme.textSecondary(context),
                style: IconButton.styleFrom(
                  fixedSize: const Size(40, 40),
                  backgroundColor:
                      action.selected ? AppTheme.primary : Colors.transparent,
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
