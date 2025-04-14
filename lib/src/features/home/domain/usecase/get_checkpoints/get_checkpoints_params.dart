class GetCheckpointsParams {
  final int checkpointType;
  final String token;
  final String buildCode;
  final String deviceName;
  final String deviceId;

  GetCheckpointsParams({
    required this.checkpointType,
    required this.token,
    required this.buildCode,
    required this.deviceName,
    required this.deviceId,
  });
}
