import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:badges/badges.dart' as badges;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ugz_app/src/constants/colors.dart';
import 'package:ugz_app/src/constants/gen/assets.gen.dart';
import 'package:ugz_app/src/features/auth/providers/user_data_provider.dart';
import 'package:ugz_app/src/global_providers/global_providers.dart';
import 'package:ugz_app/src/global_providers/pending_count_providers.dart';
import 'package:ugz_app/src/local/usecases/delete_all_pending_forms/delete_all_pending_forms.dart';
import 'package:ugz_app/src/routes/router_config.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';
import 'package:ugz_app/src/utils/misc/print.dart';
import 'package:ugz_app/src/widgets/custom_view.dart';
import 'package:ugz_app/src/widgets/dialog/exit_app_dialog.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io' show Platform;

import 'big_screen_navigation_bar.dart';
import 'small_screen_navigation_bar.dart';

class ShellScreen extends ConsumerStatefulWidget {
  const ShellScreen({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends ConsumerState<ShellScreen> {
  @override
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      final bool permissionGranted = await _checkAndRequestPermissions(
        androidInfo,
      );

      if (!permissionGranted) {
        printIfDebug(
          "Permission belum granted secara penuh (locationAlways dan/atau notification)",
        );
        return;
      }

      await _initializeAndStartServices();
    });
  }

  Future<bool> _checkAndRequestPermissions(
    AndroidDeviceInfo androidInfo,
  ) async {
    if (!Platform.isAndroid) return false;

    // Request Notification permission if Android 13+
    if (androidInfo.version.sdkInt >= 33) {
      final notificationStatus = await Permission.notification.status;
      if (!notificationStatus.isGranted) {
        final result = await Permission.notification.request();
        if (!result.isGranted) {
          return false;
        }
      }
    }

    final locationStatus = await Permission.locationAlways.status;
    if (!locationStatus.isGranted) {
      return false;
    }

    // If Android 13+, make sure notification permission still granted
    if (androidInfo.version.sdkInt >= 33) {
      final notificationStatus = await Permission.notification.isGranted;
      return notificationStatus && locationStatus.isGranted;
    }

    return locationStatus.isGranted;
  }

  Future<void> _initializeAndStartServices() async {
    try {
      final user = ref.read(userDataProvider).valueOrNull;
      final packageInfo = await PackageInfo.fromPlatform();
      final credentials = ref.read(credentialsProvider);
      final buildCode = packageInfo.buildNumber;
      final deviceName = ref.read(deviceNameProvider);
      final deviceId = ref.read(deviceIdProvider);

      await ref
          .read(uniguardServiceProvider)
          .initialize(
            headers: {
              "x-app-build": buildCode,
              'x-device-name': deviceName ?? '',
              'x-device-uid': deviceId ?? '',
              'Authorization': credentials ?? '',
            },
          );

      try {
        await ref.read(uniguardServiceProvider).startBeaconService();
      } catch (e) {
        printIfDebug('Failed to start beacon service: $e');
      }

      if (user != null && user.parentBranch.gpsTrackingEnabled) {
        try {
          await ref
              .read(uniguardServiceProvider)
              .startLocationUploadService(
                interval: user.parentBranch.gpsInterval * 1000,
              );
        } catch (e) {
          printIfDebug('Failed to start location service: $e');
        }
      }
    } catch (e) {
      printIfDebug('Error initializing services: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = ref.watch(pendingCountProvider);

    ref.listen(userDataProvider, (previous, next) {
      if (previous != null && next is AsyncData && next.value == null) {
        // Stop background service when logging out
        // if (!kDebugMode) {
        ref.read(uniguardServiceProvider).stopBeaconService();
        ref.read(uniguardServiceProvider).stopLocationUploadService();
        // }
        LoginRoute().go(context);
      } else if (next is AsyncError) {
        context.showSnackBar(next.error.toString());
      }
    });

    if (context.isTablet) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (!didPop) {
            final shouldExit = await showExitDialog(context);
            if (shouldExit == true) {
              exitApp();
            }
          }
        },
        child: Scaffold(
          body: Row(
            children: [
              BigScreenNavigationBar(selectedScreen: context.location),
              Expanded(child: widget.child),
            ],
          ),
          floatingActionButton: SizedBox(
            width: 72,
            height: 72,
            child: FittedBox(
              child: FloatingActionButton.large(
                shape: const CircleBorder(),
                onPressed: () => ScanRoute().push(context),
                backgroundColor: AppColors.primary,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Assets.icons.scan.svg(width: 42),
                    const SizedBox(height: 4),
                    Text("Scan", style: context.textTheme.labelMedium),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (!didPop) {
            final shouldExit = await showExitDialog(context);
            if (shouldExit == true) {
              exitApp();
            }
          }
        },
        child: CustomView(
          header: CustomViewHeader(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Assets.images.loginLogo.image(width: 120),
              Row(
                children: [
                  pendingCount.when(
                    data: (data) {
                      if (data != null && data > 0) {
                        return badges.Badge(
                          badgeContent: Text(
                            data.toString(),
                            textAlign: TextAlign.center,
                            style: context.textTheme.labelSmall!,
                          ),
                          badgeStyle: badges.BadgeStyle(
                            padding: const EdgeInsets.all(4),
                            badgeColor: context.colorScheme.secondaryFixedDim,
                            elevation: 0,
                          ),
                          position: badges.BadgePosition.topEnd(top: 2, end: 2),
                          child: IconButton(
                            onPressed: () {},
                            icon: const FaIcon(
                              FontAwesomeIcons.cloudArrowUp,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        );
                      }

                      return const SizedBox();
                    },
                    error: (err, _) => const SizedBox(),
                    loading: () => const SizedBox(),
                  ),

                  IconButton(
                    onPressed: () {
                      SettingsRoute().push(context);
                    },
                    icon: const FaIcon(
                      FontAwesomeIcons.gear,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                  if (kDebugMode)
                    IconButton(
                      onPressed: () {
                        ref.read(dbDeleteAllPendingFormsProvider).call(null);
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.trashArrowUp,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ],
          ),
          body: widget.child,
          backgroundColor: context.colorScheme.surfaceContainer,
          floatingActionButton: SizedBox(
            width: 72,
            height: 72,
            child: FittedBox(
              child: FloatingActionButton.large(
                shape: const CircleBorder(),
                onPressed: () => ScanRoute().push(context),
                backgroundColor: AppColors.primary,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Assets.images.nfcLogoWhite.image(width: 48),
                    const SizedBox(height: 4),
                    Text("Scan", style: context.textTheme.labelLarge),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: SmallScreenNavigationBar(
            selectedScreen: context.location,
          ),
        ),
      );
    }
  }
}
