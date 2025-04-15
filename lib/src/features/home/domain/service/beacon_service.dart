import 'package:flutter/services.dart';
import 'package:ugz_app/src/utils/misc/print.dart';

class BeaconService {
  static const platform = MethodChannel(
    'com.uniguard.ugz_app/uniguard_service',
  );

  /// Initialize the beacon service with required parameters
  ///
  /// [headers] - Additional headers for API requests
  Future<void> startBeaconService({
    required Map<String, String> headers,
  }) async {
    try {
      printIfDebug('Starting beacon service...');
      await platform.invokeMethod('startBeaconService', {'headers': headers});
      printIfDebug('Beacon service started successfully');
    } on PlatformException catch (e) {
      printIfDebug('Failed to initialize beacon service: ${e.message}');
      rethrow;
    }
  }

  /// Stop the beacon scanning service
  Future<void> stopBeaconService() async {
    try {
      await platform.invokeMethod('stopBeaconService');
    } on PlatformException catch (e) {
      printIfDebug('Failed to stop beacon service: ${e.message}');
      rethrow;
    }
  }
}
