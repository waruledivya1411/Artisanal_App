import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';

import 'package:artisnal_app/core/gallery/save_photo.dart';
import 'package:artisnal_app/features/learn/data/photo_edit.dart';
import 'package:artisnal_app/features/learn/widgets/crop_box.dart';
import 'package:artisnal_app/core/l10n/app_text.dart';

enum PhotoEditOutcome { cancelled, saved, downloaded }

enum _EditTool { cut, turn, bright, white }

/// Edit screen shown after a photography capture.
class PhotoEditScreen extends StatefulWidget {
  const PhotoEditScreen({super.key, required this.imageBytes});

  final Uint8List imageBytes;

  static const Color background = Color(0xFF102624);
  static const Color teal = Color(0xFF1B7574);
  static const Color toolIdle = Color(0xFF1C3331);

  @override
  State<PhotoEditScreen> createState() => _PhotoEditScreenState();
}

class _PhotoEditScreenState extends State<PhotoEditScreen> {
  _EditTool _tool = _EditTool.bright;
  Rect _crop = PhotoEdits.fullFrame;
  int _quarterTurns = 0;
  double _brightness = 0;
  double _white = 0;
  bool _saving = false;

  /// Width over height of the photo as taken; known once it is decoded.
  double? _photoAspect;

  @override
  void initState() {
    super.initState();
    decodeImageFromList(widget.imageBytes).then((image) {
      final aspect = image.width / image.height;
      image.dispose();
      if (mounted) setState(() => _photoAspect = aspect);
    });
  }

  /// The photo's shape after turning.
  double? get _shownAspect {
    final aspect = _photoAspect;
    if (aspect == null) return null;
    return _quarterTurns.isOdd ? 1 / aspect : aspect;
  }

  PhotoEdits get _edits => PhotoEdits(
        crop: _crop,
        quarterTurns: _quarterTurns,
        brightness: _brightness,
        white: _white,
      );

  void _reset() {
    setState(() {
      _crop = PhotoEdits.fullFrame;
      _quarterTurns = 0;
      _brightness = 0;
      _white = 0;
    });
  }

  void _select(_EditTool tool) {
    setState(() {
      if (tool == _EditTool.turn && _tool == _EditTool.turn) {
        _quarterTurns = (_quarterTurns + 1) % 4;
        _crop = PhotoEdits.fullFrame;
      }
      _tool = tool;
    });
  }

  double get _sliderValue => switch (_tool) {
        _EditTool.cut => 0,
        _EditTool.turn => (_quarterTurns % 4) / 3,
        _EditTool.bright => ((_brightness + 0.35) / 0.8).clamp(0, 1),
        _EditTool.white => ((_white + 1) / 2).clamp(0, 1),
      };

  void _onSlider(double value) {
    setState(() {
      switch (_tool) {
        case _EditTool.cut:
          break;
        case _EditTool.turn:
          final turns = (value * 3).round() % 4;
          if (turns != _quarterTurns) _crop = PhotoEdits.fullFrame;
          _quarterTurns = turns;
        case _EditTool.bright:
          _brightness = value * 0.8 - 0.35;
        case _EditTool.white:
          _white = value * 2 - 1;
      }
    });
  }

  String get _sliderHint => switch (_tool) {
        _EditTool.cut => 'Cut — drag the corners or edges to crop',
        _EditTool.turn => 'Turn — slide, or tap Turn again',
        _EditTool.bright => 'Bright — slide to lighten or darken',
        _EditTool.white => 'White — slide from cool to warm',
      };

