import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:artisnal_app/core/speech/speech_player.dart';

import 'package:artisnal_app/core/widgets/sharp_image.dart';
import 'package:artisnal_app/core/widgets/speak_circle_button.dart';
import 'package:artisnal_app/core/l10n/app_text.dart';

class PhotoAccessScreen extends StatefulWidget {
  const PhotoAccessScreen({super.key, required this.locale, this.nextBuilder});

  final String locale;
  final WidgetBuilder? nextBuilder;

  static const Color background = Color(0xFFF6F7F4);
  static const Color teal = Color(0xFF1B7574);
  static const Color ink = Color(0xFF152322);
  static const Color muted = Color(0xFF4F5F5D);

  static const String spoken =
      'Allow photo access. The first time you tap plus to make a post, '
      'your phone asks for permission. Tap Allow all or Select photos.';

  @override
  State<PhotoAccessScreen> createState() => _PhotoAccessScreenState();
}

class _PhotoAccessScreenState extends State<PhotoAccessScreen> {
  late final SpeechPlayer _speech = SpeechPlayer((_) {
    if (mounted) setState(() {});
  });

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  void _continue() {
    _speech.stop();
    final builder = widget.nextBuilder;
    if (builder == null) {
      Navigator.of(context).maybePop();
      return;
    }
    Navigator.of(context).push(MaterialPageRoute<void>(builder: builder));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: PhotoAccessScreen.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: PhotoAccessScreen.background,
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
                          color: PhotoAccessScreen.ink,
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
                          color: PhotoAccessScreen.teal,
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
                            text: tr(PhotoAccessScreen.spoken),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        AspectRatio(
                          aspectRatio: 320 / 220,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x12000000),
                                  blurRadius: 14,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: SharpImage(
                                  'assets/images/lessons/create_post/photo_access_art.jpg',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          tr('Allow photo access'),
                          textAlign: TextAlign.center,
                          style: appType(
                            color: PhotoAccessScreen.ink,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tr('Your phone will ask the first time you post.\nTap Allow all or Select photos.'),
                          textAlign: TextAlign.center,
                          style: appType(
                            color: PhotoAccessScreen.muted,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const _PermissionCard(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    onTap: _continue,
                    borderRadius: BorderRadius.circular(18),
                    child: SizedBox(
                      height: 56,
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          tr(widget.nextBuilder == null ? 'Got it' : 'Continue'),
                          style: appType(
                            color: PhotoAccessScreen.teal,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
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

class _PermissionCard extends StatelessWidget {
  const _PermissionCard();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7F3F1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.photo_library_outlined,
                    color: PhotoAccessScreen.teal,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tr('Photos and videos'),
                    style: appType(
                      color: PhotoAccessScreen.ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const _Choice(label: "Don't allow"),
            const SizedBox(height: 8),
            const _Choice(label: 'Select photos'),
            const SizedBox(height: 8),
            const _Choice(label: 'Allow all', selected: true),
          ],
        ),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: selected ? PhotoAccessScreen.teal : const Color(0xFFF3F5F4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? PhotoAccessScreen.teal : const Color(0xFFE4EEEC),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              tr(label),
              style: appType(
                color: selected ? Colors.white : PhotoAccessScreen.ink,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (selected)
            const Icon(Icons.check_rounded, color: Colors.white, size: 20),
        ],
      ),
    );
  }
}
