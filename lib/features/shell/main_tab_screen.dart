import 'package:flutter/material.dart';

import 'package:artisnal_app/core/widgets/app_bottom_nav.dart';
import 'package:artisnal_app/features/learn/data/learn_tasks.dart';
import 'package:artisnal_app/features/learn/screens/learn_home_screen.dart';
import 'package:artisnal_app/features/me/screens/me_screen.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key, required this.locale});

  final String locale;

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  AppNavTab _tab = AppNavTab.learn;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LearnHomeScreen.background,
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _tab == AppNavTab.me ? 1 : 0,
              children: [
                LearnHomeScreen(
                  locale: widget.locale,
                  showBottomNav: false,
                ),
                const MeScreen(),
              ],
            ),
          ),
          AppBottomNav(
            selectedTab: _tab,
            onLearnTap: () => setState(() => _tab = AppNavTab.learn),
            onPhotoTap: _openPhotographyLessons,
            onMeTap: () => setState(() => _tab = AppNavTab.me),
          ),
        ],
      ),
    );
  }

  void _openPhotographyLessons() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => photographyTask(widget.locale),
      ),
    );
  }
}