  Future<void> _finish() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final bytes = _edits.isIdentity
          ? widget.imageBytes
          : await compute(
              _bakeMessage,
              (
                widget.imageBytes,
                (_crop.left, _crop.top, _crop.right, _crop.bottom),
                _quarterTurns,
                _brightness,
                _white,
              ),
            );
      final saved = await savePhotoBytes(bytes);
      if (!mounted) return;
      Navigator.of(context).pop(
        saved.kind == PhotoSaveKind.download
            ? PhotoEditOutcome.downloaded
            : PhotoEditOutcome.saved,
      );
    } on GalException {
      if (!mounted) return;
      setState(() => _saving = false);
      _showError('Could not save. Allow photo access, then try again.');
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showError('Could not save that photo. Try again.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tr(message), style: appType()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: PhotoEditScreen.background,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: PhotoEditScreen.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Column(
              children: [
                _header(),
                const SizedBox(height: 8),
                Expanded(child: _previewCard()),
                const SizedBox(height: 16),
                if (_tool == _EditTool.cut)
                  const SizedBox(height: 48)
                else
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    activeTrackColor: const Color(0xFFD7E0DD),
                    inactiveTrackColor: const Color(0xFF3D524F),
                    thumbColor: Colors.white,
                    overlayColor: Colors.white24,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 11,
                    ),
                  ),
                  child: Slider(
                    value: _sliderValue,
                    divisions: _tool == _EditTool.turn ? 3 : null,
                    onChanged: _saving ? null : _onSlider,
                  ),
                ),
                Text(
                  tr(_sliderHint),
                  textAlign: TextAlign.center,
                  style: appType(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _toolButton(
                      tool: _EditTool.cut,
                      icon: Icons.crop_rounded,
                      label: 'Cut',
                    ),
                    _toolButton(
                      tool: _EditTool.turn,
                      icon: Icons.rotate_right_rounded,
                      label: 'Turn',
                    ),
                    _toolButton(
                      tool: _EditTool.bright,
                      icon: Icons.wb_sunny_rounded,
                      label: 'Bright',
                    ),
                    _toolButton(
                      tool: _EditTool.white,
                      icon: Icons.colorize_rounded,
                      label: 'White',
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: _saving ? null : _finish,
                    style: FilledButton.styleFrom(
                      backgroundColor: PhotoEditScreen.teal,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          PhotoEditScreen.teal.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_rounded, size: 22),
                    label: Text(
                      tr('Save'),
                      style: appType(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
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

  Widget _header() {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          IconButton(
            onPressed: _saving
                ? null
                : () => Navigator.of(context).pop(PhotoEditOutcome.cancelled),
            icon: const Icon(Icons.close_rounded),
            color: Colors.white,
          ),
          Expanded(
            child: Text(
              tr('Edit'),
              textAlign: TextAlign.center,
              style: appType(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: _saving ? null : _reset,
            child: Text(
              tr('Reset'),
              style: appType(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _previewCard() {
    final aspect = _shownAspect;
    // The photo, turned and toned, filling whatever box it is given.
    final photo = ColorFiltered(
      colorFilter: ColorFilter.matrix(_colorMatrix(_brightness, _white)),
      child: RotatedBox(
        quarterTurns: _quarterTurns,
        child: Image.memory(
          widget.imageBytes,
          fit: BoxFit.fill,
          gaplessPlayback: true,
        ),
      ),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ColoredBox(
          color: const Color(0xFFF4F1EA),
          child: aspect == null
              ? const SizedBox.expand()
              : _tool == _EditTool.cut
              ? CropBox(
                  photo: photo,
                  photoAspect: aspect,
                  crop: _crop,
                  onChanged: _saving
                      ? (_) {}
                      : (crop) => setState(() => _crop = crop),
                )
              : CroppedPhoto(photo: photo, photoAspect: aspect, crop: _crop),
        ),
      ),
    );
  }

  Widget _toolButton({
    required _EditTool tool,
    required IconData icon,
    required String label,
  }) {
    final selected = _tool == tool;
    return InkWell(
      onTap: _saving ? null : () => _select(tool),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: selected ? Colors.white : PhotoEditScreen.toolIdle,
                shape: BoxShape.circle,
              ),
              child: SizedBox(
                width: 56,
                height: 56,
                child: Icon(
                  icon,
                  color: selected ? PhotoEditScreen.teal : Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              tr(label),
              style: appType(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<double> _colorMatrix(double brightness, double white) {
  final lift = brightness * 255;
  final warm = white * 48;
  return <double>[
    1, 0, 0, 0, lift + warm,
    0, 1, 0, 0, lift,
    0, 0, 1, 0, lift - warm,
    0, 0, 0, 1, 0,
  ];
}

Uint8List _bakeMessage(
  (Uint8List, (double, double, double, double), int, double, double) message,
) {
  final (left, top, right, bottom) = message.$2;
  return bakePhotoEdits(
    message.$1,
    PhotoEdits(
      crop: Rect.fromLTRB(left, top, right, bottom),
      quarterTurns: message.$3,
      brightness: message.$4,
      white: message.$5,
    ),
  );
}
