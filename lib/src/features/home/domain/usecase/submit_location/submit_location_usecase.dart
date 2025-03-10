
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/home/data/interface/geolocation_repository.dart';
import 'package:ugz_app/src/features/home/data/repository/geolocation_repository_impl.dart';
import 'package:ugz_app/src/features/home/domain/usecase/submit_location/submit_location_params.dart';
import 'package:ugz_app/src/utils/misc/usecase.dart';

part 'submit_location_usecase.g.dart';

class SubmitLocation implements UseCase<String, SubmitLocationParams> {
  final GeolocationRepository _geolocationRepository;

  SubmitLocation({required GeolocationRepository geolocationRepository})
      : _geolocationRepository = geolocationRepository;

  @override
  Future<String> call(SubmitLocationParams params) async {
    final response = await _geolocationRepository.uploadLocation(
      latitude: params.latitude,
      longitude: params.longitude,
      token: params.token,
      buildCode: params.buildCode,
    );

    return response.message;
  }
}

@riverpod
SubmitLocation submitLocation(SubmitLocationRef ref) =>
    SubmitLocation(geolocationRepository: ref.watch(geolocationRepositoryProvider));