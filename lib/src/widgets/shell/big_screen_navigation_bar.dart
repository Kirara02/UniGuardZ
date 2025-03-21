import 'package:flutter/material.dart';
import 'package:ugz_app/src/constants/gen/assets.gen.dart';
import 'package:ugz_app/src/constants/navigation_bar_data.dart';
import 'package:ugz_app/src/routes/router_config.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';

class BigScreenNavigationBar extends StatelessWidget {
  const BigScreenNavigationBar({super.key, required this.selectedScreen});

  final String selectedScreen;

  NavigationRailDestination getNavigationRailDestination(
    BuildContext context,
    NavigationBarData data,
  ) {
    return NavigationRailDestination(
      icon: data.icon,
      label: Text(data.label(context)),
      selectedIcon: data.activeIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget leadingIcon;
    if (context.isDesktop) {
      leadingIcon = TextButton.icon(
        onPressed: () => const SettingsRoute().push(context),
        icon: ImageIcon(AssetImage(Assets.images.uniguardIcon.path), size: 48),
        label: Text(context.l10n!.app_name),
        style: TextButton.styleFrom(
          foregroundColor: context.textTheme.bodyLarge?.color,
        ),
      );
    } else {
      leadingIcon = IconButton(
        onPressed: () => const SettingsRoute().push(context),
        icon: ImageIcon(AssetImage(Assets.images.uniguardIcon.path), size: 48),
      );
    }

    return NavigationRail(
      useIndicator: true,
      elevation: 5,
      extended: context.isDesktop,
      labelType:
          context.isDesktop
              ? NavigationRailLabelType.none
              : NavigationRailLabelType.all,
      leading: leadingIcon,
      destinations:
          NavigationBarData.navList
              .map<NavigationRailDestination>(
                (e) => getNavigationRailDestination(context, e),
              )
              .toList(),
      selectedIndex: NavigationBarData.indexWherePathOrZero(selectedScreen),
      onDestinationSelected:
          (value) => NavigationBarData.navList[value].go(context),
    );
  }
}
