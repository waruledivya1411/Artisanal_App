import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:artisnal_app/features/auth/screens/login_screen.dart';
import 'package:artisnal_app/core/l10n/app_text.dart';

/// The opening screen: the name rises in letter by letter, a gold line sweeps
/// under it, and the tagline fades up.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const Color background = Color(0xFF1B7574);
  static const Color gold = Color(0xFFE3B65B);

  /// How long the screen stays before the log in page.
  static const Duration showFor = Duration(milliseconds: 3000);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _animationLength = Duration(milliseconds: 2100);

  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: _animationLength,
  );
  Timer? _timer;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(SplashScreen.showFor, _openLogin);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    // Someone who has asked for less motion sees the finished screen.
    if (MediaQuery.disableAnimationsOf(context)) {
      _animation.value = 1;
    } else {
      _animation.forward();
    }
  }

  void _openLogin() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, _, _) => const LoginScreen(),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animation.dispose();
    super.dispose();
  }

  /// How far along a stretch of the animation is, from 0 to 1, between two
  /// moments given in milliseconds.
  double _progress(int fromMs, int toMs, {Curve curve = Curves.easeOutCubic}) {
    final total = _animationLength.inMilliseconds;
    return curve.transform(
      ((_animation.value * total - fromMs) / (toMs - fromMs)).clamp(0.0, 1.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final title = tr('Click & Social');
    final titleStyle = TextStyle(
      color: Colors.white,
      fontSize: width * 0.111,
      fontWeight: FontWeight.w600,
      letterSpacing: width * 0.003,
      height: 1.1,
    );
    final letters = title.characters.toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: SplashScreen.background,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: SplashScreen.background,
        body: Align(
          alignment: const Alignment(0, 0.18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, _) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Semantics(
                    key: const ValueKey('splash-title'),
                    label: title,
                    child: ExcludeSemantics(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (final (index, letter) in letters.indexed)
                              _letter(letter, index, titleStyle),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: width * 0.035),
                  // The line grows out from the middle.
                  Transform.scale(
                    scaleX: _progress(1000, 1450),
                    child: Container(
                      width: width * 0.3,
                      height: 3,
                      decoration: BoxDecoration(
                        color: SplashScreen.gold,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: width * 0.04),
                  Opacity(
                    opacity: _progress(1400, 2100),
                    child: Transform.translate(
                      offset: Offset(0, 12 * (1 - _progress(1400, 2100))),
                      child: Text(
                        tr('Show your craft to the world'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: (width * 0.045).clamp(14.0, 20.0),
                          fontWeight: FontWeight.w500,
                          height: 1.3,
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

  Widget _letter(String letter, int index, TextStyle style) {
    final start = index * 55;
    final shown = _progress(start, start + 450);
    return Opacity(
      opacity: shown,
      child: Transform.translate(
        offset: Offset(0, style.fontSize! * 0.55 * (1 - shown)),
        child: Text(letter == ' ' ? ' ' : letter, style: style),
      ),
    );
  }
}
