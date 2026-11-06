/// Writes the prompt an artisan copies into their own AI tool to get a bio or
/// a caption, from a few things they tell us about themselves.
///
/// The prompt is in English, like the photo prompts: AI tools follow English
/// most reliably. The words the AI writes back are in the language picked.
library;

enum AiWordsGoal { bio, caption }

/// One thing we ask. [hint] is an example shown in the empty box.
class AiWordsQuestion {
  const AiWordsQuestion(this.key, this.label, this.hint, {this.needed = false});

  final String key;
  final String label;
  final String hint;

  /// The prompt cannot be written without it.
  final bool needed;
}

const _bioQuestions = <AiWordsQuestion>[
  AiWordsQuestion('name', 'Your name', 'Rina Das'),
  AiWordsQuestion(
    'from',
    'Where are you from?',
    'Sualkuchi, Assam',
    needed: true,
  ),
  AiWordsQuestion(
    'make',
    'What do you make?',
    'Handwoven Muga silk sarees',
    needed: true,
  ),
  AiWordsQuestion(
    'story',
    'Your story',
    'Weaving for 15 years, taught by my mother',
  ),
  AiWordsQuestion(
    'buy',
    'How can people buy?',
    'DM to order. Ships across India.',
  ),
];

const _captionQuestions = <AiWordsQuestion>[
  AiWordsQuestion(
    'product',
    'What is in this post?',
    'Red Muga silk saree',
    needed: true,
  ),
  AiWordsQuestion(
    'special',
    'What is special about it?',
    'Woven by hand in 20 days',
    needed: true,
  ),
  AiWordsQuestion('from', 'Where are you from?', 'Sualkuchi, Assam'),
  AiWordsQuestion('price', 'Price', '₹4,500'),
  AiWordsQuestion(
    'buy',
    'How can people buy?',
    'DM to order. Ships across India.',
  ),
];

List<AiWordsQuestion> aiWordsQuestionsFor(AiWordsGoal goal) =>
    goal == AiWordsGoal.bio ? _bioQuestions : _captionQuestions;

/// Languages the AI can write back in. Its own name goes into the prompt.
const aiWordsLanguages = <String>[
  'English',
  'Assamese',
  'Odia',
  'Telugu',
  'Hindi',
];

/// The language the app is in, as the first guess for the answer.
String aiWordsLanguageFor(String appCode) => switch (appCode) {
  'as' => 'Assamese',
  'or' => 'Odia',
  'te' => 'Telugu',
  _ => 'English',
};

/// True once every question the prompt needs has an answer.
bool aiWordsReady(AiWordsGoal goal, Map<String, String> answers) =>
    aiWordsQuestionsFor(goal)
        .where((question) => question.needed)
        .every((question) => (answers[question.key] ?? '').trim().isNotEmpty);

const _factNames = <String, String>{
  'name': 'Name',
  'from': 'From',
  'make': 'I make',
  'story': 'My story',
  'buy': 'How to buy',
  'product': 'Product',
  'special': 'What is special',
  'price': 'Price',
};

String buildAiWordsPrompt({
  required AiWordsGoal goal,
  required Map<String, String> answers,
  required String language,
}) {
  String? answer(String key) {
    final value = answers[key]?.trim().replaceAll(RegExp(r'\s+'), ' ');
    return value == null || value.isEmpty ? null : value;
  }

  final facts = [
    for (final question in aiWordsQuestionsFor(goal))
      if (answer(question.key) case final value?)
        '- ${_factNames[question.key]}: $value',
  ].join('\n');
  // The AI must not add a price, a place or a story the artisan never gave.
  const honest = 'Use only these facts. Do not make anything up.';

  if (goal == AiWordsGoal.bio) {
    return 'Write 3 Instagram bio options for my handloom page.\n\n'
        'About me:\n$facts\n\n'
        'Keep each bio under 150 characters, in 3 or 4 short lines. '
        'Use simple, warm words and 1 or 2 emojis. Write in $language.\n\n'
        '$honest';
  }
  final ending = answer('buy') == null
      ? 'End by asking people to message me to order'
      : 'End with how to buy';
  return 'Write 3 Instagram caption options for my post.\n\n'
      'About the post:\n$facts\n\n'
      'Start with a line that makes people stop. Keep it to 4 short lines. '
      '$ending, then add 5 hashtags. '
      'Use simple, warm words. Write in $language.\n\n'
      '$honest';
}
