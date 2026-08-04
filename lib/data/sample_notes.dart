import '../models/note.dart';

final sampleNotes = <Note>[
  Note(
    id: 'project-space',
    title: 'The Solitude of Space',
    content: const [
      NoteBlock(
        type: NoteBlockType.paragraph,
        text:
            'Exploring the thematic elements of isolation in deep space travel narratives. Need to research long-term psychological effects of sensory deprivation and hyper-sleep cycles.',
      ),
    ],
    tags: const [],
    createdAt: DateTime.utc(2026, 8),
    updatedAt: DateTime.utc(2026, 8, 1),
  ),
  Note(
    id: 'journal-autumn',
    title: 'Autumn Impressions',
    content: const [
      NoteBlock(
        type: NoteBlockType.paragraph,
        text:
            'The way the light shifts in October, turning everything golden before it fades to grey. I want to capture that fleeting warmth in the next chapter of the manuscript.',
      ),
    ],
    tags: const [],
    createdAt: DateTime.utc(2026, 7, 24),
    updatedAt: DateTime.utc(2026, 7, 27),
  ),
  Note(
    id: 'character-elias',
    title: 'Character Study: Elias',
    content: const [
      NoteBlock(
        type: NoteBlockType.paragraph,
        text:
            "Details on Elias's background. He grew up in the coastal town of...",
      ),
    ],
    tags: const [],
    createdAt: DateTime.utc(2026, 8, 2),
    updatedAt: DateTime.utc(2026, 8, 2),
  ),
  Note(
    id: 'dialogue-snips',
    title: 'Dialogue Snips',
    content: const [
      NoteBlock(
        type: NoteBlockType.paragraph,
        text:
            '"I never said it was easy, I said it was necessary." - Need to use this...',
      ),
    ],
    tags: const [],
    createdAt: DateTime.utc(2026, 10, 24),
    updatedAt: DateTime.utc(2026, 10, 24),
  ),
  Note(
    id: 'floating-city',
    title: 'Worldbuilding: The Floating City',
    content: const [
      NoteBlock(
        type: NoteBlockType.paragraph,
        text:
            'Architecture relies heavily on aerostatic balloons and lightweight...',
      ),
    ],
    tags: const [],
    createdAt: DateTime.utc(2026, 10, 20),
    updatedAt: DateTime.utc(2026, 10, 20),
  ),
  Note(
    id: 'grocery-list',
    title: 'Grocery List',
    content: const [
      NoteBlock(
        type: NoteBlockType.bulletedList,
        text: 'Almond milk, coffee beans, sourdough bread, avocados...',
      ),
    ],
    tags: const [],
    createdAt: DateTime.utc(2026, 10, 18),
    updatedAt: DateTime.utc(2026, 10, 18),
  ),
];
