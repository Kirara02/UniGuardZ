import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/home/data/interface/checkpoint_repository.dart';
import 'package:ugz_app/src/features/home/domain/model/scan_nfc_submit_model.dart';
import 'package:ugz_app/src/global_providers/global_providers.dart';
import 'package:ugz_app/src/utils/storage/dio/api_response.dart';
import 'package:ugz_app/src/utils/storage/dio/dio_client.dart';

part 'checkpoint_repository_impl.g.dart';

class CheckpointRepositoryImpl implements CheckpointRepository {
  final DioClient _dioClient;

  CheckpointRepositoryImpl({required DioClient dioClient})
    : _dioClient = dioClient;

  @override
  Future<ApiResponse<ScanNfcSubmitModel>> submitNfcScan({
    required String checkpointId,
    required double latitude,
    required double longitude,
    required String timeSubmit,
  }) async {
    return await _dioClient.postApiResponse(
      "mobile-api/admin/checkpoint/log",
      data: {
        "checkpoint_id": checkpointId,
        "latitude": latitude,
        "longitude": longitude,
        "original_submitted_time": timeSubmit,
      },
      converter: (json) => ScanNfcSubmitModel.fromJson(json),
    );
  }
}

@riverpod
CheckpointRepository checkpointRepository(ref) =>
    CheckpointRepositoryImpl(dioClient: ref.watch(dioClientKeyProvider));
