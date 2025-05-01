import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/home/data/interface/checkpoint_repository.dart';
import 'package:ugz_app/src/features/home/data/repository/checkpoint_repository_impl.dart';
import 'package:ugz_app/src/features/home/domain/model/checkpoint_model.dart';
import 'package:ugz_app/src/features/home/domain/usecase/get_checkpoints/get_checkpoints_params.dart';
import 'package:ugz_app/src/utils/misc/result.dart';
import 'package:ugz_app/src/utils/misc/usecase.dart';

part 'get_checkpoints_usecase.g.dart';

class GetCheckpoints
    implements UseCase<Result<List<CheckpointModel>>, GetCheckpointsParams> {
  final CheckpointRepository _checkpointRepository;

  GetCheckpoints({required CheckpointRepository checkpointRepository})
    : _checkpointRepository = checkpointRepository;

  @override
  Future<Result<List<CheckpointModel>>> call(
    GetCheckpointsParams params,
  ) async {
    final response = await _checkpointRepository.getCheckpoints(
      checkpointType: params.checkpointType,
    );

    if (response.success && response.data != null) {
      return Result.success(response.data!);
    }

    return Result.failed(response.message);
  }
}

@riverpod
GetCheckpoints getCheckpoints(ref) => GetCheckpoints(
  checkpointRepository: ref.watch(checkpointRepositoryProvider),
);
