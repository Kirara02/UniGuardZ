import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ugz_app/src/constants/app_sizes.dart';
import 'package:ugz_app/src/constants/colors.dart';
import 'package:ugz_app/src/constants/navigation_bar_data.dart';
import 'package:ugz_app/src/features/settings/widgets/app_theme_mode_tile/app_theme_mode_tile.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';

class SmallScreenNavigationBar extends ConsumerWidget {
  const SmallScreenNavigationBar({super.key, required this.selectedScreen});

  final String selectedScreen;

  NavigationDestination getNavigationDestination(
    BuildContext context,
    NavigationBarData data,
  ) {
    return NavigationDestination(
      icon: data.icon,
      label: data.label(context),
      selectedIcon: data.activeIcon,
      tooltip: data.label(context),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appThemeMode = ref.watch(appThemeModeProvider);

    final isDarkMode =
        appThemeMode == ThemeMode.dark ||
        (appThemeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return NavigationBarTheme(
      data: NavigationBarThemeData(
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(overflow: TextOverflow.ellipsis),
        ),
      ),
      child: BottomAppBar(
        elevation: 3,
        shape: const CircularNotchedRectangle(),
        notchMargin: 5,
        padding: EdgeInsets.zero,
        height: kAppBarBottomHeight,
        color: context.colorScheme.surface,
        clipBehavior: Clip.antiAlias,
        child: NavigationBar(
          backgroundColor: context.colorScheme.surface,
          elevation: 0,
          indicatorColor: AppColors.secondary.withOpacity(0.24),
          labelTextStyle: WidgetStatePropertyAll(context.textTheme.labelSmall),
          selectedIndex: NavigationBarData.indexWherePathOrZero(selectedScreen),
          onDestinationSelected:
              (value) => NavigationBarData.navList[value].go(context),
          destinations:
              NavigationBarData.navList
                  .map<NavigationDestination>(
                    (e) => getNavigationDestination(context, e),
                  )
                  .toList(),
        ),
      ),
    );
  }
}
