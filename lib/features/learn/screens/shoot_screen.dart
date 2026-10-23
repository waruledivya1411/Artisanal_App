import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:artisnal_app/core/speech/speech_player.dart';

import 'package:artisnal_app/core/widgets/speak_circle_button.dart';
import 'package:artisnal_app/features/learn/data/display_guides.dart';
import 'package:artisnal_app/features/learn/data/displays.dart';
import 'package:artisnal_app/features/learn/screens/photo_edit_screen.dart';
import 'package:artisnal_app/features/learn/widgets/shot_outline.dart';

/// Live camera with the dotted box the product should fill.
///
/// Pops `true` once a photo is kept, so the caller knows the shot was taken.
class ShootScreen extends StatefulWidget {
  const ShootScreen({
    super.key,
    required this.locale,
    required this.display,
    required this.product,
  });

  final String locale;
  final DisplayOption display;
  final String? product;

  static const Color ink = Color(0xFF152322);
  static const Color teal = Color(0xFF1B7574);

  @override
  State<ShootScreen> createState() => _ShootScreenState();
}

class _ShootScreenState extends State<ShootScreen> with WidgetsBindingObserver {
  late final SpeechPlayer _speech = SpeechPlayer((_) {
    if (mounted) setState(() {});
  });

  late final ShotOutline _outline =
      ShotOutline.forShot(widget.product, widget.display.key);

  bool get _guidedShoot =>
      _outline.kind == ShotOverlayKind.embroideryBorder ||
      _outline.kind == ShotOverlayKind.foldedStack ||
      _outline.kind == ShotOverlayKind.hangingDisplay ||
      _outline.kind == ShotOverlayKind.mekhalaHanging ||
      _outline.kind == ShotOverlayKind.mekhalaFolded ||
      _outline.kind == ShotOverlayKind.stoleFolded ||
      _outline.kind == ShotOverlayKind.shawlFolded ||
      _outline.kind == ShotOverlayKind.gamusaFolded ||
      _outline.kind == ShotOverlayKind.jodFolded ||
      _outline.kind == ShotOverlayKind.jodHanging ||
      _outline.kind == ShotOverlayKind.yardageHanging ||
      _outline.kind == ShotOverlayKind.yardageClose;

  int get _guideStepCount =>
      guideFor(widget.display.key, product: widget.product).length;

