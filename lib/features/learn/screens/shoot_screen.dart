import 'dart:ui' show ImageFilter;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:artisnal_app/features/learn/data/displays.dart';
import 'package:artisnal_app/features/learn/data/materials.dart';
import 'package:artisnal_app/features/learn/data/photo_edit.dart';
import 'package:artisnal_app/features/learn/screens/photo_edit_screen.dart';
import 'package:artisnal_app/features/learn/widgets/shot_outline.dart';
import 'package:artisnal_app/core/l10n/app_text.dart';

/// Live camera in an upright 4:3 photo area, with the dotted box the product
/// should fill. Black above and below, holding only Back and the shutter.
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
  late final ShotOutline _outline =
      ShotOutline.forShot(widget.product, widget.display.key);

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
    _controller?.dispose();
    super.dispose();
  }

  /// Set while the camera is being opened, so a resume that arrives during
  /// it - the permission prompt on a phone causes one - does not open it
  /// a second time.
  bool _starting = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Give the camera up while the app is out of view and take it back on
    // return. A browser tab only loses focus on `inactive` - a download
    // prompt, a click elsewhere - so there it is kept until the tab hides.
    final release = kIsWeb
        ? state == AppLifecycleState.hidden ||
              state == AppLifecycleState.paused
        : state == AppLifecycleState.inactive;
    if (release) {
      final controller = _controller;
      if (controller == null) return;
      setState(() => _controller = null);
      controller.dispose();
    } else if (state == AppLifecycleState.resumed && _controller == null) {
      _startCamera();
    }
  }

  Future<void> _startCamera() async {
    if (_starting) return;
    _starting = true;
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) setState(() => _problem = tr('No camera found on this device.'));
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
        setState(() => _problem = tr(
              'The camera could not be opened. Allow camera access, then try again.',
            ));
      }
    } finally {
      _starting = false;
    }
  }

  /// Cuts the shot down to the 4:3 photo area, so the saved picture is
  /// exactly what the artisan saw.
  Future<Uint8List> _cropToPhoto(Uint8List bytes) async {
    final aspect = _previewAspect;
    if (aspect == null) return bytes;

    // The live picture covers the 3:4 photo area, centred.
    const photo = Size(3, 4);
    var shownWidth = photo.width;
    var shownHeight = shownWidth / aspect;
    if (shownHeight < photo.height) {
      shownHeight = photo.height;
      shownWidth = shownHeight * aspect;
    }
    final left = (shownWidth - photo.width) / 2 / shownWidth;
    final top = (shownHeight - photo.height) / 2 / shownHeight;
    final region = (left, top, 1 - left, 1 - top);
    try {
      return await compute(_cropMessage, (bytes, aspect, region));
    } catch (_) {
      return bytes;
    }
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _busy) return;
    setState(() => _busy = true);
    try {
      final file = await controller.takePicture();
      final bytes = await _cropToPhoto(await file.readAsBytes());
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
            tr(
              savedToGallery
                  ? 'Saved to your gallery'
                  : 'Photo downloaded',
            ),
          ),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(
          () => _problem = tr('That shot did not save. Try again.'),
        );
      }
    } finally {
      if (mounted && _busy) setState(() => _busy = false);
    }
  }

  /// Width over height of the live picture as it is laid out. On a phone
  /// the camera reports its size lying down, so it is turned upright; a
  /// browser reports the picture the way it is shown.
  double? get _previewAspect {
    final size = _controller?.value.previewSize;
    if (size == null || size.width == 0 || size.height == 0) return null;
    return kIsWeb ? size.width / size.height : size.height / size.width;
  }

  /// The good example photo for this display, faded over the live picture,
  /// for products the artisan lines up against the photo itself rather than
  /// a drawing. It follows the material picked, as the guide does. Null for
  /// every other product.
  String? get _ghostPhoto {
    if (!_ghostProducts.contains(widget.product)) return null;
    // Draped and full display have their own dotted drawings, for Mekhala
    // sador as for a saree.
    if (widget.display.key == 'draped_look' ||
        widget.display.key == 'full_display') {
      return null;
    }
    final material = SelectedMaterial.instance.name ?? 'Cotton';
    return widget.display.imageFor(material, product: widget.product);
  }

  static const _ghostProducts = {'Mekhala sador', 'Cushion covers'};

  /// The reference photo for [_ghostPhoto]. A cushion photo is wider than
  /// the 4:3 frame, so it is shown whole - cropping would cut the cushion
  /// off - over a blurred copy of itself that fills the rest of the frame.
  Widget _ghostImage(String asset) {
    Widget image(BoxFit fit) => Image.asset(
          asset,
          fit: fit,
          errorBuilder: (context, error, stack) => const SizedBox.shrink(),
        );
    if (widget.product != 'Cushion covers') return image(BoxFit.cover);
    return Stack(
      fit: StackFit.expand,
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: image(BoxFit.cover),
        ),
        image(BoxFit.contain),
      ],
    );
  }

  /// Height of the black band above the photo, which holds only Back.
  static const double _topBand = 56;

  /// Least room left under the photo for the shutter.
  static const double _minBottomBand = 112;

  @override
  Widget build(BuildContext context) {
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
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Like a phone camera: an upright 4:3 photo as wide as the
              // screen, black above and below. A short screen narrows it.
              var width = constraints.maxWidth;
              var height = width * 4 / 3;
              final room =
                  constraints.maxHeight - _topBand - _minBottomBand;
              if (height > room) {
                height = room;
                width = height * 3 / 4;
              }
              return Column(
                children: [
                  SizedBox(
                    height: _topBand,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        tooltip: tr('Back'),
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: Colors.white,
                        iconSize: 24,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    height: height,
                    child: ClipRect(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _preview(),
                          // Only over the live picture - not while the camera
                          // is still opening or could not open.
                          if (_ghostPhoto case final ghost?) ...[
                            if (_controller?.value.isInitialized ?? false)
                              IgnorePointer(
                                child: Opacity(
                                  opacity: 0.5,
                                  child: _ghostImage(ghost),
                                ),
                              ),
                          ]
                          else
                            ShotOutlineOverlay(
                              outline: _outline,
                              locale: widget.locale,
                            ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(child: Center(child: _shutterRow())),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _preview() {
    final controller = _controller;
    if (controller != null && controller.value.isInitialized) {
      final size = controller.value.previewSize;
      // In a browser the picture is shown as it comes, so the box takes the
      // picture's own shape and nothing is cut before the screen crops it.
      if (kIsWeb && size != null) {
        return FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: controller.buildPreview(),
          ),
        );
      }
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: size?.height ?? 1080,
          height: size?.width ?? 1920,
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
                tr(_problem ?? 'Opening the camera…'),
                textAlign: TextAlign.center,
                style: appType(
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

  Widget _shutterRow() {
    final ready = _controller?.value.isInitialized ?? false;
    return Semantics(
      button: true,
      label: tr('Take photo'),
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

Uint8List _cropMessage(
  (Uint8List, double, (double, double, double, double)) message,
) =>
    cropToPreviewRegion(message.$1, message.$2, message.$3);
