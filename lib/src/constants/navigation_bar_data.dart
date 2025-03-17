import 'package:flutter/material.dart';
import 'package:ugz_app/src/constants/gen/assets.gen.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';
import 'package:ugz_app/src/widgets/navigation_icon.dart';
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
      icon: NavigationIcon(iconPath: Assets.images.homeActive.path),
      activeIcon: NavigationIcon(iconPath: Assets.images.homeActive.path),
      label: (context) => context.l10n!.home,
      go: const HomeRoute().go,
      activeOn: [const HomeRoute().location],
    ),
    NavigationBarData(
      icon: NavigationIcon(iconPath: Assets.images.historiesActive.path),
      activeIcon: NavigationIcon(iconPath: Assets.images.historiesActive.path),
      label: (context) => context.l10n!.history,
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
