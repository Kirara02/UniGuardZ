import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/constants/endpoint.dart';
import 'package:ugz_app/src/features/home/data/interface/checkpoint_repository.dart';
import 'package:ugz_app/src/features/home/domain/model/checkpoint_model.dart';
import 'package:ugz_app/src/features/home/domain/model/scan_nfc_submit_model.dart';
import 'package:ugz_app/src/features/home/domain/usecase/submit_checkpoint/submit_checkpoint_params.dart';
import 'package:ugz_app/src/global_providers/global_providers.dart';
import 'package:ugz_app/src/utils/storage/dio/api_response.dart';
import 'package:ugz_app/src/utils/storage/dio/dio_client.dart';

part 'checkpoint_repository_impl.g.dart';

class CheckpointRepositoryImpl implements CheckpointRepository {
  final DioClient _dioClient;

  CheckpointRepositoryImpl({required DioClient dioClient})
    : _dioClient = dioClient;

  @override
  Future<ApiResponse<ScanNfcSubmitModel>> submitCheckpoint({
    required SubmitCheckpointParams params,
  }) async {
    // data: {
    //   "type": "beacon", // Beacon || NFC
    //   "beacon": {
    //     "minor_value": "DUMMY_MINOR_VALUE",
    //     "major_value": "DUMMY_MAJOR_VALUE",
    //     "battery_level": 80
    //   }, // opsional tapi wajib diisi jika type nya beacon
    //   "nfc": {
    //     "hex": "DUMMY_HEX"
    //   }, // opsional tapi wajib diisi jika type nya nfc
    //   "latitude": -6.2088,
    //   "longitude": 106.8456,
    //   "original_submitted_time": "2025-04-04T23:10:00Z"
    // },

    final Map<String, dynamic> data = {
      "type": params.type,
      "latitude": params.latitude,
      "longitude": params.longitude,
      "original_submitted_time": params.submitTime,
    };

    if (params.type == "beacon" && params.beaconData != null) {
      data["beacon"] = params.beaconData!.toJson();
    }

    if (params.type == "nfc" && params.nfcData != null) {
      data["nfc"] = params.nfcData!.toJson();
    }

    return await _dioClient.postApiResponse(
      CheckpointUrl.submit,
      data: data,
      converter: (json) => ScanNfcSubmitModel.fromJson(json),
    );
  }

  @override
  Future<ApiResponse<List<CheckpointModel>>> getCheckpoints({
    required int checkpointType,
  }) async {
    return await _dioClient.getApiListResponse<CheckpointModel>(
      CheckpointUrl.get,
      queryParameters: {
        'checkpoint_type_id': checkpointType,
        // 1 = BEACONS, 2 = NFC, 3 = RFID, 4 = GEOFENCE
      },
      itemConverter: (json) => CheckpointModel.fromJson(json),
    );
  }
}

@riverpod
CheckpointRepository checkpointRepository(ref) =>
    CheckpointRepositoryImpl(dioClient: ref.watch(dioClientKeyProvider));
