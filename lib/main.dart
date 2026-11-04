import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:artisnal_app/app/app.dart';
import 'package:artisnal_app/features/learn/data/saved_work.dart';
import 'package:artisnal_app/features/onboarding/screens/splash_screen.dart';

Future<void> main() async {
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
  await loadSavedData();
  runApp(const ArtisnalApp());
}
