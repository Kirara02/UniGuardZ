import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ugz_app/src/constants/colors.dart';
import 'package:ugz_app/src/constants/gen/assets.gen.dart';
import 'package:ugz_app/src/features/home/domain/usecase/start_alarm/start_alarm_params.dart';
import 'package:ugz_app/src/features/home/domain/usecase/stop_alarm/stop_alarm_params.dart';
import 'package:ugz_app/src/features/home/providers/alarm_provider.dart';
import 'package:ugz_app/src/features/settings/widgets/app_theme_mode_tile/app_theme_mode_tile.dart';
import 'package:ugz_app/src/global_providers/location_providers.dart';
import 'package:ugz_app/src/routes/router_config.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _blinkTimer;
  bool _isVisible = true;
  final isAlarmProcessing = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _startBlinking();
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    super.dispose();
  }

  void _startBlinking() {
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      setState(() {
        _isVisible = !_isVisible;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final alarmRef = ref.read(alarmIdKeyProvider.notifier);
    final alarm = ref.watch(alarmIdKeyProvider);
    final alarmActRef = ref.read(alarmProvider.notifier);

    final appThemeMode = ref.watch(appThemeModeProvider);

    final isDarkMode =
        appThemeMode == ThemeMode.dark ||
        (appThemeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    ref.listen(alarmProvider, (prev, next) {
      if (next is AsyncData) {
        if (next.value != null) {
          alarmRef.update(next.value!.id);
          context.showSnackBar("Alarm started");
        } else {
          alarmRef.update(null);
          context.showSnackBar("Alarm stopped");
        }
        isAlarmProcessing.value = false;
      }
    });

    final List<MenuItem> menuItems = [
      MenuItem(
        iconPath: Assets.images.alarmIcon.path,
        iconDarkPath: Assets.images.alarmIconDark.path,
        label: context.l10n!.alarm,
        isAlarmTap: true,
      ),
      MenuItem(
        iconPath: Assets.images.formIcon.path,
        iconDarkPath: Assets.images.formIconDark.path,
        label: context.l10n!.forms,
        onPressed: () => FormsRoute().push(context),
      ),
      MenuItem(
        iconPath: Assets.images.taskIcon.path,
        iconDarkPath: Assets.images.taskIconDark.path,
        label: context.l10n!.tasks,
        onPressed: () => TasksRoute().push(context),
      ),
      MenuItem(
        iconPath: Assets.images.logIcon.path,
        iconDarkPath: Assets.images.logIconDark.path,
        label: context.l10n!.activity_log,
        onPressed: () => ActivitiesRoute().push(context),
      ),
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n!.latest_activity,
                    style: context.textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ClipOval(
                        child: Container(
                          width: 36,
                          height: 36,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Form - School Form 1",
                            style: context.textTheme.titleSmall!.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "Today, 10:00 am",
                            style: context.textTheme.labelSmall!.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppColors.hint,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Wrap(
              spacing: 28,
              runSpacing: 24,
              alignment: WrapAlignment.center,
              children:
                  menuItems.map((item) {
                    return GestureDetector(
                      onTap: item.isAlarmTap == false ? item.onPressed : null,
                      onLongPress:
                          item.isAlarmTap == true
                              ? () async {
                                isAlarmProcessing.value = true;
                                final position = await _getLocation(
                                  context,
                                  ref,
                                );
                                if (position == null) {
                                  isAlarmProcessing.value = false;
                                  return;
                                }
                                final bool isAlarmActive = alarm.isNull;
                                if (isAlarmActive) {
                                  await alarmActRef.startAlarm(
                                    params: StartAlarmParams(
                                      latitude: position.latitude,
                                      longitude: position.longitude,
                                    ),
                                  );
                                } else {
                                  if (alarm != null) {
                                    await alarmActRef.stopAlarm(
                                      params: StopAlarmParams(
                                        id: alarm,
                                        latitude: position.latitude,
                                        longitude: position.longitude,
                                      ),
                                    );
                                  } else {
                                    if (context.mounted) {
                                      context.showSnackBar(
                                        "Alarm ID tidak ditemukan!",
                                      );
                                    }
                                    isAlarmProcessing.value = false;
                                  }
                                }
                              }
                              : null,
                      child: Stack(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 1500),
                            height: 150,
                            width: 130,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: context.colorScheme.surfaceBright,
                              border:
                                  item.isAlarmTap == true && !alarm.isNull
                                      ? Border.all(
                                        color:
                                            _isVisible
                                                ? Colors.red
                                                : Colors.transparent,
                                        width: 2,
                                      )
                                      : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  isDarkMode
                                      ? item.iconDarkPath
                                      : item.iconPath,
                                  fit: BoxFit.fitWidth,
                                  height: 80,
                                  width: 80,
                                ),
                                const Gap(12),
                                Text(
                                  item.label,
                                  style: context.textTheme.labelLarge!.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (item.isAlarmTap == true)
                            ValueListenableBuilder<bool>(
                              valueListenable: isAlarmProcessing,
                              builder: (context, isProcessing, child) {
                                if (isProcessing) {
                                  return Container(
                                    height: 150,
                                    width: 130,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Future<Position?> _getLocation(BuildContext context, WidgetRef ref) async {
    final locationData = await ref.read(locationProvider.future);

    locationData.position;

    if (context.mounted) {
      switch (locationData.status) {
        case LocationStatus.serviceDisabled:
          context.showSnackBar(
            "GPS is not active",
            backgroundColor: AppColors.error,
          );
          return null;
        case LocationStatus.denied:
          context.showSnackBar(
            "Location permission denied",
            backgroundColor: AppColors.error,
          );
          return null;
        case LocationStatus.unknown:
          context.showSnackBar(
            "Failed to get location",
            backgroundColor: AppColors.error,
          );
          return null;
        case LocationStatus.granted:
          return locationData.position;
      }
    }
    return null;
  }
}

class MenuItem {
  final String iconPath;
  final String iconDarkPath;
  final String label;
  final bool? isAlarmTap;
  final VoidCallback? onPressed;

  MenuItem({
    required this.iconPath,
    required this.iconDarkPath,
    required this.label,
    this.isAlarmTap = false,
    this.onPressed,
  });
}
