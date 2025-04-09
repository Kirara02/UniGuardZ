import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/home/domain/model/nfc_tag_model.dart';
import 'package:ugz_app/src/features/home/domain/usecase/submit_checkpoint/submit_checkpoint_params.dart';
import 'package:ugz_app/src/features/home/domain/usecase/submit_checkpoint/submit_checkpoint_usecase.dart';
import 'package:ugz_app/src/global_providers/global_providers.dart';

part 'scan_controller.g.dart';

class ScanState {
  final bool isLoading;
  final bool isSubmitting;
  final NfcTagModel? tag;
  final String? error;

  const ScanState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.tag,
    this.error,
  });

  ScanState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    NfcTagModel? tag,
    String? error,
  }) {
    return ScanState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      tag: tag ?? this.tag,
      error: error ?? this.error,
    );
  }
}

@riverpod
class ScanController extends _$ScanController {
  @override
  ScanState build() {
    return const ScanState();
  }

  Future<void> startScanning() async {
    state = state.copyWith(isLoading: true, error: null, tag: null);

    try {
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          try {
            // Get card type and UID
            Map<String, dynamic>? cardDetails;
            String cardType = 'Unknown';
            String uid = 'Unknown';

            // Try to get card details from different NFC types
            if (tag.data['nfca'] != null) {
              cardDetails = Map<String, dynamic>.from(tag.data['nfca'] as Map);
              cardType = 'NFCA';
            } else if (tag.data['nfcb'] != null) {
              cardDetails = Map<String, dynamic>.from(tag.data['nfcb'] as Map);
              cardType = 'NFCB';
            } else if (tag.data['nfcf'] != null) {
              cardDetails = Map<String, dynamic>.from(tag.data['nfcf'] as Map);
              cardType = 'NFCF';
            } else if (tag.data['nfcv'] != null) {
              cardDetails = Map<String, dynamic>.from(tag.data['nfcv'] as Map);
              cardType = 'NFCV';
            } else if (tag.data['mifare'] != null) {
              cardDetails = Map<String, dynamic>.from(
                tag.data['mifare'] as Map,
              );
              cardType = 'Mifare';
            }

            // Get UID from card details
            if (cardDetails != null && cardDetails['identifier'] != null) {
              final identifier = cardDetails['identifier'] as List;
              uid =
                  identifier
                      .map((e) => e.toRadixString(16).padLeft(2, '0'))
                      .join('')
                      .toUpperCase();
            }

            // Create NFC tag model
            final nfcTag = NfcTagModel(
              uid: uid,
              type: cardType,
              rawData: tag.data,
              message: null, // We'll handle NDEF data separately if needed
            );

            // Stop NFC session as we've successfully read a tag
            NfcManager.instance.stopSession();

            // Update state with tag data
            state = state.copyWith(isLoading: false, tag: nfcTag);

            // Submit scan data
            await submitScan(nfcTag);
          } catch (e) {
            NfcManager.instance.stopSession();
            state = state.copyWith(
              isLoading: false,
              error: 'Error processing NFC tag: $e',
            );
          }
        },
        onError: (error) async {
          state = state.copyWith(isLoading: false, error: 'NFC Error: $error');
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error starting NFC session: $e',
      );
    }
  }

  Future<void> submitScan(NfcTagModel tag) async {
    state = state.copyWith(isSubmitting: true);

    try {
      // Get current position
      final position = await Geolocator.getCurrentPosition();

      // Get current time
      final now = DateTime.now();
      final timeSubmit = now.toIso8601String();

      // final result = await ref
      //     .read(nfcScanSubmitProvider)
      //     .call(
      //       NfcScanSubmitParams(
      //         checkpointId: tag.uid,
      //         latitude: position.latitude,
      //         longitude: position.longitude,
      //         timeSubmit: timeSubmit,
      //       ),
      //     );

      final packageInfo = await PackageInfo.fromPlatform();
      final credentials = ref.read(credentialsProvider);
      final buildCode = packageInfo.buildNumber;
      final deviceName = ref.read(deviceNameProvider);
      final deviceId = ref.read(deviceIdProvider);

      final result = await ref
          .read(submitCheckpointProvider)
          .call(
            SubmitCheckpointParams(
              type: "NFC",
              nfcData: NfcData(hex: tag.uid),
              latitude: position.latitude,
              longitude: position.longitude,
              submitTime: timeSubmit,
              token: credentials ?? "",
              buildCode: buildCode,
              deviceName: deviceName ?? "",
              deviceId: deviceId ?? "",
            ),
          );

      if (result.isSuccess) {
        state = state.copyWith(isSubmitting: false, error: null);
      } else {
        state = state.copyWith(
          isSubmitting: false,
          error: result.errorMessage ?? 'Failed to submit scan',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Error submitting scan: $e',
      );
    }
  }

  void stopScanning() {
    NfcManager.instance.stopSession();
  }

  void reset() {
    state = const ScanState();
  }
}
