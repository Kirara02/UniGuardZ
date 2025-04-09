import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/utils/service/geolocation_tracking_service.dart';
import 'package:ugz_app/src/utils/service/uniguard_background_service.dart';

part 'uniguard_background_service.g.dart';

@Riverpod(keepAlive: true)
class UniguardService extends _$UniguardService {
  late final UniguardBackgroundService _service;

  @override
  UniguardBackgroundService build() {
    _service = UniguardBackgroundService();
    _service.initialize();
    return _service;
  }

  Future<void> startService() async {
    await _service.startService(ref);
  }

  Future<void> stopService() async {
    await _service.stopService();
  }

  Future<bool> isServiceRunning() async {
    return await _service.isRunning();
  }
}
