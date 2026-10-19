import 'package:flutter/material.dart';

import 'package:artisnal_app/app/phone_frame.dart';
import 'package:artisnal_app/features/onboarding/screens/splash_screen.dart';

class ArtisnalApp extends StatelessWidget {
  const ArtisnalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Click & Social',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF6F7F4),
        colorScheme: ColorScheme.fromSeed(seedColor: SplashScreen.background),
        useMaterial3: true,
      ),
      builder: (context, child) => PhoneFrame(child: child!),
      home: const SplashScreen(),
    );
  }
}
