part of 'ai_photos_screen.dart';

/// Builds a prompt for a bio or a caption: the artisan picks one, tells us a
/// few things about themselves, then copies the prompt.
class AiWordsScreen extends StatefulWidget {
  const AiWordsScreen({super.key, required this.locale});

  final String locale;

  @override
  State<AiWordsScreen> createState() => _AiWordsScreenState();
}

class _AiWordsScreenState extends State<AiWordsScreen>
    with _AiPage<AiWordsScreen> {
  /// Kept while the app is open, so a caption after a bio does not ask
  /// "Where are you from?" twice.
  static final Map<String, String> _remembered = {};

  int _step = 0;
  AiWordsGoal? _goal;
  late String _language = aiWordsLanguageFor(AppLang.code);
  final Map<String, TextEditingController> _boxes = {};
  bool _copied = false;
  Timer? _copiedTimer;

  @override
  void initState() {
    super.initState();
    final name = SavedWork.instance.name;
    if (name != null && name.isNotEmpty) {
      _remembered.putIfAbsent('name', () => name);
    }
  }

  @override
  void dispose() {
    _copiedTimer?.cancel();
    for (final box in _boxes.values) {
      box.dispose();
    }
    super.dispose();
  }

  TextEditingController _box(String key) => _boxes.putIfAbsent(key, () {
    final box = TextEditingController(text: _remembered[key] ?? '');
    box.addListener(() {
      _remembered[key] = box.text;
      setState(() {});
    });
    return box;
  });

  Map<String, String> get _answers => {
    for (final question in aiWordsQuestionsFor(_goal!))
      question.key: _box(question.key).text,
  };

  String get _prompt =>
      buildAiWordsPrompt(goal: _goal!, answers: _answers, language: _language);

  void _back() {
    if (_step == 0) {
      Navigator.of(context).maybePop();
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _step--);
  }

  bool get _canContinue {
    final goal = _goal;
    if (goal == null) return false;
    return _step == 0 || aiWordsReady(goal, _answers);
  }

  Future<void> _copy() async {
    var worked = true;
    try {
      await Clipboard.setData(
        ClipboardData(text: _prompt),
      ).timeout(const Duration(seconds: 3));
    } on PlatformException {
      worked = false;
    } on TimeoutException {
      worked = false;
    }
    if (!mounted) return;
    if (!worked) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              tr('Could not copy. Select the words and copy them.'),
              style: appType(color: Colors.white),
            ),
          ),
        );
      return;
    }
    SavedWork.instance.saveAiPrompt(_prompt);
    setState(() => _copied = true);
    _copiedTimer?.cancel();
    _copiedTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return aiFrame(
      kicker: 'Bio and caption',
      canPop: _step == 0,
      onBack: _back,
      pageKey: _step,
      body: switch (_step) {
        0 => _goalStep(),
        1 => _questionsStep(),
        _ => _promptStep(),
      },
      bottom: _step < 2
          ? [
              _button(
                label: 'Continue',
                onTap: _canContinue
                    ? () {
                        FocusScope.of(context).unfocus();
                        setState(() => _step++);
                      }
                    : null,
              ),
            ]
          : [
              _button(
                label: _copied ? 'Prompt copied' : 'Copy prompt',
                icon: _copied ? Icons.check_rounded : null,
                onTap: _copy,
              ),
              const SizedBox(height: 4),
              finishButton(),
            ],
    );
  }

  Widget _goalStep() {
    void pick(AiWordsGoal goal) {
      HapticFeedback.selectionClick();
      setState(() => _goal = goal);
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _heading('What do you want?', 'Tap one'),
        _ChoiceRow(
          title: 'Bio',
          detail: 'A few lines at the top of your page',
          icon: Icons.person_outline_rounded,
          selected: _goal == AiWordsGoal.bio,
          onTap: () => pick(AiWordsGoal.bio),
        ),
        _ChoiceRow(
          title: 'Caption',
          detail: 'The words under a post',
          icon: Icons.notes_rounded,
          selected: _goal == AiWordsGoal.caption,
          onTap: () => pick(AiWordsGoal.caption),
        ),
      ],
    );
  }

  Widget _questionsStep() {
    final goal = _goal!;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _heading(
          goal == AiWordsGoal.bio
              ? 'Tell us about you'
              : 'Tell us about the post',
          'We put this in the prompt',
        ),
        for (final question in aiWordsQuestionsFor(goal)) _question(question),
        _label('Write it in'),
        _chips(
          aiWordsLanguages,
          isOn: (language) => language == _language,
          onTap: (language) {
            HapticFeedback.selectionClick();
            setState(() => _language = language);
          },
        ),
      ],
    );
  }

  Widget _question(AiWordsQuestion question) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: tr(question.label),
              style: appType(
                color: AiPhotosScreen.ink,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
              children: [
                if (!question.needed)
                  TextSpan(
                    text: '  ${tr('Optional')}',
                    style: appType(
                      color: AiPhotosScreen.muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            key: ValueKey('ai-words-${question.key}'),
            controller: _box(question.key),
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
            style: appType(color: AiPhotosScreen.ink, fontSize: 15),
            decoration: InputDecoration(
              hintText: tr(question.hint),
              hintStyle: appType(color: AiPhotosScreen.waiting, fontSize: 15),
              filled: true,
              fillColor: Colors.white,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AiPhotosScreen.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AiPhotosScreen.teal,
                  width: 1.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _promptStep() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _heading('Your prompt', 'Copy it and paste it into your AI tool'),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AiPhotosScreen.cardBorder),
          ),
          child: SelectableText(
            _prompt,
            style: appType(
              color: AiPhotosScreen.ink,
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ),
        _label('How to use it'),
        _numbered(1, 'Open your AI tool'),
        _numbered(2, 'Paste the prompt and send'),
        _numbered(3, 'Pick the one you like best'),
        _label('Check before you post'),
        _ticked('Is every fact true?'),
        _ticked('Does it sound like you?'),
        const SizedBox(height: 8),
        Text(
          tr('Change any word you like. It is your page.'),
          style: appType(
            color: AiPhotosScreen.muted,
            fontSize: 14,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
