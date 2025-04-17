import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/home/domain/model/checkpoint_model.dart';
import 'package:ugz_app/src/features/home/domain/usecase/get_checkpoints/get_checkpoints_params.dart';
import 'package:ugz_app/src/features/home/domain/usecase/get_checkpoints/get_checkpoints_usecase.dart';
import 'package:ugz_app/src/global_providers/global_providers.dart';
import 'package:ugz_app/src/utils/misc/result.dart';
import 'package:ugz_app/src/channel/uniguard_service.dart';

part 'beacon_providers.g.dart';

@Riverpod(keepAlive: true)
class Beacons extends _$Beacons {
  @override
  FutureOr<List<CheckpointModel>> build() async => [];

  Future<List<CheckpointModel>> getBeacons() async {
    state = const AsyncLoading();

    final packageInfo = await PackageInfo.fromPlatform();
    final credentials = ref.read(credentialsProvider);
    final buildCode = packageInfo.buildNumber;
    final deviceName = ref.read(deviceNameProvider);
    final deviceId = ref.read(deviceIdProvider);

    GetCheckpoints getCheckpoints = ref.read(getCheckpointsProvider);
    final result = await getCheckpoints(
      GetCheckpointsParams(
        checkpointType: 1,
        token: credentials ?? '',
        buildCode: buildCode,
        deviceName: deviceName ?? '',
        deviceId: deviceId ?? '',
      ),
    );

    switch (result) {
      case Success(value: final checkpoints):
        state = AsyncData(checkpoints);
        print(checkpoints);
        return checkpoints;

      case Failed(message: _):
        state = AsyncError(FlutterError, StackTrace.current);
        state = const AsyncData([]);
        return [];
    }
  }
}
