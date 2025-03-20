import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ugz_app/src/features/auth/providers/user_data_provider.dart';
import 'package:ugz_app/src/features/home/domain/usecase/submit_location/submit_location_params.dart';
import 'package:ugz_app/src/features/home/domain/usecase/submit_location/submit_location_usecase.dart';
import 'package:ugz_app/src/global_providers/global_providers.dart';
import 'package:ugz_app/src/utils/misc/print.dart';

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  debugPrint("Background Service Started!");

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  String? userId;
  bool gpsTrackingEnabled = false;
  int gpsInterval = 30;
  String? token;
  String? buildCode;
  String? deviceName;
  String? deviceId;

  // **Langsung mulai tracking jika data user telah dikirim sebelumnya**
  service.on('setUserData').listen((event) {
    userId = event?['userId'];
    gpsTrackingEnabled = event?['gpsTrackingEnabled'] ?? false;
    gpsInterval = event?['gpsInterval'] ?? 30;
    token = event?['token'];
    buildCode = event?['buildCode'];
    deviceName = event?['deviceName'];
    deviceId = event?['deviceId'];

    debugPrint("User ditemukan: $userId, GPS Tracking: $gpsTrackingEnabled");

    if (userId != null &&
        gpsTrackingEnabled &&
        token != null &&
        buildCode != null &&
        deviceName != null &&
        deviceId != null) {
      startTracking(
        service,
        flutterLocalNotificationsPlugin,
        gpsInterval,
        token!,
        buildCode!,
        deviceName!,
        deviceId!,
      );
    } else {
      debugPrint("User tidak ditemukan atau tracking tidak aktif.");
    }
  });

  service.on('stopService').listen((event) {
    service.stopSelf();
  });
}

void startTracking(
  ServiceInstance service,
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  int interval,
  String token,
  String buildCode,
  String deviceName,
  String deviceId,
) {
  StreamSubscription<Position>? positionStream;

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

  positionStream = Geolocator.getPositionStream(
    locationSettings: locationSettings,
  ).listen((Position position) async {
    service.invoke('updateLocation', {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': position.timestamp.toString(),
    });

    debugPrint(
      'Background Location: ${position.latitude}, ${position.longitude}',
    );

    // **🔹 Panggil API untuk kirim data lokasi**
    final container = ProviderContainer();
    final sendLocation = container.read(submitLocationProvider);
    final result = await sendLocation(
      SubmitLocationParams(
        token: token,
        buildCode: buildCode,
        latitude: position.latitude,
        longitude: position.longitude,
        deviceName: deviceName,
        deviceId: deviceId,
      ),
    );
    printIfDebug(result);

    // Perbarui notifikasi di foreground
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: "Tracking Location",
        content:
            "Lat: ${position.latitude}, Lon: ${position.longitude}, Time: ${position.timestamp}",
      );

      flutterLocalNotificationsPlugin.show(
        888,
        'Tracking Location',
        'Lat: ${position.latitude}, Lon: ${position.longitude}',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'my_foreground',
            'MY FOREGROUND SERVICE',
            icon: 'ic_bg_service_small',
            ongoing: true,
          ),
        ),
      );
    }
  });

  service.on('stopService').listen((event) {
    positionStream?.cancel();
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

class GeolocationTrackingService {
  static final GeolocationTrackingService _instance =
      GeolocationTrackingService._internal();

  factory GeolocationTrackingService() => _instance;

  GeolocationTrackingService._internal();

  final FlutterBackgroundService _service = FlutterBackgroundService();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    await requestNotificationPermission();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'my_foreground',
      'MY FOREGROUND SERVICE',
      description: 'This channel is used for important notifications.',
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
        notificationChannelId: 'my_foreground',
        initialNotificationTitle: 'Tracking Location',
        initialNotificationContent: 'Initializing location tracking...',
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
    bool isRunning = await _service.isRunning();
    if (isRunning) {
      _service.invoke('stopService');
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
}
