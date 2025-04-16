import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:ugz_app/src/constants/colors.dart';
import 'package:ugz_app/src/constants/gen/assets.gen.dart';
import 'package:ugz_app/src/features/home/domain/usecase/start_alarm/start_alarm_params.dart';
import 'package:ugz_app/src/features/home/domain/usecase/stop_alarm/stop_alarm_params.dart';
import 'package:ugz_app/src/features/home/providers/alarm_provider.dart';
import 'package:ugz_app/src/features/home/providers/beacon_providers.dart';
import 'package:ugz_app/src/features/settings/widgets/app_theme_mode_tile/app_theme_mode_tile.dart';
import 'package:ugz_app/src/global_providers/location_providers.dart';
import 'package:ugz_app/src/routes/router_config.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';
import 'package:ugz_app/src/features/home/presentation/home/controller/home_controller.dart';
import 'package:skeletonizer/skeletonizer.dart';

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

    final latestActivity = ref.watch(homeControllerProvider);

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

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(homeControllerProvider.notifier).refresh();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            latestActivity.when(
              data: (activity) {
                if (activity == null) {
                  return Card(
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.l10n!.latest_activity,
                                style: context.textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.history_rounded,
                                  size: 48,
                                  color: context.colorScheme.outline,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "No recent activities",
                                  style: context.textTheme.bodyLarge?.copyWith(
                                    color: context.colorScheme.outline,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Your activities will appear here",
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: context.colorScheme.outlineVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                Widget? icon;

                // Determine icon based on type
                switch (activity.payloadData['type'].toLowerCase()) {
                  case 'form':
                    icon = Assets.icons.file.svg(width: 20, height: 20);
                  case 'task':
                    icon = Assets.icons.checklist.svg(width: 20, height: 20);
                  case 'activity':
                    icon = Assets.icons.guard.svg(width: 20, height: 20);
                  case 'user':
                    icon =
                        icon = Icon(
                          Icons.person_outline_rounded,
                          color: Colors.blue,
                        );
                  case 'alarm':
                    icon = Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.blue,
                    );
                  case 'checkpoint':
                    icon = Icon(Icons.wifi_tethering, color: Colors.blue);
                  default:
                    icon = Assets.icons.pinLocation.svg(width: 20, height: 20);
                }

                return Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.l10n!.latest_activity,
                              style: context.textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: context.colorScheme.surfaceContainerHigh,
                                boxShadow: [
                                  BoxShadow(
                                    color: context.colorScheme.outlineVariant,
                                    spreadRadius: 1,
                                    blurRadius: 2,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: icon,
                            ),
                            const Gap(16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activity.referenceName,
                                  style: context.textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('dd MMM yyyy, hh:mm a').format(
                                    DateTime.parse(
                                      activity.originalSubmittedTime,
                                    ).toLocal(),
                                  ),
                                  style: context.textTheme.bodySmall!.copyWith(
                                    color: context.colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading:
                  () => Skeletonizer(
                    enabled: true,
                    textBoneBorderRadius: TextBoneBorderRadius(
                      BorderRadius.circular(4),
                    ),
                    child: Card(
                      margin: const EdgeInsets.all(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  context.l10n!.latest_activity,
                                  style: context.textTheme.titleMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color:
                                        context
                                            .colorScheme
                                            .surfaceContainerHigh,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            context.colorScheme.outlineVariant,
                                        spreadRadius: 1,
                                        blurRadius: 2,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: SizedBox(width: 20, height: 20),
                                ),
                                const Gap(16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Loading activity...",
                                      style: context.textTheme.bodyLarge,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Loading time...",
                                      style: context.textTheme.bodySmall!
                                          .copyWith(
                                            color: context.colorScheme.outline,
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
                  ),
              error:
                  (error, stack) => Center(
                    child: Text(
                      "Error loading latest activity: $error",
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.error,
                      ),
                    ),
                  ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.spaceBetween,
                children:
                    menuItems.map((item) {
                      return GestureDetector(
                        onTap:
                            item.isAlarmTap == false
                                ? item.onPressed
                                : () {
                                  context.showSnackBar(
                                    "Long press to start/stop alarm",
                                  );
                                },
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
                              height:
                                  MediaQuery.of(context).orientation ==
                                          Orientation.portrait
                                      ? context.height * .25
                                      : context.height * .4,
                              width: context.width * .40,
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
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Image.asset(
                                      isDarkMode
                                          ? item.iconDarkPath
                                          : item.iconPath,
                                      fit: BoxFit.contain,
                                      height:
                                          context.isPortrait
                                              ? context.height * .08
                                              : context.height * .15,
                                    ),
                                  ),
                                  const Gap(12),
                                  Flexible(
                                    child: Text(
                                      item.label,
                                      style: context.textTheme.labelLarge!
                                          .copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
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
                                      height: context.height * .25,
                                      width: context.width * .40,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha: 0.3,
                                        ),
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
      ),
    );
  }

  Future<Position?> _getLocation(BuildContext context, WidgetRef ref) async {
    ref.read(locationTriggerProvider.notifier).state++;

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
