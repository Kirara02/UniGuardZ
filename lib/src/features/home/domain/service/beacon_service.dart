import 'package:flutter/services.dart';

class BeaconService {
  static const platform = MethodChannel('com.uniguard.ugz_app/beacon_service');

  /// Initialize the beacon service with required parameters
  ///
  /// [token] - Authentication token
  /// [beaconIds] - List of valid beacon UUIDs to scan for
  /// [headers] - Additional headers for API requests
  Future<void> initialize({
    required String token,
    required List<String> beaconIds,
    required Map<String, String> headers,
  }) async {
    try {
      await platform.invokeMethod('initialize', {
        'token': token,
        'beaconIds': beaconIds,
        'headers': headers,
      });
    } on PlatformException catch (e) {
      print('Failed to initialize beacon service: ${e.message}');
      rethrow;
    }
  }

  /// Start the beacon scanning service
  Future<void> startBeaconService() async {
    try {
      print('Starting beacon service...');
      await platform.invokeMethod('startBeaconService');
      print('Beacon service started successfully');
    } on PlatformException catch (e) {
      print('Failed to start beacon service: ${e.message}');
      rethrow;
    }
  }

  /// Stop the beacon scanning service
  Future<void> stopBeaconService() async {
    try {
      await platform.invokeMethod('stopBeaconService');
    } on PlatformException catch (e) {
      print('Failed to stop beacon service: ${e.message}');
      rethrow;
    }
  }

  Future<void> uploadBeacons(List<Map<String, dynamic>> beacons) async {
    try {
      await platform.invokeMethod('uploadBeacons', {'beacons': beacons});
    } on PlatformException catch (e) {
      print('Failed to upload beacons: ${e.message}');
    }
  }
}
