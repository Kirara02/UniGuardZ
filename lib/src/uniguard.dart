import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ugz_app/src/global_providers/global_providers.dart';
import 'package:ugz_app/src/routes/router_config.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';

import 'constants/theme.dart';
import 'features/settings/widgets/app_theme_mode_tile/app_theme_mode_tile.dart';
import 'l10n/generated/app_localizations.dart';

class Uniguard extends ConsumerWidget {
  const Uniguard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routes = ref.watch(routerConfigProvider);
    final appLocale = ref.watch(l10nProvider);
    final appThemeMode = ref.watch(appThemeModeProvider);

    final isDarkMode =
        appThemeMode == ThemeMode.dark ||
        (appThemeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final theme = isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: theme.colorScheme.surface,
          systemNavigationBarIconBrightness:
              isDarkMode ? Brightness.light : Brightness.dark,
        ),
      );
    });

    return MaterialApp.router(
      builder: FToastBuilder(),
      onGenerateTitle: (context) => context.l10n!.app_name,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale: appLocale,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: appThemeMode,
      routerConfig: routes,
    );
  }
}
