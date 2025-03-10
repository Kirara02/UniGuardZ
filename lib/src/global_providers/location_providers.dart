import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// Enum untuk status lokasi
enum LocationStatus { granted, denied, serviceDisabled, unknown }

/// Provider untuk mendapatkan lokasi dengan pengecekan izin & layanan otomatis
final locationProvider =
    FutureProvider<({LocationStatus status, Position? position})>((ref) async {
  // Periksa apakah layanan lokasi aktif
  if (!await Geolocator.isLocationServiceEnabled()) {
    return (status: LocationStatus.serviceDisabled, position: null);
  }

  // Periksa & minta izin lokasi
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    return (status: LocationStatus.denied, position: null);
  }

  // Dapatkan lokasi saat ini jika izin diberikan
  try {
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    return (status: LocationStatus.granted, position: position);
  } catch (e) {
    return (status: LocationStatus.unknown, position: null);
  }
});
