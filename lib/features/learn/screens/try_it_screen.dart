import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:artisnal_app/core/speech/speech_player.dart';
import 'package:image_picker/image_picker.dart';

import 'package:artisnal_app/core/theme/button_shadow.dart';
import 'package:artisnal_app/core/widgets/speak_circle_button.dart';
import 'package:artisnal_app/core/widgets/sharp_image.dart';
import 'package:artisnal_app/features/learn/widgets/lesson_step.dart';

class TryItScreen extends StatefulWidget {
  const TryItScreen({super.key, required this.locale});

  final String locale;

  static const Color background = Color(0xFFF6F7F4);
  static const Color teal = Color(0xFF1B7574);
  static const Color ink = Color(0xFF152322);

  static const String spoken =
      'Now you try. Hold with two hands, use a plain sheet, stand near a window, and hold the phone straight.';

  @override
  State<TryItScreen> createState() => _TryItScreenState();
}

class _TryItScreenState extends State<TryItScreen> {
  late final SpeechPlayer _speech = SpeechPlayer((_) {
    if (mounted) setState(() {});
  });

  final _picker = ImagePicker();
  Uint8List? _photo;

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  Future<void> _openCamera() async {
    _speech.stop();
    try {
      final file = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 90,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (mounted) setState(() => _photo = bytes);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final photo = _photo;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: TryItScreen.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: PopScope<void>(
        canPop: photo == null,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          final step = LessonStep.maybeOf(context);
          step == null ? Navigator.of(context).pop() : step.onFinished();
        },
        child: Scaffold(
          backgroundColor: TryItScreen.background,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 52,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                          color: TryItScreen.ink,
                          iconSize: 24,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Try it',
                          style: GoogleFonts.plusJakartaSans(
                            color: TryItScreen.ink,
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        SpeakCircleButton(
                          playing: _speech.playing,
                          onTap: () => _speech.toggle(
                            locale: widget.locale,
                            text: TryItScreen.spoken,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Center(
                            child: AspectRatio(
                              aspectRatio: 320 / 223,
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
                                  child: photo != null
                                      ? Image.memory(photo, fit: BoxFit.cover)
                                      : const Padding(
                                          padding: EdgeInsets.all(10),
                                          child: SharpImage(
                                            'assets/images/lessons/photography/try_it_art.jpg',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          photo != null ? 'Nice photo!' : 'Now you try',
                          style: GoogleFonts.plusJakartaSans(
                            color: TryItScreen.ink,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: kPrimaryButtonShadow,
                    ),
                    child: Material(
                      color: TryItScreen.teal,
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        onTap: _openCamera,
                        borderRadius: BorderRadius.circular(18),
                        child: SizedBox(
                          height: 56,
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.photo_camera_outlined,
                                color: Colors.white,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                photo != null ? 'Take again' : 'Open camera',
                                style: GoogleFonts.plusJakartaSans(
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
