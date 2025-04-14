import 'package:ugz_app/src/features/home/domain/model/checkpoint_model.dart';
import 'package:ugz_app/src/features/home/domain/model/scan_nfc_submit_model.dart';
import 'package:ugz_app/src/features/home/domain/usecase/submit_checkpoint/submit_checkpoint_params.dart';
import 'package:ugz_app/src/utils/storage/dio/api_response.dart';

abstract interface class CheckpointRepository {
  Future<ApiResponse<ScanNfcSubmitModel>> submitNfcScan({
    required String checkpointId,
    required double latitude,
    required double longitude,
    required String timeSubmit,
  });

  Future<ApiResponse<ScanNfcSubmitModel>> submitCheckpoint({
    required SubmitCheckpointParams params,
  });

  Future<ApiResponse<List<CheckpointModel>>> getCheckpoints({
    required int checkpointType,
    required String token,
    required String buildCode,
    required String deviceName,
    required String deviceId,
  });
}
