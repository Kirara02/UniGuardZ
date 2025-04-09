import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:beacons_plugin/beacons_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ugz_app/src/constants/app_constants.dart';
import 'package:ugz_app/src/features/auth/providers/user_data_provider.dart';
import 'package:ugz_app/src/features/home/domain/model/beacon_result.dart';
import 'package:ugz_app/src/features/home/domain/usecase/submit_location/submit_location_params.dart';
import 'package:ugz_app/src/features/home/domain/usecase/submit_location/submit_location_usecase.dart';
import 'package:ugz_app/src/global_providers/global_providers.dart';
import 'package:ugz_app/src/utils/misc/print.dart';

final backgroundServiceInstance = UniguardBackgroundService();

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  final notifications = FlutterLocalNotificationsPlugin();

  service.on('setUserData').listen((event) {
    backgroundServiceInstance._startBeaconMonitoring(notifications);

    final gpsTrackingEnabled = event?['gpsTrackingEnabled'] ?? false;
    if (!gpsTrackingEnabled) return;

    backgroundServiceInstance._startLocationTracking(
      service,
      notifications,
      event?['gpsInterval'] ?? 30,
      event?['token'],
      event?['buildCode'],
      event?['deviceName'],
      event?['deviceId'],
    );
  });

  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: "Background Service",
      content: "UniGuard Background Service",
    );
  }

  service.on('stopService').listen((event) {
    print("service stop");
    service.stopSelf();
  });
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  // Request location permission if not already granted
  final locationStatus = await Permission.locationAlways.status;
  if (!locationStatus.isGranted) {
    await Permission.locationAlways.request();
  }

  return true;
}

class UniguardBackgroundService {
  static final UniguardBackgroundService _instance =
      UniguardBackgroundService._internal();

  factory UniguardBackgroundService() => _instance;

  UniguardBackgroundService._internal();

  final FlutterBackgroundService _service = FlutterBackgroundService();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<String>? _beaconSubscription;

  // 🔹 Beacon-related
  StreamController<String> _beaconEventsController =
      StreamController<String>.broadcast();
  final List<BeaconResult> _beaconResults = [];
  bool _beaconRunning = false;

  // For stopping GPS tracking stream
  StreamSubscription<Position>? _positionStream;

  Future<void> initialize() async {
    await requestNotificationPermission();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'ugz_foreground',
      'UGZ FOREGROUND SERVICE',
      description: 'This channel is used for background service notifications.',
      importance: Importance.low,
    );

