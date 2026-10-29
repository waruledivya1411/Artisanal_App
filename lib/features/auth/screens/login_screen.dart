import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:artisnal_app/core/theme/button_shadow.dart';
import 'package:artisnal_app/features/auth/screens/forgot_password_screen.dart';
import 'package:artisnal_app/features/onboarding/screens/language_picker_screen.dart';
import 'package:artisnal_app/core/widgets/fit_or_scroll.dart';
import 'package:artisnal_app/core/l10n/app_text.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const Color background = Color(0xFFF6F7F4);
  static const Color teal = Color(0xFF1B7574);
  static const Color ink = Color(0xFF152322);
  static const Color muted = Color(0xFF4F5F5D);

  static const Color fieldBorder = Color(0xFFE4EEEC);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hidePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _continue() {
    FocusScope.of(context).unfocus();
    // Pushed, not replaced, so Back on the language screen returns here.
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, _, _) => const LanguagePickerScreen(),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _openForgotPassword() {
    _passwordController.clear();
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ForgotPasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: LoginScreen.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: LoginScreen.background,
        // One fixed page, no scrolling: the keyboard slides over the
        // bottom rather than pushing the layout up.
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => FitOrScroll(
              height: constraints.maxHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(flex: 3),
                    const _AppTitle(),
                    const Spacer(flex: 2),
                    Text(
                      tr('Log in'),
                      style: appType(
                        color: LoginScreen.ink,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tr('Use your email and password to open your lessons.'),
                      style: appType(
                        color: LoginScreen.muted,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: LoginScreen.fieldBorder),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0F000000),
                            blurRadius: 24,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 18, 16, 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _AuthField(
                              controller: _emailController,
                              label: 'Email',
                              hint: 'you@example.com',
                              icon: Icons.mail_outline_rounded,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 14),
                            _AuthField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: 'Your password',
                              icon: Icons.lock_outline_rounded,
                              obscure: _hidePassword,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _continue(),
                              trailing: IconButton(
                                tooltip: tr(
                                  _hidePassword
                                      ? 'Show password'
                                      : 'Hide password',
                                ),
                                onPressed: () => setState(
                                  () => _hidePassword = !_hidePassword,
                                ),
                                icon: Icon(
                                  _hidePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                color: LoginScreen.muted,
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _openForgotPassword,
                                style: TextButton.styleFrom(
                                  foregroundColor: LoginScreen.teal,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 10,
                                  ),
                                ),
                                child: Text(
                                  tr('Forgot password?'),
                                  style: appType(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: kPrimaryButtonShadow,
                      ),
                      child: Material(
                        color: LoginScreen.teal,
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          onTap: _continue,
                          borderRadius: BorderRadius.circular(18),
                          child: SizedBox(
                            key: const ValueKey('login-submit'),
                            height: 56,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  tr('Log in'),
                                  style: appType(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(flex: 4),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The app's name, large, in its own teal - the page belongs to the app.
class _AppTitle extends StatelessWidget {
  const _AppTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          tr('Click & Social'),
          textAlign: TextAlign.center,
          style: appType(
            color: LoginScreen.teal,
            fontSize: 36,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: 44,
          height: 4,
          decoration: BoxDecoration(
            color: LoginScreen.teal.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.trailing,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: LoginScreen.fieldBorder),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(label),
          style: appType(
            color: LoginScreen.ink,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
          style: appType(
            color: LoginScreen.ink,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: tr(hint),
            hintStyle: appType(
              color: LoginScreen.muted.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Icon(icon, color: LoginScreen.muted, size: 20),
            suffixIcon: trailing,
            filled: true,
            fillColor: LoginScreen.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: border,
            enabledBorder: border,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: LoginScreen.teal, width: 1.8),
            ),
          ),
        ),
      ],
    );
  }
}
