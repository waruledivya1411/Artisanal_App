import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:artisnal_app/app/app.dart';
import 'package:artisnal_app/features/onboarding/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: SplashScreen.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const ArtisnalApp());
}
