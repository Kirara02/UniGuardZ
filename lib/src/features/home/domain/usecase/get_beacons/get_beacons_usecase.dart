import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/home/data/interface/checkpoint_repository.dart';
import 'package:ugz_app/src/features/home/data/repository/checkpoint_repository_impl.dart';
import 'package:ugz_app/src/features/home/domain/model/beacon_model.dart';
import 'package:ugz_app/src/features/home/domain/usecase/get_beacons/get_beacons_params.dart';
import 'package:ugz_app/src/utils/misc/result.dart';
import 'package:ugz_app/src/utils/misc/usecase.dart';

part 'get_beacons_usecase.g.dart';

class GetBeacons
    implements UseCase<Result<List<BeaconModel>>, GetBeaconsParams> {
  final CheckpointRepository _checkpointRepository;

  GetBeacons({required CheckpointRepository checkpointRepository})
    : _checkpointRepository = checkpointRepository;

  @override
  Future<Result<List<BeaconModel>>> call(GetBeaconsParams params) async {
    final response = await _checkpointRepository.getBeacons(
      token: params.token,
      deviceId: params.deviceId,
      deviceName: params.deviceName,
      buildCode: params.buildCode,
    );

    if (response.success && response.data != null) {
      return Result.success(response.data!);
    }

    return Result.failed(response.message);
  }
}

@riverpod
GetBeacons getBeacons(ref) =>
    GetBeacons(checkpointRepository: ref.watch(checkpointRepositoryProvider));
