import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/home/data/interface/checkpoint_repository.dart';
import 'package:ugz_app/src/features/home/data/repository/checkpoint_repository_impl.dart';
import 'package:ugz_app/src/features/home/domain/model/scan_nfc_submit_model.dart';
import 'package:ugz_app/src/features/home/domain/usecase/nfc_scan_submit/nfc_scan_submit_params.dart';
import 'package:ugz_app/src/utils/misc/result.dart';
import 'package:ugz_app/src/utils/misc/usecase.dart';

part 'nfc_scan_submit_usecase.g.dart';

class NfcScanSubmit
    implements UseCase<Result<ScanNfcSubmitModel>, NfcScanSubmitParams> {
  final CheckpointRepository _checkpointRepository;

  NfcScanSubmit({required CheckpointRepository checkpointRepository})
    : _checkpointRepository = checkpointRepository;

  @override
  Future<Result<ScanNfcSubmitModel>> call(NfcScanSubmitParams params) async {
    final response = await _checkpointRepository.submitNfcScan(
      checkpointId: params.checkpointId,
      latitude: params.latitude,
      longitude: params.longitude,
      timeSubmit: params.timeSubmit,
    );

    if (response.success && response.data != null) {
      return Result.success(response.data!);
    } else {
      return Result.failed(response.message);
    }
  }
}

@riverpod
NfcScanSubmit nfcScanSubmit(ref) => NfcScanSubmit(
  checkpointRepository: ref.watch(checkpointRepositoryProvider),
);
