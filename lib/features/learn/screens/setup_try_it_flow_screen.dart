import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:artisnal_app/core/speech/speech_player.dart';

import 'package:artisnal_app/core/theme/button_shadow.dart';
import 'package:artisnal_app/core/widgets/sharp_image.dart';
import 'package:artisnal_app/core/widgets/speak_circle_button.dart';
import 'package:artisnal_app/features/learn/data/learn_task_navigation.dart';
import 'package:artisnal_app/features/learn/data/learn_tasks.dart';
import 'package:artisnal_app/features/learn/screens/lesson_badge_screen.dart';
import 'package:artisnal_app/features/learn/widgets/lesson_step.dart';
import 'package:artisnal_app/features/learn/widgets/next_learn_task_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:artisnal_app/core/l10n/app_text.dart';

class SetupTryItFlowScreen extends StatefulWidget {
  const SetupTryItFlowScreen({super.key, required this.locale});

  final String locale;

  static const int stepCount = 5;
  static const Color background = Color(0xFFF6F7F4);
  static const Color teal = Color(0xFF1B7574);
  static const Color ink = Color(0xFF152322);
  static const Color muted = Color(0xFF4F5F5D);
  static const Color track = Color(0xFFEDF2EF);

  @override
  State<SetupTryItFlowScreen> createState() => _SetupTryItFlowScreenState();
}

class _SetupTryItFlowScreenState extends State<SetupTryItFlowScreen> {
  late final SpeechPlayer _speech = SpeechPlayer((_) {
    if (mounted) setState(() {});
  });

  int _step = 0;
  String? _selectedHandle;
  String? _customHandle;
  Uint8List? _profilePhotoBytes;

  late final TextEditingController _nameController =
      TextEditingController(text: 'Divya Warule');
  late final TextEditingController _usernameController =
      TextEditingController(text: 'divya.weaves');
  late final TextEditingController _bioController = TextEditingController(
    text: tr('Handwoven cloth · Sualkuchi, Assam'),
  );

  final _picker = ImagePicker();

  String _sellCategoryId = 'clothing';
  bool _showCategoryOnPage = true;

  static const _bioTags = [
    'Muga silk',
    'Order on WhatsApp',
    'Since 2010',
  ];

  static const _suggestions = <_NameSuggestion>[
    _NameSuggestion('divya.weaves', best: true),
    _NameSuggestion('divya_mekhela'),
    _NameSuggestion('sualkuchi.divya'),
    _NameSuggestion('divya.handloom'),
    _NameSuggestion('weaves.by.divya'),
  ];

  String get _spoken {
    if (_step == 0) {
      return tr(
        'Pick your name. Short and easy to say. '
        'divya dot weaves is a good choice.',
      );
    }
    if (_step == 1) {
      return tr(
        'Set up your page. Add your photo, name, username, and bio. '
        'Tap the tags to add them to your bio.',
      );
    }
    if (_step == 2) {
      return tr('Switch to a professional account to unlock business tools.');
    }
    if (_step == 3) {
      return tr('What do you sell? Weavers should pick Clothing Brand.');
    }
    if (_step == 4) {
      return tr(
        'Your professional page is ready. Name, category, and contact are set.',
      );
    }
    return tr(
      'Set up your page. Step ${_step + 1} of ${SetupTryItFlowScreen.stepCount}.',
    );
  }

  String? get _effectiveHandle =>
      _customHandle ?? _selectedHandle ?? _suggestions.first.handle;

  @override
  void initState() {
    super.initState();
    _selectedHandle = _suggestions.first.handle;
    _nameController.addListener(_onFormChanged);
    _usernameController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _speech.stop();
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _back() {
    _speech.stop();
    if (_step == 4) {
      setState(() => _step = 3);
      return;
    }
    if (_step == 3) {
      setState(() => _step = 1);
      return;
    }
    if (_step > 0) {
      setState(() => _step--);
      return;
    }
    Navigator.of(context).maybePop();
  }

  Future<void> _changePhoto() async {
    _speech.stop();
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (mounted) setState(() => _profilePhotoBytes = bytes);
    } catch (_) {}
  }

