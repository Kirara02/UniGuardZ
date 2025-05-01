import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/home/domain/model/checkpoint_model.dart';
import 'package:ugz_app/src/features/home/domain/usecase/get_checkpoints/get_checkpoints_params.dart';
import 'package:ugz_app/src/features/home/domain/usecase/get_checkpoints/get_checkpoints_usecase.dart';
import 'package:ugz_app/src/utils/misc/print.dart';
import 'package:ugz_app/src/utils/misc/result.dart';

part 'beacon_providers.g.dart';

@riverpod
class Beacons extends _$Beacons {
  @override
  FutureOr<List<CheckpointModel>> build() async => [];

  Future<List<CheckpointModel>> getBeacons() async {
    state = const AsyncLoading();

    GetCheckpoints getCheckpoints = ref.read(getCheckpointsProvider);
    final result = await getCheckpoints(
      GetCheckpointsParams(checkpointType: 1),
    );

    switch (result) {
      case Success(value: final checkpoints):
        state = AsyncData(checkpoints);
        printIfDebug(checkpoints);
        return checkpoints;

      case Failed(message: _):
        state = AsyncError(FlutterError, StackTrace.current);
        state = const AsyncData([]);
        return [];
    }
  }
}
