import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ugz_app/src/constants/colors.dart';
import 'package:ugz_app/src/features/settings/widgets/app_theme_mode_tile/app_theme_mode_tile.dart';

class NavigationIcon extends ConsumerWidget {
  final String iconPath;
  const NavigationIcon({super.key, required this.iconPath});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appThemeMode = ref.watch(appThemeModeProvider);

    final isDarkMode =
        appThemeMode == ThemeMode.dark ||
        (appThemeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Image.asset(
      iconPath,
      width: 24,
      height: 24,
      color: isDarkMode ? AppColors.secondary : AppColors.primary
    );
  }
}
