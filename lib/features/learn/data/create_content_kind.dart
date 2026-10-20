enum CreateContentKind { post, story, reel }

class CreateContentGuide {
  const CreateContentGuide({
    required this.headerTitle,
    required this.spoken,
    required this.firstStepSpoken,
    required this.steps,
    required this.instructionTitle,
    required this.instructionBody,
  });

  final String headerTitle;
  final String spoken;
  final String firstStepSpoken;
  final List<String> steps;
  final String instructionTitle;
  final String instructionBody;

  static CreateContentGuide forKind(CreateContentKind kind) {
    return switch (kind) {
      CreateContentKind.post => const CreateContentGuide(
        headerTitle: 'Post in Instagram',
        spoken:
            'Post in Instagram. Tap plus at the top left. Pick your photo, '
            'paste your words, then tap Share.',
        firstStepSpoken: 'Tap the plus sign to start a new post.',
        steps: ['Tap +', 'Pick your photo', 'Paste your words', 'Tap Share'],
        instructionTitle: 'Make a feed post',
        instructionBody:
            'A post stays on your page. Use a clear photo of your cloth.',
      ),
      CreateContentKind.story => const CreateContentGuide(
        headerTitle: 'Share a story',
        spoken:
            'To share a story, tap plus, then tap Story. Pick your photo '
            'and tap Your story.',
        firstStepSpoken: 'Tap plus, then choose Story.',
        steps: ['Tap +', 'Tap Story', 'Pick your photo', 'Tap Your story'],
        instructionTitle: 'Make a story',
        instructionBody:
            'Stories disappear after one day. Show your weave up close.',
      ),
      CreateContentKind.reel => const CreateContentGuide(
        headerTitle: 'Make a reel',
        spoken:
            'To make a reel, tap plus, then tap Reel. Pick a short clip '
            'of your work and tap Share.',
        firstStepSpoken: 'Tap plus, then choose Reel.',
        steps: ['Tap +', 'Tap Reel', 'Pick your clip', 'Tap Share'],
        instructionTitle: 'Make a reel',
        instructionBody: 'Reels are short videos. Show your hands at the loom.',
      ),
    };
  }
}