    if (Platform.isIOS || Platform.isAndroid) {
      await _flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(
          iOS: DarwinInitializationSettings(),
          android: AndroidInitializationSettings('ic_bg_service_small'),
        ),
      );
    }

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    await _service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        autoStartOnBoot: false,
        isForegroundMode: true,
        notificationChannelId: 'ugz_foreground',
        initialNotificationTitle: 'UGZ Service',
        initialNotificationContent: 'UniGuardZ Service',
        foregroundServiceNotificationId: 888,
        foregroundServiceTypes: [AndroidForegroundType.location],
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  Future<void> startService(Ref ref) async {
    final packageInfo = await PackageInfo.fromPlatform();
    bool isRunning = await _service.isRunning();
    final user = ref.read(userDataProvider).valueOrNull;
    final credentials = ref.read(credentialsProvider);
    final buildCode = packageInfo.buildNumber;
    final deviceName = ref.read(deviceNameProvider);
    final deviceId = ref.read(deviceIdProvider);

    printIfDebug(user);
    printIfDebug(isRunning);

    if (!isRunning) {
      if (user == null) {
        debugPrint("User belum login, service tidak bisa dimulai.");
        return;
      }

      await _service.startService().then((_) {
        debugPrint("Start Service");
        _service.invoke('setUserData', {
          'userId': user.id,
          'gpsTrackingEnabled': user.parentBranch.gpsTrackingEnabled,
          'gpsInterval': user.parentBranch.gpsInterval,
          'token': credentials,
          'buildCode': buildCode,
          'deviceName': deviceName,
          'deviceId': deviceId,
        });
      });

      // Future.delayed(const Duration(seconds: 2), () {
      //
      // });
    }
  }

  Future<void> stopService() async {
    print("stopService");
    bool isRunning = await _service.isRunning();
    if (isRunning) {
      print("running");
      await _stopBeaconMonitoring().then((_) {
        _stopLocationTracking();
        _service.invoke('stopService');
      });
    }
  }

  Future<bool> isRunning() async {
    return await _service.isRunning();
  }

  Future<void> requestNotificationPermission() async {
    // if (Platform.isAndroid) {
    var status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
    // }
  }

  void _startLocationTracking(
    ServiceInstance service,
    FlutterLocalNotificationsPlugin notifications,
    int interval,
    String token,
    String buildCode,
    String deviceName,
    String deviceId,
  ) {
    late LocationSettings locationSettings;

    if (defaultTargetPlatform == TargetPlatform.android) {
      print("Android");
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2,
        intervalDuration: Duration(seconds: interval),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      print("IOS");
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.otherNavigation,
        distanceFilter: 2,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
      );
    } else {
      print("Other");
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(minutes: 1),
        distanceFilter: 1,
      );
    }

    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((position) async {
      service.invoke('updateLocation', {
        'latitude': position.latitude,
        'longitude': position.longitude,
      });

      final container = ProviderContainer();
      final sendLocation = container.read(submitLocationProvider);
      await sendLocation(
        SubmitLocationParams(
          token: token,
          buildCode: buildCode,
          latitude: position.latitude,
          longitude: position.longitude,
          deviceName: deviceName,
          deviceId: deviceId,
        ),
      );
    });
  }

  void _stopLocationTracking() {
    _positionStream?.cancel();
    _positionStream = null;
  }

  Future<void> _startBeaconMonitoring(
    FlutterLocalNotificationsPlugin notifications,
  ) async {
    if (_beaconRunning) return;
    _beaconRunning = true;

    _beaconEventsController = StreamController<String>.broadcast();

    try {
      BeaconsPlugin.listenToBeacons(_beaconEventsController);
    } catch (e) {
      print('BeaconsPlugin.listenToBeacons error: $e');
      return;
    }

    await BeaconsPlugin.addRegion(
      "all-beacons-region",
      "f7826da6-4fa2-4e98-8024-bc5b71e0893e",
    );
    BeaconsPlugin.addBeaconLayoutForAndroid(
      "m:2-3=0215,i:4-19,i:20-21,i:22-23,p:24-24",
    );

    final int bleScanLength =
        Duration(milliseconds: Delays.bleScanLengthMs).inMilliseconds;
    final int bleScanInterval =
        Duration(milliseconds: Delays.bleScanIntervalMs).inMilliseconds;
    final int betweenScanPeriod = (bleScanInterval - bleScanLength).clamp(
      0,
      bleScanInterval,
    );

    // Apply to BeaconsPlugin
    BeaconsPlugin.setForegroundScanPeriodForAndroid(
      foregroundScanPeriod: bleScanLength,
      foregroundBetweenScanPeriod: betweenScanPeriod,
    );

    BeaconsPlugin.setBackgroundScanPeriodForAndroid(
      backgroundScanPeriod: bleScanLength,
      backgroundBetweenScanPeriod: betweenScanPeriod,
    );

    _beaconSubscription = _beaconEventsController.stream.listen((data) {
      if (data.isEmpty) return;
      printIfDebug(data);
      try {
        final json = jsonDecode(data);
        final beacon = BeaconResult.fromJson(json);

        final exists = _beaconResults.any(
          (b) =>
              b.uuid == beacon.uuid &&
              b.major == beacon.major &&
              b.minor == beacon.minor,
        );

        if (!exists) {
          _beaconResults.add(beacon);
          notifications.show(
            889,
            'Beacon Detected',
            'UUID: ${beacon.uuid}, Major: ${beacon.major}',
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'ugz_foreground',
                'UGZ FOREGROUND SERVICE',
                importance: Importance.low,
                icon: 'ic_bg_service_small',
              ),
            ),
          );
        }
      } catch (e) {
        print('Beacon decode error: $e');
      }
    });

    await BeaconsPlugin.runInBackground(true);
    await BeaconsPlugin.startMonitoring();
  }

  Future<void> _stopBeaconMonitoring() async {
    try {
      await BeaconsPlugin.stopMonitoring();
      await _beaconSubscription?.cancel();
      _beaconSubscription = null;

      if (!_beaconEventsController.isClosed) {
        await _beaconEventsController.close();
      }

      _beaconRunning = false;
    } catch (e) {
      print("Stop beacon error: $e");
    }
  }
}
