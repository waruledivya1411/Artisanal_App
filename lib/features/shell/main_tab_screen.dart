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
            onLearnTap: () {
              if (_tab == AppNavTab.learn) {
                _openPhotographyFromLearn();
              } else {
                setState(() => _tab = AppNavTab.learn);
              }
            },
            onMeTap: () => setState(() => _tab = AppNavTab.me),
          ),
        ],
      ),
    );
  }

  void _openPhotographyFromLearn() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: photographySetupRoute),
        builder: (_) => photographyEntry(widget.locale),
      ),
    );
  }
}
