import 'package:flutter/material.dart';
import 'package:ugz_app/src/constants/colors.dart';
import 'package:ugz_app/src/constants/gen/assets.gen.dart';
import '../routes/router_config.dart';

class NavigationBarData {
  final String Function(BuildContext context) label;
  final ValueSetter<BuildContext> go;
  final Widget icon;
  final Widget activeIcon;
  final List<String> activeOn;

  static int indexWherePathOrZero(path) {
    final index = navList.indexWhere(
      (e) => e.activeOn.any((element) => path.contains(element)),
    );
    return index > 0 ? index : 0;
  }

  static final navList = [
    NavigationBarData(
      icon: Assets.images.homeActive.image(
        width: 24,
        height: 24,
        color: AppColors.primary,
      ),
      activeIcon: Assets.images.homeActive.image(
        width: 24,
        height: 24,
        color: AppColors.primary,
      ),
      label: (context) => "Home",
      go: const HomeRoute().go,
      activeOn: [const HomeRoute().location],
    ),
    NavigationBarData(
      icon: Assets.images.historiesActive.image(
        width: 24,
        height: 24,
        color: AppColors.primary,
      ),
      activeIcon: Assets.images.historiesActive.image(
        width: 24,
        height: 24,
        color: AppColors.primary,
      ),
      label: (context) => "More",
      go: const HistoryRoute().go,
      activeOn: [
        const HistoryRoute().location,
        // const SettingsRoute().location,
      ],
    ),
  ];

  NavigationBarData({
    required this.label,
    required this.go,
    required this.icon,
    required this.activeIcon,
    required this.activeOn,
  });
}
