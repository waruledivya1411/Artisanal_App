import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:artisnal_app/core/speech/speech_player.dart';

import 'package:artisnal_app/core/widgets/sharp_image.dart';
import 'package:artisnal_app/core/widgets/speak_circle_button.dart';
import 'package:artisnal_app/features/learn/data/create_content_kind.dart';
import 'package:artisnal_app/features/learn/screens/did_you_post_screen.dart';
import 'package:artisnal_app/core/l10n/app_text.dart';

class PickPhotoGuideScreen extends StatefulWidget {
  const PickPhotoGuideScreen({
    super.key,
    required this.locale,
    this.kind = CreateContentKind.post,
  });

  final String locale;
  final CreateContentKind kind;

  static const Color background = Color(0xFFF6F7F4);
  static const Color teal = Color(0xFF1B7574);
  static const Color ink = Color(0xFF152322);
  static const Color muted = Color(0xFF4F5F5D);
  static const Color gold = Color(0xFFC5922E);

  static const galleryAssets = [
    'assets/images/lessons/photography/fabric_straight.jpg',
    'assets/images/lessons/read_numbers/post_many_saves.jpg',
    'assets/images/lessons/read_numbers/reply_cloth_post.jpg',
    'assets/images/lessons/photography/fabric_steady.jpg',
    'assets/images/lessons/read_numbers/post_only_likes.jpg',
    'assets/images/lessons/photography/fabric_window.jpg',
  ];

  @override
  State<PickPhotoGuideScreen> createState() => _PickPhotoGuideScreenState();
}

class _PickPhotoGuideScreenState extends State<PickPhotoGuideScreen> {
  late final SpeechPlayer _speech = SpeechPlayer((_) {
    if (mounted) setState(() {});
  });

  int? _selectedIndex;

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  void _selectPhoto(int index) {
    setState(() => _selectedIndex = index);
  }

  void _openDidYouPost() {
    final index = _selectedIndex;
    if (index == null) return;
    _speech.stop();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DidYouPostScreen(
          photoAsset: PickPhotoGuideScreen.galleryAssets[index],
          locale: widget.locale,
          kind: widget.kind,
          isVideo: widget.kind == CreateContentKind.reel,
        ),
      ),
    );
  }

  bool get _isReel => widget.kind == CreateContentKind.reel;

  bool get _isStory => widget.kind == CreateContentKind.story;

  String get _headerTitle {
    return switch (widget.kind) {
      CreateContentKind.reel => 'New reel',
      CreateContentKind.story => 'New story',
      CreateContentKind.post => 'New post',
    };
  }

  String get _spoken {
    return tr(switch (widget.kind) {
      CreateContentKind.reel =>
        'Pick your video. Tap a clip of your weaving, then tap Next.',
      CreateContentKind.story =>
        'Pick your photo for your story. Tap the cloth picture, then tap Next.',
      CreateContentKind.post =>
        'Pick your photo. Tap the cloth picture, then tap Next.',
    });
  }

  String get _guideStep =>
      widget.kind == CreateContentKind.post ? 'STEP 2 OF 4' : 'STEP 3 OF 4';

  String get _guideTitle {
    return switch (widget.kind) {
      CreateContentKind.reel => 'Pick your clip',
      CreateContentKind.story => 'Pick your photo',
      CreateContentKind.post => 'Pick your photo',
    };
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = _selectedIndex != null;
    final previewIndex = _selectedIndex ?? 0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.close_rounded),
                          color: PickPhotoGuideScreen.ink,
                        ),
                        Expanded(
                          child: Text(
                            tr(_headerTitle),
                            textAlign: TextAlign.center,
                            style: appType(
                              color: PickPhotoGuideScreen.ink,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: hasSelection ? _openDidYouPost : null,
                          child: Text(
                            tr('Next'),
                            style: appType(
                              color: hasSelection
                                  ? PickPhotoGuideScreen.teal
                                  : const Color(0xFFB8C5C2),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          SharpImage(
                            PickPhotoGuideScreen.galleryAssets[previewIndex],
                            fit: BoxFit.cover,
                          ),
                          if (_isReel)
                            const ColoredBox(
                              color: Color(0x33000000),
                              child: Center(
                                child: Icon(
                                  Icons.play_circle_fill_rounded,
                                  color: Colors.white,
                                  size: 64,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: GridView.builder(
                      padding: const EdgeInsets.all(2),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 2,
                            crossAxisSpacing: 2,
                          ),
                      itemCount: PickPhotoGuideScreen.galleryAssets.length,
                      itemBuilder: (context, index) {
                        final picked =
                            _selectedIndex != null && index == _selectedIndex;
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            key: ValueKey(
                              _isReel
                                  ? 'gallery-video-$index'
                                  : 'gallery-photo-$index',
                            ),
                            onTap: () => _selectPhoto(index),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                SharpImage(
                                  PickPhotoGuideScreen.galleryAssets[index],
                                  fit: BoxFit.cover,
                                ),
                                if (_isReel)
                                  const ColoredBox(
                                    color: Color(0x26000000),
                                    child: Center(
                                      child: Icon(
                                        Icons.play_circle_outline_rounded,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                if (picked)
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: PickPhotoGuideScreen.gold,
                                        width: 3,
                                      ),
                                    ),
                                    child: const SizedBox.expand(),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: _GuideCard(
                  speech: _speech,
                  locale: widget.locale,
                  spoken: _spoken,
                  stepLabel: _guideStep,
                  title: _guideTitle,
                  nextEnabled: hasSelection,
                  onNext: _openDidYouPost,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({
    required this.speech,
    required this.locale,
    required this.spoken,
    required this.stepLabel,
    required this.title,
    required this.nextEnabled,
    required this.onNext,
  });

  final SpeechPlayer speech;
  final String locale;
  final String spoken;
  final String stepLabel;
  final String title;
  final bool nextEnabled;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PickPhotoGuideScreen.teal, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x28000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: PickPhotoGuideScreen.teal,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CustomPaint(
                    painter: _GemPainter(),
                    size: const Size(44, 44),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr(stepLabel),
                        style: appType(
                          color: PickPhotoGuideScreen.teal,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tr(title),
                        style: appType(
                          color: PickPhotoGuideScreen.ink,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                SpeakCircleButton(
                  playing: speech.playing,
                  onTap: () => speech.toggle(
                    locale: locale,
                    text: spoken,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _dot(filled: true),
                const SizedBox(width: 6),
                _dot(filled: true),
                const SizedBox(width: 6),
                Expanded(child: _dash(filled: true)),
                const SizedBox(width: 6),
                _dot(filled: false),
                const SizedBox(width: 6),
                _dot(filled: false),
                const Spacer(),
                Material(
                  color: nextEnabled
                      ? PickPhotoGuideScreen.teal
                      : const Color(0xFFB8C5C2),
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    onTap: nextEnabled ? onNext : null,
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tr('Next'),
                            style: appType(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot({required bool filled}) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: filled ? PickPhotoGuideScreen.teal : const Color(0xFFD5DEDB),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _dash({required bool filled}) {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: filled ? PickPhotoGuideScreen.teal : const Color(0xFFD5DEDB),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _GemPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF4EBDD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeJoin = StrokeJoin.round;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final w = size.width * 0.34;
    final h = size.height * 0.34;
    final path = Path()
      ..moveTo(cx, cy - h)
      ..lineTo(cx + w, cy)
      ..lineTo(cx, cy + h)
      ..lineTo(cx - w, cy)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
