import 'package:ugz_app/src/features/home/domain/model/scan_nfc_submit_model.dart';
import 'package:ugz_app/src/utils/storage/dio/api_response.dart';

abstract interface class CheckpointRepository {
  Future<ApiResponse<ScanNfcSubmitModel>> submitNfcScan({
    required String checkpointId,
    required double latitude,
    required double longitude,
    required String timeSubmit,
  });
}
