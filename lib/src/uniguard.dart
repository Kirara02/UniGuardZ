import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_device_imei/flutter_device_imei.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ugz_app/src/features/settings/domain/device/device_model.dart';
import 'package:ugz_app/src/global_providers/global_providers.dart';
import 'package:ugz_app/src/routes/router_config.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';
import 'package:ugz_app/src/utils/misc/print.dart';

import 'constants/theme.dart';
import 'features/settings/widgets/app_theme_mode_tile/app_theme_mode_tile.dart';
import 'l10n/generated/app_localizations.dart';

class Uniguard extends ConsumerStatefulWidget {
  const Uniguard({super.key});

  @override
  ConsumerState<Uniguard> createState() => _UniguardState();
}

class _UniguardState extends ConsumerState<Uniguard> {
  @override
  void initState() {
    super.initState();
    _initDevice();
  }

  @override
  Widget build(BuildContext context) {
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

  void _initDevice() async {
    final deviceInfo = await getInfo();
    ref.read(deviceNameProvider.notifier).update(deviceInfo.deviceName);
    ref.read(deviceIdProvider.notifier).update(deviceInfo.deviceId);
  }

  Future<Device> getInfo() async {
    final deviceName = await _getDeviceName();
    final deviceImei = await _getImei();

    return Device(deviceId: deviceImei, deviceName: deviceName);
  }

  Future<String> _getDeviceName() async {
    String deviceName = 'unknown';
    final info = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await info.androidInfo;

      deviceName =
          "${androidInfo.manufacturer.toCamelCase} ${androidInfo.name}";
    } else if (Platform.isIOS) {
      final iosInfo = await info.iosInfo;
      print(iosInfo);

      deviceName = iosInfo.modelName;
    }

    return deviceName;
  }

  Future<String> _getImei() async {
    String platformVersion = "unknown";
    try {
      platformVersion =
          await FlutterDeviceImei.instance.getIMEI() ??
          'Unknown platform version';
    } on PlatformException {
      printIfDebug("Failed to get platform version.");
    }
    return platformVersion;
  }
}
