class NfcScanSubmitParams {
  final String checkpointId;
  final double latitude;
  final double longitude;
  final String timeSubmit;

  NfcScanSubmitParams({
    required this.checkpointId,
    required this.latitude,
    required this.longitude,
    required this.timeSubmit,
  });
}
