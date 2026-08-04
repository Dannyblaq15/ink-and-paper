enum NoteBlockType {
  paragraph,
  blockquote,
  bulletedList,
}

class NoteBlock {
  const NoteBlock({
    required this.type,
    required this.text,
    this.bold = false,
    this.italic = false,
    this.underline = false,
  });

  final NoteBlockType type;
  final String text;
  final bool bold;
  final bool italic;
  final bool underline;

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'text': text,
      'bold': bold,
      'italic': italic,
      'underline': underline,
    };
  }

  factory NoteBlock.fromJson(Map<String, dynamic> json) {
    return NoteBlock(
      type: NoteBlockType.values.byName(json['type'] as String),
      text: json['text'] as String,
      bold: json['bold'] as bool? ?? false,
      italic: json['italic'] as bool? ?? false,
      underline: json['underline'] as bool? ?? false,
    );
  }
}

class Note {
  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.pinned = false,
  });

  final String id;
  final String title;
  final List<NoteBlock> content;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool pinned;

  String get plainTextContent {
    return content.map((block) => block.text).join('\n');
  }

  Note copyWith({
    String? id,
    String? title,
    List<NoteBlock>? content,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? pinned,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pinned: pinned ?? this.pinned,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content.map((block) => block.toJson()).toList(),
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'pinned': pinned,
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String,
      content: (json['content'] as List<dynamic>)
          .map((block) =>
              NoteBlock.fromJson(Map<String, dynamic>.from(block as Map)))
          .toList(),
      tags: (json['tags'] as List<dynamic>).cast<String>(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      pinned: json['pinned'] as bool? ?? false,
    );
  }
}
