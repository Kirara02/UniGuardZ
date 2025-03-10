import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ugz_app/src/constants/colors.dart';
import 'package:ugz_app/src/constants/gen/assets.gen.dart';
import 'package:ugz_app/src/features/home/domain/usecase/start_alarm/start_alarm_params.dart';
import 'package:ugz_app/src/features/home/domain/usecase/stop_alarm/stop_alarm_params.dart';
import 'package:ugz_app/src/features/home/providers/alarm_provider.dart';
import 'package:ugz_app/src/global_providers/location_providers.dart';
import 'package:ugz_app/src/routes/router_config.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colorScheme;
    final alarmRef = ref.read(alarmIdKeyProvider.notifier);
    final alarm = ref.watch(alarmIdKeyProvider);
    final alarmActRef = ref.read(alarmProvider.notifier);

    ref.listen(alarmProvider, (prev, next) {
      if (next is AsyncData) {
        if (next.value != null) {
          alarmRef.update(next.value!.id);
          context.showSnackBar("Alarm started");
        } else {
          alarmRef.update(null);
          context.showSnackBar("Alarm stopped");
        }
      }
    });

    final List<MenuItem> menuItems = [
      MenuItem(
        iconPath: Assets.images.alarm.path,
        label: context.l10n!.alarm,
        isAlarmTap: true,
      ),
      MenuItem(
        iconPath: Assets.images.forms.path,
        label: context.l10n!.forms,
        onPressed: () => FormsRoute().push(context),
      ),
      MenuItem(
        iconPath: Assets.images.tasks.path,
        label: context.l10n!.tasks,
        onPressed: () => TasksRoute().push(context),
      ),
      MenuItem(
        iconPath: Assets.images.onlineActivity.path,
        label: context.l10n!.activity_log,
        onPressed: () => ActivitiesRoute().push(context),
      ),
    ];

    // Display the selected section based on the page state
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
                          )
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 28,
                mainAxisSpacing: 24,
                childAspectRatio: 1.5,
              ),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];

                return GestureDetector(
                  onTap: item.isAlarmTap == false ? item.onPressed : null,
                  onLongPress:
                      item.isAlarmTap == true
                          ? () async {
                            final position = await _getLocation(context, ref);
                            if (position == null) return;
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
                              }
                            }
                          }
                          : null,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: colorScheme.surfaceBright,
                      border:
                          item.isAlarmTap == true && !alarm.isNull
                              ? Border.all(color: Colors.yellow, width: 2)
                              : null,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.outline.withOpacity(0.5),
                          spreadRadius: 1.5,
                          blurRadius: 2,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          item.iconPath,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.label,
                          style: context.textTheme.labelMedium!.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
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
  final String label;
  final bool? isAlarmTap;
  final VoidCallback? onPressed;

  MenuItem({
    required this.iconPath,
    required this.label,
    this.isAlarmTap = false,
    this.onPressed,
  });
}
