import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/home/data/interface/checkpoint_repository.dart';
import 'package:ugz_app/src/features/home/data/repository/checkpoint_repository_impl.dart';
import 'package:ugz_app/src/features/home/domain/model/scan_nfc_submit_model.dart';
import 'package:ugz_app/src/features/home/domain/usecase/submit_checkpoint/submit_checkpoint_params.dart';
import 'package:ugz_app/src/utils/misc/result.dart';
import 'package:ugz_app/src/utils/misc/usecase.dart';

part 'submit_checkpoint_usecase.g.dart';

class SubmitCheckpoint
    implements UseCase<Result<ScanNfcSubmitModel>, SubmitCheckpointParams> {
  final CheckpointRepository _checkpointRepository;

  SubmitCheckpoint({required CheckpointRepository checkpointRepository})
    : _checkpointRepository = checkpointRepository;

  @override
  Future<Result<ScanNfcSubmitModel>> call(SubmitCheckpointParams params) async {
    final response = await _checkpointRepository.submitCheckpoint(
      params: params,
    );

    if (response.success && response.data != null) {
      return Result.success(response.data!);
    } else {
      return Result.failed(response.message);
    }
  }
}

@riverpod
SubmitCheckpoint submitCheckpoint(ref) => SubmitCheckpoint(
  checkpointRepository: ref.watch(checkpointRepositoryProvider),
);
