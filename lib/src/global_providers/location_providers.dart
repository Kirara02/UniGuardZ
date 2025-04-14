import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// Enum untuk status lokasi
enum LocationStatus { granted, denied, serviceDisabled, unknown }

final locationTriggerProvider = StateProvider<int>((ref) => 0);

/// Provider untuk mendapatkan lokasi dengan pengecekan izin & layanan otomatis
final locationProvider =
    FutureProvider<({LocationStatus status, Position? position})>((ref) async {
      final trigger = ref.watch(locationTriggerProvider); // listen ke trigger

      if (!await Geolocator.isLocationServiceEnabled()) {
        return (status: LocationStatus.serviceDisabled, position: null);
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return (status: LocationStatus.denied, position: null);
      }

      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        return (status: LocationStatus.granted, position: position);
      } catch (e) {
        return (status: LocationStatus.unknown, position: null);
      }
    });
