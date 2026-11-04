import 'package:flutter/material.dart';

import 'package:artisnal_app/core/l10n/app_text.dart';
import 'package:artisnal_app/core/theme/button_shadow.dart';
import 'package:artisnal_app/features/learn/data/saved_work.dart';

/// Practice writing a caption for a post. What they write is kept, and shows
/// again under the Create a post badge.
class WriteCaptionScreen extends StatefulWidget {
  const WriteCaptionScreen({super.key, required this.nextBuilder});

  final WidgetBuilder nextBuilder;

  static const Color background = Color(0xFFF6F7F4);
  static const Color teal = Color(0xFF1B7574);
  static const Color ink = Color(0xFF152322);
  static const Color muted = Color(0xFF4F5F5D);
  static const Color cardBorder = Color(0xFFE4EEEC);
  static const Color waiting = Color(0xFF8DBAB9);

  @override
  State<WriteCaptionScreen> createState() => _WriteCaptionScreenState();
}

class _WriteCaptionScreenState extends State<WriteCaptionScreen> {
  late final TextEditingController _text = TextEditingController(
    text: SavedWork.instance.caption ?? '',
  )..addListener(_onChanged);

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _continue() {
    SavedWork.instance.saveCaption(_text.text.trim());
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute<void>(builder: widget.nextBuilder));
  }

  @override
  Widget build(BuildContext context) {
    final ready = _text.text.trim().isNotEmpty;
    return Scaffold(
      backgroundColor: WriteCaptionScreen.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  tooltip: tr('Back'),
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: WriteCaptionScreen.ink,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Text(
                      tr('Write your caption'),
                      style: appType(
                        color: WriteCaptionScreen.ink,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tr('Say what it is and how to order'),
                      style: appType(
                        color: WriteCaptionScreen.muted,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      key: const ValueKey('caption-text'),
                      controller: _text,
                      minLines: 4,
                      maxLines: 6,
                      style: appType(
                        color: WriteCaptionScreen.ink,
                        fontSize: 15,
                        height: 1.4,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: _border(WriteCaptionScreen.cardBorder),
                        enabledBorder: _border(WriteCaptionScreen.cardBorder),
                        focusedBorder: _border(WriteCaptionScreen.teal),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      tr('Tap one to use it'),
                      style: appType(
                        color: WriteCaptionScreen.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (final idea in captionIdeas)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Material(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(
                              color: WriteCaptionScreen.cardBorder,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => _text.text = tr(idea),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                tr(idea),
                                style: appType(
                                  color: WriteCaptionScreen.ink,
                                  fontSize: 14,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: kPrimaryButtonShadow,
                ),
                child: Material(
                  color: ready
                      ? WriteCaptionScreen.teal
                      : WriteCaptionScreen.waiting,
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    onTap: ready ? _continue : null,
                    borderRadius: BorderRadius.circular(18),
                    child: SizedBox(
                      height: 56,
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
    );
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: color),
  );
}
