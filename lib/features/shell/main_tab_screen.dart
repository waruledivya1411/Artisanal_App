import 'package:flutter/material.dart';

import 'package:artisnal_app/core/widgets/app_bottom_nav.dart';
import 'package:artisnal_app/features/learn/data/learn_task_navigation.dart';
import 'package:artisnal_app/features/learn/screens/learn_home_screen.dart';
import 'package:artisnal_app/features/me/screens/me_screen.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key, required this.locale});

  final String locale;

  /// Switches the Learn / Me tab after a pushed screen pops back home.
  static void Function(AppNavTab tab)? selectTab;

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  AppNavTab _tab = AppNavTab.learn;

  @override
  void initState() {
    super.initState();
    MainTabScreen.selectTab = (tab) {
      if (mounted) setState(() => _tab = tab);
    };
  }

  @override
  void dispose() {
    if (MainTabScreen.selectTab != null) MainTabScreen.selectTab = null;
    super.dispose();
  }

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
                MeScreen(locale: widget.locale),
              ],
            ),
          ),
          AppBottomNav(
            locale: widget.locale,
            selectedTab: _tab,
            onLearnTap: () => setState(() => _tab = AppNavTab.learn),
            onPhotoTap: () =>
                LearnTaskNavigation.openShoot(context, widget.locale),
            onMeTap: () => setState(() => _tab = AppNavTab.me),
          ),
        ],
      ),
    );
  }
}