  void _addBioTag(String tag) {
    final translated = tr(tag);
    final bio = _bioController.text;
    if (bio.contains(translated)) return;
    setState(() {
      _bioController.text = bio.isEmpty ? translated : '$bio · $translated';
    });
  }

  void _next() {
    _speech.stop();
    if (_step < SetupTryItFlowScreen.stepCount - 1) {
      if (_step == 0) {
        _usernameController.text = _effectiveHandle ?? 'divya.weaves';
        setState(() => _step++);
        return;
      }
      if (_step == 1) {
        setState(() => _step = 3);
        return;
      }
      setState(() => _step++);
      return;
    }
    _finishTryIt();
  }

  void _finishTryIt() {
    final step = LessonStep.maybeOf(context);
    if (step != null) {
      step.onFinished();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _showSetUpPageBadge() {
    _speech.stop();
    final step = LessonStep.maybeOf(context);
    final nextTaskTitle = step?.nextLearnTaskTitle;
    final lessonNavigator = Navigator.of(context);
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (badgeContext) => LessonBadgeScreen(
          title: 'Set up your page',
          subtitle:
              'You practiced your name, bio, category, and pro page on Instagram.',
          nextLearnTaskTitle: nextTaskTitle,
          onContinue: () {
            if (step != null && nextTaskTitle != null) {
              LearnTaskNavigation.dismissBadgeFinishAndOpenNext(
                badgeContext: badgeContext,
                lessonNavigator: lessonNavigator,
                finishedTaskId: setUpPageTaskId,
                locale: widget.locale,
                finishLesson: step.onFinished,
              );
              return;
            }
            Navigator.of(badgeContext).pop();
            if (step != null) {
              step.onFinished();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
    );
  }

  String get _selectedCategoryTitle {
    switch (_sellCategoryId) {
      case 'artist':
        return 'Artist';
      case 'shop':
        return 'Shop';
      case 'community':
        return 'Community';
      default:
        return 'Clothing (Brand)';
    }
  }

  Future<void> _typeMyOwn() async {
    _speech.stop();
    final controller = TextEditingController(
      text: _customHandle ?? _selectedHandle ?? '',
    );
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            tr('Your handle'),
            style: appType(fontWeight: FontWeight.w800),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              prefixText: '@',
              hintText: 'divya.weaves',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(tr('Cancel')),
            ),
            TextButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isEmpty) return;
                Navigator.pop(context, text);
              },
              child: Text(tr('Save')),
            ),
          ],
        );
      },
    );
    if (result == null || !mounted) return;
    setState(() {
      _customHandle = result;
      _selectedHandle = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: SetupTryItFlowScreen.background,
      ),
      child: Scaffold(
        backgroundColor: SetupTryItFlowScreen.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 48,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: _back,
                          icon: const Icon(Icons.arrow_back_rounded),
                          color: SetupTryItFlowScreen.ink,
                          iconSize: 24,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                      ),
                      Text(
                        tr('TASK 2 · ${_step + 1} OF ${SetupTryItFlowScreen.stepCount}'),
                        style: appType(
                          color: SetupTryItFlowScreen.teal,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: SpeakCircleButton(
                          playing: _speech.playing,
                          onTap: () => _speech.toggle(
                            locale: widget.locale,
                            text: _spoken,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (var i = 0; i < SetupTryItFlowScreen.stepCount; i++) ...[
                      if (i > 0) const SizedBox(width: 6),
                      Expanded(
                        child: Container(
                          height: 7,
                          decoration: BoxDecoration(
                            color: i <= _step
                                ? SetupTryItFlowScreen.teal
                                : SetupTryItFlowScreen.track,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 14),
                ..._headerSection,
                const SizedBox(height: 14),
                Expanded(child: _stepBody),
                const SizedBox(height: 12),
                if (_step == 4) _buildNextTaskButton() else _buildPrimaryNextButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryNextButton({
    VoidCallback? onTap,
    String label = 'Next',
  }) {
    final enabled = onTap != null || _canContinue;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: enabled ? kPrimaryButtonShadow : null,
      ),
      child: Material(
        color: enabled
            ? SetupTryItFlowScreen.teal
            : const Color(0xFF8DBAB9),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: enabled ? (onTap ?? _next) : null,
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            height: 56,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 2),
                Text(
                  tr(label),
                  style: appType(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNextTaskButton() {
    final nextTitle = LessonStep.maybeOf(context)?.nextLearnTaskTitle;
    if (nextTitle == null) {
      return _buildPrimaryNextButton(onTap: _finishTryIt, label: 'Done');
    }
    return NextLearnTaskButton(
      locale: widget.locale,
      nextTaskTitle: nextTitle,
      onTap: _showSetUpPageBadge,
    );
  }

  bool get _canContinue {
    if (_step == 0) {
      return _effectiveHandle != null && _effectiveHandle!.isNotEmpty;
    }
    if (_step == 1) {
      return _nameController.text.trim().isNotEmpty &&
          _usernameController.text.trim().isNotEmpty;
    }
    return true;
  }

  List<Widget> get _headerSection {
    if (_step == 1) {
      return [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F3F2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            tr('PRACTICE · LIKE INSTAGRAM'),
            style: appType(
              color: SetupTryItFlowScreen.teal,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          tr('Set up your page'),
          style: appType(
            color: SetupTryItFlowScreen.ink,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
      ];
    }

    if (_step == 3) {
      return [
        Text(
          tr('Set up your page'),
          style: appType(
            color: SetupTryItFlowScreen.ink,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          tr('What do you sell?'),
          style: appType(
            color: SetupTryItFlowScreen.ink,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.12,
          ),
        ),
      ];
    }

    if (_step == 4) {
      return [
        Text(
          tr('Set up your page'),
          style: appType(
            color: SetupTryItFlowScreen.ink,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          tr('Your Pro page'),
          style: appType(
            color: SetupTryItFlowScreen.ink,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.12,
          ),
        ),
      ];
    }

    if (_step == 0) {
      return [
        Text(
          tr('Set up your page'),
          style: appType(
            color: SetupTryItFlowScreen.teal,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          tr(_stepTitle),
          style: appType(
            color: SetupTryItFlowScreen.ink,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          tr(_stepSubtitle),
          style: appType(
            color: SetupTryItFlowScreen.muted,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ];
    }

    return [
      Text(
        tr('Set up your page'),
        style: appType(
          color: SetupTryItFlowScreen.teal,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        tr(_stepTitle),
        style: appType(
          color: SetupTryItFlowScreen.ink,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          height: 1.15,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        tr(_stepSubtitle),
        style: appType(
          color: SetupTryItFlowScreen.muted,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    ];
  }

  String get _stepTitle {
    switch (_step) {
      case 0:
        return 'Pick your name';
      case 1:
        return 'Add your photo';
      case 2:
        return 'Go professional';
      case 3:
        return 'What do you sell?';
      default:
        return 'Review your page';
    }
  }

  String get _stepSubtitle {
    switch (_step) {
      case 0:
        return 'Short. Easy to say.';
      case 1:
        return 'Clear face or your loom.';
      case 2:
        return 'Unlock the professional dashboard.';
      case 3:
        return 'Pick the best category for weavers.';
      default:
        return 'You are ready to sell.';
    }
  }

  Widget get _stepBody {
    if (_step == 1) return _buildProfilePageStep();
    if (_step == 2) return _buildProfessionalStep();
    if (_step == 3) return _buildWhatDoYouSellStep();
    if (_step == 4) return _buildYourProPageStep();
    if (_step != 0) {
      return Center(
        child: Text(
          tr('Step ${_step + 1}'),
          style: appType(
            color: SetupTryItFlowScreen.muted,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView(
      children: [
        if (_customHandle != null) ...[
          _NameCard(
            handle: _customHandle!,
            selected: true,
            onTap: () {},
          ),
          const SizedBox(height: 10),
        ],
        for (final suggestion in _suggestions)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _NameCard(
              handle: suggestion.handle,
              best: suggestion.best,
              selected: _customHandle == null &&
                  _selectedHandle == suggestion.handle,
              onTap: () => setState(() {
                _customHandle = null;
                _selectedHandle = suggestion.handle;
              }),
            ),
          ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _typeMyOwn,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.edit_outlined,
                    color: SetupTryItFlowScreen.teal,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    tr('Type my own'),
                    style: appType(
                      color: SetupTryItFlowScreen.teal,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePageStep() {
    return ListView(
      children: [
        Row(
          children: [
            ClipOval(
              child: _profilePhotoBytes != null
                  ? Image.memory(
                      _profilePhotoBytes!,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    )
                  : const SharpImage(
                      'assets/images/lessons/set_up_page/profile_clear.jpg',
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('Your photo'),
                    style: appType(
                      color: SetupTryItFlowScreen.ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _changePhoto,
                      borderRadius: BorderRadius.circular(6),
                      child: Text(
                        tr('Change photo'),
                        style: appType(
                          color: SetupTryItFlowScreen.teal,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _FieldLabel('Name'),
        const SizedBox(height: 6),
        _OutlinedField(controller: _nameController),
        const SizedBox(height: 14),
        _FieldLabel('Username'),
        const SizedBox(height: 6),
        _OutlinedField(controller: _usernameController),
        const SizedBox(height: 14),
        _FieldLabel('Bio'),
        const SizedBox(height: 6),
        _OutlinedField(controller: _bioController, maxLines: 3),
        const SizedBox(height: 16),
        Text(
          tr('Tap to add to bio'),
          style: appType(
            color: SetupTryItFlowScreen.muted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tag in _bioTags)
              _BioChip(label: tag, onTap: () => _addBioTag(tag)),
          ],
        ),
      ],
    );
  }

  Widget _buildProfessionalStep() {
    return ListView(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE4EEEC)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('Professional dashboard'),
                style: appType(
                  color: SetupTryItFlowScreen.ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                tr(
                  'Switch to professional so buyers can message you and '
                  'you can see your numbers.',
                ),
                style: appType(
                  color: SetupTryItFlowScreen.muted,
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWhatDoYouSellStep() {
    const categories = <_SellCategory>[
      _SellCategory(
        id: 'clothing',
        title: 'Clothing (Brand)',
        detail: 'Mekhela, saree, stole',
        icon: Icons.sell_outlined,
        best: true,
      ),
      _SellCategory(
        id: 'artist',
        title: 'Artist',
        icon: Icons.brush_outlined,
      ),
      _SellCategory(
        id: 'shop',
        title: 'Shop',
        icon: Icons.storefront_outlined,
      ),
      _SellCategory(
        id: 'community',
        title: 'Community',
        icon: Icons.groups_outlined,
      ),
    ];

    return ListView(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8EE),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFF0E2C8)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.star_rounded,
                color: const Color(0xFFC5922E),
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  tr('Weavers: pick Clothing (Brand)'),
                  style: appType(
                    color: SetupTryItFlowScreen.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (final category in categories)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SellCategoryCard(
              category: category,
              selected: _sellCategoryId == category.id,
              onTap: () => setState(() => _sellCategoryId = category.id),
            ),
          ),
        const SizedBox(height: 4),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE4EEEC)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.person_outline_rounded,
                    color: SetupTryItFlowScreen.muted,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tr('Show on my page'),
                      style: appType(
                        color: SetupTryItFlowScreen.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Switch.adaptive(
                    value: _showCategoryOnPage,
                    activeTrackColor: const Color(0xFF9CC5C4),
                    thumbColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return SetupTryItFlowScreen.teal;
                      }
                      return null;
                    }),
                    onChanged: (v) => setState(() => _showCategoryOnPage = v),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildYourProPageStep() {
    final handle = _usernameController.text.trim();
    final bio = _bioController.text.trim();

    return ListView(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE4EEEC)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipOval(
                      child: _profilePhotoBytes != null
                          ? Image.memory(
                              _profilePhotoBytes!,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                            )
                          : const SharpImage(
                              'assets/images/lessons/set_up_page/profile_clear.jpg',
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        children: const [
                          Expanded(
                            child: _MiniStat('0', 'posts'),
                          ),
                          Expanded(
                            child: _MiniStat('12', 'followers'),
                          ),
                          Expanded(
                            child: _MiniStat('30', 'following'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      _nameController.text.trim(),
                      style: appType(
                        color: SetupTryItFlowScreen.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.verified_rounded,
                      color: SetupTryItFlowScreen.teal,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  tr(_selectedCategoryTitle),
                  style: appType(
                    color: SetupTryItFlowScreen.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  bio,
                  style: appType(
                    color: SetupTryItFlowScreen.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    _PageActionChip('Edit page'),
                    SizedBox(width: 6),
                    _PageActionChip('Share page'),
                    SizedBox(width: 6),
                    _PageActionChip('Contact'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE4EEEC)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('ALL DONE'),
                  style: appType(
                    color: SetupTryItFlowScreen.teal,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 10),
                _DoneRow('Name @$handle'),
                const SizedBox(height: 8),
                _DoneRow(_selectedCategoryTitle),
                const SizedBox(height: 8),
                const _DoneRow('Contact button'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat(this.value, this.label);

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: appType(
            color: SetupTryItFlowScreen.ink,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          tr(label),
          style: appType(
            color: SetupTryItFlowScreen.muted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _PageActionChip extends StatelessWidget {
  const _PageActionChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFEFEFEF),
          borderRadius: BorderRadius.circular(8),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              tr(label),
              style: appType(
                color: SetupTryItFlowScreen.ink,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DoneRow extends StatelessWidget {
  const _DoneRow(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.check_circle_rounded,
          color: SetupTryItFlowScreen.teal,
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            tr(text),
            style: appType(
              color: SetupTryItFlowScreen.ink,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _SellCategory {
  const _SellCategory({
    required this.id,
    required this.title,
    required this.icon,
    this.detail,
    this.best = false,
  });

  final String id;
  final String title;
  final String? detail;
  final IconData icon;
  final bool best;
}

class _SellCategoryCard extends StatelessWidget {
  const _SellCategoryCard({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final _SellCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? SetupTryItFlowScreen.teal
                  : const Color(0xFFE4EEEC),
              width: selected ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(
                  category.icon,
                  color: selected
                      ? SetupTryItFlowScreen.teal
                      : SetupTryItFlowScreen.muted,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              tr(category.title),
                              style: appType(
                                color: selected
                                    ? SetupTryItFlowScreen.teal
                                    : SetupTryItFlowScreen.ink,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (category.best) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F3F2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                tr('Best'),
                                style: appType(
                                  color: SetupTryItFlowScreen.teal,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (category.detail != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          tr(category.detail!),
                          style: appType(
                            color: SetupTryItFlowScreen.muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected
                      ? SetupTryItFlowScreen.teal
                      : const Color(0xFFB8C5C2),
                  size: 26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      tr(text),
      style: appType(
        color: SetupTryItFlowScreen.ink,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _OutlinedField extends StatelessWidget {
  const _OutlinedField({
    required this.controller,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: appType(
        color: SetupTryItFlowScreen.ink,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE4EEEC)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE4EEEC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: SetupTryItFlowScreen.teal,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class _BioChip extends StatelessWidget {
  const _BioChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFD5E8E6)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            tr('+ $label'),
            style: appType(
              color: SetupTryItFlowScreen.teal,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _NameSuggestion {
  const _NameSuggestion(this.handle, {this.best = false});

  final String handle;
  final bool best;
}

class _NameCard extends StatelessWidget {
  const _NameCard({
    required this.handle,
    required this.selected,
    required this.onTap,
    this.best = false,
  });

  final String handle;
  final bool best;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? SetupTryItFlowScreen.teal
                  : const Color(0xFFE4EEEC),
              width: selected ? 2 : 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Text(
                  tr('@ $handle'),
                  style: appType(
                    color: SetupTryItFlowScreen.ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (best) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F3F2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tr('Best'),
                      style: appType(
                        color: SetupTryItFlowScreen.teal,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected
                      ? SetupTryItFlowScreen.teal
                      : const Color(0xFFB8C5C2),
                  size: 26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