  CameraController? _controller;
  String? _problem;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _speech.stop();
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed) {
      _startCamera();
    }
  }

  Future<void> _startCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) setState(() => _problem = 'No camera found on this device.');
        return;
      }
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _problem = null;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _problem = 'The camera could not be opened. Allow '
            'camera access, then try again.');
      }
    }
  }

  /// Shots whose drawing already names the pieces and marks the border have
  /// no dark caption, so that text does not cover the border.
  String? get _hint {
    if (_outline.kind == ShotOverlayKind.embroideryBorder) return null;
    if (_outline.kind == ShotOverlayKind.foldedStack) {
      return 'One folded sari in this box — border on the side';
    }
    if (_outline.kind == ShotOverlayKind.mekhalaFolded) return null;
    if (_outline.kind == ShotOverlayKind.stoleFolded) {
      return 'One folded stole — border and tassels along the front';
    }
    if (_outline.kind == ShotOverlayKind.shawlFolded) {
      return 'One folded shawl — border on the side, tassels along the front';
    }
    if (_outline.kind == ShotOverlayKind.gamusaFolded) {
      return 'One folded gamusa — end border across, tassels along the front';
    }
    if (_outline.kind == ShotOverlayKind.jodFolded) {
      return 'Wide fold on the left · smaller piece with tassels on the right';
    }
    if (_outline.kind == ShotOverlayKind.hangingDisplay) {
      return 'Hang the piece in the centre, under the rod';
    }
    if (_outline.kind == ShotOverlayKind.mekhalaHanging) {
      return 'Hang both pieces under the rod — mekhela shorter, sador with tassels';
    }
    if (_outline.kind == ShotOverlayKind.jodHanging) {
      return 'Hang both pieces under the rod — wide cloth on the left, tassels on the right';
    }
    if (_outline.kind == ShotOverlayKind.yardageHanging) {
      return 'Hang the cloth under the rod — motifs across the whole piece';
    }
    if (_outline.kind == ShotOverlayKind.yardageClose) {
      return 'Fill the frame with the weave — a few motifs in the shot';
    }
    if (_outline.kind == ShotOverlayKind.mekhalaFull) {
      return 'Lay both pieces side by side in the frame';
    }
    if (_outline.kind == ShotOverlayKind.stoleFull) {
      return 'Hang the stole under the rod — tassels along the bottom';
    }
    if (_outline.kind == ShotOverlayKind.shawlFull) {
      return 'Hang the shawl under the rod — border on the side, tassels along the bottom';
    }
    if (_outline.kind == ShotOverlayKind.gamusaFull) {
      return 'Hang the gamusa under the rod — borders on both sides, tassels along the bottom';
    }
    if (_outline.kind == ShotOverlayKind.cushionSofa) {
      return 'Sit the cover against the back — only this side of the sofa in frame';
    }
    if (_outline.kind == ShotOverlayKind.cushionFlat) {
      return 'Lay the cover flat — all four corners in the frame';
    }
    if (_outline.kind == ShotOverlayKind.sariDraped) {
      return 'Chair, folded seat piece and pallu inside this box';
    }
    if (_outline.silhouette == ShotSilhouette.draped) {
      return 'Cover the pale shape with your cloth';
    }
    if (_outline.silhouette == ShotSilhouette.foldedSari) {
      return 'One folded sari in this box — border on the side';
    }
    final product = widget.product?.toLowerCase();
    return product == null
        ? 'Fit the whole piece inside the dotted line'
        : 'Fit the $product inside the dotted line';
  }

  /// The one thing to do next, called out in yellow.
  String get _prompt {
    if (_outline.kind == ShotOverlayKind.mekhalaFull ||
        _outline.kind == ShotOverlayKind.mekhalaHanging ||
        _outline.kind == ShotOverlayKind.mekhalaFolded ||
        _outline.kind == ShotOverlayKind.jodHanging ||
        _outline.kind == ShotOverlayKind.jodFolded) {
      return 'Move both pieces into the frame';
    }
    if (_outline.kind == ShotOverlayKind.stoleFolded) {
      return 'Move the stole into the frame';
    }
    if (_outline.kind == ShotOverlayKind.shawlFolded) {
      return 'Move the shawl into the frame';
    }
    if (_outline.kind == ShotOverlayKind.gamusaFull ||
        _outline.kind == ShotOverlayKind.gamusaFolded) {
      return 'Move the gamusa into the frame';
    }
    if (_outline.kind == ShotOverlayKind.cushionSofa ||
        _outline.kind == ShotOverlayKind.cushionFlat) {
      return 'Move the cover into the frame';
    }
    if (_outline.kind == ShotOverlayKind.sariDraped) {
      return 'Move the saree into the frame';
    }
    if (_outline.kind == ShotOverlayKind.yardageHanging ||
        _outline.kind == ShotOverlayKind.yardageClose) {
      return 'Move the yardage into the frame';
    }
    if (_guidedShoot) {
      return 'Move the saree into the frame';
    }
    final product = widget.product?.toLowerCase() ?? 'piece';
    return 'Move the $product into the frame';
  }

  String get _headerTitle {
    switch (_outline.kind) {
      case ShotOverlayKind.embroideryBorder:
        return widget.display.name.toUpperCase().replaceAll(' AND ', ' & ');
      case ShotOverlayKind.foldedStack:
      case ShotOverlayKind.mekhalaFolded:
      case ShotOverlayKind.stoleFolded:
      case ShotOverlayKind.shawlFolded:
      case ShotOverlayKind.gamusaFolded:
      case ShotOverlayKind.jodFolded:
        return 'FOLDED STACK';
      case ShotOverlayKind.hangingDisplay:
      case ShotOverlayKind.mekhalaHanging:
      case ShotOverlayKind.jodHanging:
      case ShotOverlayKind.yardageHanging:
        return 'HANGING DISPLAY';
      case ShotOverlayKind.mekhalaFull:
      case ShotOverlayKind.stoleFull:
      case ShotOverlayKind.shawlFull:
      case ShotOverlayKind.gamusaFull:
      case ShotOverlayKind.cushionSofa:
      case ShotOverlayKind.cushionFlat:
      case ShotOverlayKind.yardageClose:
      case ShotOverlayKind.standard:
        return widget.display.name.toUpperCase();
      case ShotOverlayKind.sariDraped:
        return 'DRAPED LOOK';
    }
  }

  String? get _headerProduct =>
      _guidedShoot || _outline.kind == ShotOverlayKind.sariDraped
          ? (widget.product ?? 'Saree')
          : null;

  String get _spokenText => '${widget.display.name}. ${_hint ?? _prompt}.';

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _busy) return;
    setState(() => _busy = true);
    try {
      final file = await controller.takePicture();
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() => _busy = false);
      final outcome = await Navigator.of(context).push<PhotoEditOutcome>(
        MaterialPageRoute<PhotoEditOutcome>(
          builder: (_) => PhotoEditScreen(imageBytes: bytes),
        ),
      );
      if (!mounted ||
          outcome == null ||
          outcome == PhotoEditOutcome.cancelled) {
        return;
      }
      final savedToGallery = outcome == PhotoEditOutcome.saved;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            savedToGallery
                ? 'Saved to your gallery'
                : 'Photo downloaded',
          ),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(() => _problem = 'That shot did not save. Try again.');
      }
    } finally {
      if (mounted && _busy) setState(() => _busy = false);
    }
  }

  final _stackKey = GlobalKey();
  final _topControlsKey = GlobalKey();
  final _bottomControlsKey = GlobalKey();

  /// Where the pills end and the bottom text begins, plus a 16px margin, so
  /// the box can be centred on the photo without running under either.
  double? _clearTop;
  double? _clearBottom;

  void _measureControls() {
    if (!mounted) return;
    RenderBox? box(GlobalKey key) =>
        key.currentContext?.findRenderObject() as RenderBox?;
    final stack = box(_stackKey);
    final top = box(_topControlsKey);
    final bottom = box(_bottomControlsKey);
    if (stack == null || top == null || bottom == null) return;
    if (!stack.hasSize || !top.hasSize || !bottom.hasSize) return;
    final clearTop = stack
            .globalToLocal(top.localToGlobal(Offset(0, top.size.height)))
            .dy +
        8;
    final clearBottom =
        stack.globalToLocal(bottom.localToGlobal(Offset.zero)).dy - 8;
    if ((clearTop - (_clearTop ?? -1)).abs() < 0.5 &&
        (clearBottom - (_clearBottom ?? -1)).abs() < 0.5) {
      return;
    }
    setState(() {
      _clearTop = clearTop;
      _clearBottom = clearBottom;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Re-measure after every layout: captions, screen size and rotation all
    // move the controls. It only rebuilds when something actually moved.
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureControls());
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          key: _stackKey,
          fit: StackFit.expand,
          children: [
            _preview(),
            ShotOutlineOverlay(
              outline: _outline,
              clearTop: _clearTop,
              clearBottom: _clearBottom,
            ),
            SafeArea(
              child: Column(
                children: [
                  Column(
                    key: _topControlsKey,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _outline.kind == ShotOverlayKind.sariDraped
                          ? _guidedTopBar()
                          : _guidedShoot
                              ? _guidedTopBar()
                              : _topBar(),
                      _guidedShoot ? _guidedCheckPills() : _checkPills(),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    key: _bottomControlsKey,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_hint != null) ...[
                        _hintBar(),
                        const SizedBox(height: 8),
                      ],
                      _promptPill(),
                      const SizedBox(height: 14),
                      _shutterRow(),
                    ],
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _preview() {
    final controller = _controller;
    if (controller != null && controller.value.isInitialized) {
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.previewSize?.height ?? 1080,
          height: controller.value.previewSize?.width ?? 1920,
          child: CameraPreview(controller),
        ),
      );
    }
    return ColoredBox(
      color: const Color(0xFF101614),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _problem == null
                    ? Icons.photo_camera_outlined
                    : Icons.no_photography_outlined,
                color: Colors.white70,
                size: 34,
              ),
              const SizedBox(height: 12),
              Text(
                _problem ?? 'Opening the camera…',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white70,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded),
            color: Colors.white,
            iconSize: 24,
          ),
          Expanded(
            child: Text(
              _headerTitle,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ),
          SpeakCircleButton(
            playing: _speech.playing,
            onTap: () =>
                _speech.toggle(locale: widget.locale, text: _spokenText),
          ),
        ],
      ),
    );
  }

  Widget _guidedTopBar() {
    final product = _headerProduct;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded),
            color: Colors.white,
            iconSize: 24,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _headerTitle,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    height: 1.2,
                  ),
                ),
                if (product != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    product,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '$_guideStepCount / $_guideStepCount',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _guidedCheckPills() {
    const rows = <(String, String, Color)>[
      ('Light', 'OK', Color(0xFF3D9B5A)),
      ('Distance', 'Move back', Color(0xFFE0A82E)),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: _guidedStatusPill(
                label: rows[i].$1,
                status: rows[i].$2,
                statusColor: rows[i].$3,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _guidedStatusPill({
    required String label,
    required String status,
    required Color statusColor,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x990E1413),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            DecoratedBox(
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                child: Text(
                  status,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Reminders of the things that spoil a shot.
  Widget _checkPills() {
    const checks = <(IconData, String)>[
      (Icons.wb_sunny_outlined, 'Light'),
      (Icons.straighten_rounded, 'Distance'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          for (final (icon, label) in checks)
            DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0x8C0E1413),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0x4DFFFFFF)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.white, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      label,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _promptPill() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFF5C84C),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(
            _prompt,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF2A2109),
              fontSize: 14,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _hintBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xCC0E1413),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(
            _hint ?? _prompt,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _shutterRow() {
    final ready = _controller?.value.isInitialized ?? false;
    return Semantics(
      button: true,
      label: 'Take photo',
      child: GestureDetector(
        onTap: ready && !_busy ? _capture : null,
        child: Container(
          width: 74,
          height: 74,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: ready ? 1 : 0.4),
            border: Border.all(color: const Color(0x66FFFFFF), width: 5),
          ),
          child: _busy
              ? const Padding(
                  padding: EdgeInsets.all(22),
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: ShootScreen.teal,
                  ),
                )
              : const Icon(
                  Icons.photo_camera_rounded,
                  color: ShootScreen.ink,
                  size: 30,
                ),
        ),
      ),
    );
  }

}
