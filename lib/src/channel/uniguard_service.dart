import 'package:flutter/services.dart';
import 'package:ugz_app/src/utils/misc/print.dart';

class UniguardService {
  static const platform = MethodChannel(
    'com.uniguard.ugz_app/uniguard_service',
  );

  /// Initialize the service with API headers
  ///
  /// [headers] - API headers including authentication tokens
  Future<void> initialize({required Map<String, String> headers}) async {
    try {
      printIfDebug('Initializing service with headers...');
      await platform.invokeMethod('initializeService', {'headers': headers});
      printIfDebug('Service initialized successfully');
    } on PlatformException catch (e) {
      printIfDebug('Failed to initialize service: ${e.message}');
      rethrow;
    }
  }

  /// Check if the beacon service is currently running
  Future<bool> isBeaconServiceRunning() async {
    try {
      final bool isRunning = await platform.invokeMethod(
        'isBeaconServiceRunning',
      );
      printIfDebug('Beacon service running status: $isRunning');
      return isRunning;
    } on PlatformException catch (e) {
      printIfDebug('Failed to check beacon service status: ${e.message}');
      rethrow;
    }
  }

  /// Start the beacon scanning service
  Future<void> startBeaconService() async {
    try {
      // Check if service is already running
      final bool isRunning = await isBeaconServiceRunning();
      if (isRunning) {
        printIfDebug('Beacon service is already running, stopping first...');
        await stopBeaconService();
      }

      printIfDebug('Starting beacon service...');
      await platform.invokeMethod('startBeaconService');

      // Verify service started successfully
      final bool started = await isBeaconServiceRunning();
      if (!started) {
        throw PlatformException(
          code: 'SERVICE_ERROR',
          message: 'Failed to verify beacon service started',
        );
      }

      printIfDebug('Beacon service started successfully');
    } on PlatformException catch (e) {
      printIfDebug('Failed to start beacon service: ${e.message}');
      rethrow;
    }
  }

  /// Stop the beacon scanning service
  Future<void> stopBeaconService() async {
    try {
      // Check if service is running before attempting to stop
      final bool isRunning = await isBeaconServiceRunning();
      if (!isRunning) {
        printIfDebug('Beacon service is not running, nothing to stop');
        return;
      }

      printIfDebug('Stopping beacon service...');
      await platform.invokeMethod('stopBeaconService');

      // Verify service stopped successfully
      final bool stopped = await isBeaconServiceRunning();
      if (stopped) {
        throw PlatformException(
          code: 'SERVICE_ERROR',
          message: 'Failed to verify beacon service stopped',
        );
      }

      printIfDebug('Beacon service stopped successfully');
    } on PlatformException catch (e) {
      printIfDebug('Failed to stop beacon service: ${e.message}');
      rethrow;
    }
  }

  /// Check if the location upload service is currently running
  Future<bool> isLocationUploadServiceRunning() async {
    try {
      final bool isRunning = await platform.invokeMethod(
        'isLocationUploadServiceRunning',
      );
      printIfDebug('Location upload service running status: $isRunning');
      return isRunning;
    } on PlatformException catch (e) {
      printIfDebug(
        'Failed to check location upload service status: ${e.message}',
      );
      rethrow;
    }
  }

  /// Start the location upload service
  ///
  /// [interval] - Upload interval in milliseconds (default: 60000ms / 1 minute)
  Future<void> startLocationUploadService({int interval = 60000}) async {
    try {
      // Check if service is already running
      final bool isRunning = await isLocationUploadServiceRunning();
      if (isRunning) {
        printIfDebug(
          'Location upload service is already running, stopping first...',
        );
        await stopLocationUploadService();
      }

      if (interval <= 0) {
        throw PlatformException(
          code: 'INVALID_INTERVAL',
          message: 'Interval must be greater than 0',
        );
      }

      printIfDebug(
        'Starting location upload service with interval: $interval ms...',
      );
      await platform.invokeMethod('startLocationUploadService', {
        'interval': interval,
      });

      // Verify service started successfully
      final bool started = await isLocationUploadServiceRunning();
      if (!started) {
        throw PlatformException(
          code: 'SERVICE_ERROR',
          message: 'Failed to verify location upload service started',
        );
      }

      printIfDebug('Location upload service started successfully');
    } on PlatformException catch (e) {
      printIfDebug('Failed to start location upload service: ${e.message}');
      rethrow;
    }
  }

  /// Stop the location upload service
  Future<void> stopLocationUploadService() async {
    try {
      // Check if service is running before attempting to stop
      final bool isRunning = await isLocationUploadServiceRunning();
      if (!isRunning) {
        printIfDebug('Location upload service is not running, nothing to stop');
        return;
      }

      printIfDebug('Stopping location upload service...');
      await platform.invokeMethod('stopLocationUploadService');

      // Verify service stopped successfully
      final bool stopped = await isLocationUploadServiceRunning();
      if (stopped) {
        throw PlatformException(
          code: 'SERVICE_ERROR',
          message: 'Failed to verify location upload service stopped',
        );
      }

      printIfDebug('Location upload service stopped successfully');
    } on PlatformException catch (e) {
      printIfDebug('Failed to stop location upload service: ${e.message}');
      rethrow;
    }
  }
}
