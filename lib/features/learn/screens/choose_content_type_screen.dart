import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:artisnal_app/core/speech/speech_player.dart';

import 'package:artisnal_app/core/theme/button_shadow.dart';
import 'package:artisnal_app/core/widgets/speak_circle_button.dart';
import 'package:artisnal_app/features/learn/data/create_content_kind.dart';
import 'package:artisnal_app/features/learn/data/create_post_progress.dart';
import 'package:artisnal_app/features/learn/data/learn_progress.dart';
import 'package:artisnal_app/features/learn/screens/create_post_badge_screen.dart';
import 'package:artisnal_app/features/learn/widgets/ig_create_illustration.dart';
import 'package:artisnal_app/features/learn/screens/post_in_instagram_screen.dart';
import 'package:artisnal_app/core/l10n/app_text.dart';

class ChooseContentTypeScreen extends StatefulWidget {
  const ChooseContentTypeScreen({super.key, required this.locale});

  final String locale;

  static const Color background = Color(0xFFF6F7F4);
  static const Color teal = Color(0xFF1B7574);
  static const Color ink = Color(0xFF152322);
  static const Color muted = Color(0xFF4F5F5D);

  static const String spoken =
      'What do you want to make? Choose Post, Story, or Reel. '
      'Then tap Continue.';

  @override
  State<ChooseContentTypeScreen> createState() =>
      _ChooseContentTypeScreenState();
}

class _ChooseContentTypeScreenState extends State<ChooseContentTypeScreen> {
  late final SpeechPlayer _speech = SpeechPlayer((_) {
    if (mounted) setState(() {});
  });

  CreateContentKind? _selected;

  @override
  void initState() {
    super.initState();
    LearnProgress.instance.addListener(_onProgress);
    _syncSelection();
    WidgetsBinding.instance.addPostFrameCallback((_) => _openBadgeIfDone());
  }

  @override
  void dispose() {
    LearnProgress.instance.removeListener(_onProgress);
    _speech.stop();
    super.dispose();
  }

  void _onProgress() {
    if (mounted) {
      setState(_syncSelection);
    }
  }

  void _syncSelection() {
    if (CreatePostProgress.allDone) {
      _selected = null;
      return;
    }
    _selected = CreatePostProgress.nextKind;
  }

  void _openBadgeIfDone() {
    if (!mounted || !CreatePostProgress.allDone) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CreatePostBadgeScreen(locale: widget.locale),
      ),
    );
  }

  bool _canSelect(CreateContentKind kind) {
    if (CreatePostProgress.isDone(kind)) return false;
    return CreatePostProgress.nextKind == kind;
  }

  void _select(CreateContentKind kind) {
    if (!_canSelect(kind)) return;
    setState(() => _selected = kind);
  }

  void _continue() {
    final kind = _selected;
    if (kind == null || CreatePostProgress.nextKind != kind) return;
    _speech.stop();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            PostInInstagramScreen(locale: widget.locale, kind: kind),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: ChooseContentTypeScreen.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: ChooseContentTypeScreen.background,
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
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                          color: ChooseContentTypeScreen.ink,
                          iconSize: 24,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                      ),
                      Text(
                        tr('TASK 3 OF 5'),
                        style: appType(
                          color: ChooseContentTypeScreen.teal,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: SpeakCircleButton(
                          playing: _speech.playing,
                          onTap: () => _speech.toggle(
                            locale: widget.locale,
                            text: tr(ChooseContentTypeScreen.spoken),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  tr('What do you want to make?'),
                  style: appType(
                    color: ChooseContentTypeScreen.ink,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tr('Do Post first, then Story, then Reel. Tap Continue for each one.'),
                  style: appType(
                    color: ChooseContentTypeScreen.muted,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: [
                      _TypeCard(
                        title: 'Post',
                        detail: 'Photo on your page',
                        icon: Icons.grid_on_rounded,
                        previewKind: CreateContentKind.post,
                        selected: _selected == CreateContentKind.post,
                        done: CreatePostProgress.isDone(CreateContentKind.post),
                        enabled: _canSelect(CreateContentKind.post),
                        onTap: () => _select(CreateContentKind.post),
                      ),
                      const SizedBox(height: 12),
                      _TypeCard(
                        title: 'Story',
                        detail: 'Shows for one day',
                        icon: Icons.history_rounded,
                        previewKind: CreateContentKind.story,
                        selected: _selected == CreateContentKind.story,
                        done: CreatePostProgress.isDone(CreateContentKind.story),
                        enabled: _canSelect(CreateContentKind.story),
                        onTap: () => _select(CreateContentKind.story),
                      ),
                      const SizedBox(height: 12),
                      _TypeCard(
                        title: 'Reel',
                        detail: 'Short video clip',
                        icon: Icons.movie_creation_outlined,
                        previewKind: CreateContentKind.reel,
                        selected: _selected == CreateContentKind.reel,
                        done: CreatePostProgress.isDone(CreateContentKind.reel),
                        enabled: _canSelect(CreateContentKind.reel),
                        onTap: () => _select(CreateContentKind.reel),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: _selected != null ? kPrimaryButtonShadow : null,
                  ),
                  child: Material(
                    color: _selected != null
                        ? ChooseContentTypeScreen.teal
                        : const Color(0xFFB8C5C2),
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      onTap: _selected != null ? _continue : null,
                      borderRadius: BorderRadius.circular(18),
                      child: SizedBox(
                        height: 56,
                        width: double.infinity,
                        child: Center(
                          child: Text(
                            tr('Continue'),
                            style: appType(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
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

class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.title,
    required this.detail,
    required this.icon,
    required this.previewKind,
    required this.selected,
    required this.done,
    required this.enabled,
    required this.onTap,
  });

  final String title;
  final String detail;
  final IconData icon;
  final CreateContentKind previewKind;
  final bool selected;
  final bool done;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = done
        ? const Color(0xFFB8D4D2)
        : selected
            ? ChooseContentTypeScreen.teal
            : const Color(0xFFE4EEEC);

    return Opacity(
      opacity: enabled || done ? 1 : 0.45,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(18),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: borderColor,
                width: selected && !done ? 2.5 : 1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x10000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                SizedBox(
                  width: 72,
                  height: 88,
                  child: IgCreateIllustration(kind: previewKind, compact: true),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            icon,
                            color: ChooseContentTypeScreen.teal,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            tr(title),
                            style: appType(
                              color: ChooseContentTypeScreen.ink,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tr(detail),
                        style: appType(
                          color: ChooseContentTypeScreen.muted,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (done)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: ChooseContentTypeScreen.teal,
                    size: 26,
                  )
                else if (selected)
                  const Icon(
                    Icons.radio_button_checked_rounded,
                    color: ChooseContentTypeScreen.teal,
                    size: 26,
                  ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
