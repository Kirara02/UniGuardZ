import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/utils/service/geolocation_tracking_service.dart';

part 'geolocation_tracking_service_providers.g.dart';

@Riverpod(keepAlive: true)
class GeolocationService extends _$GeolocationService {
  late final GeolocationTrackingService _service;

  @override
  GeolocationTrackingService build() {
    _service = GeolocationTrackingService();
    _service.initialize();
    return _service;
  }

  Future<void> startTracking() async {
    await _service.startService(ref);
  }

  Future<void> stopTracking() async {
    await _service.stopService();
  }

  Future<bool> isTracking() async {
    return await _service.isRunning();
  }
}
