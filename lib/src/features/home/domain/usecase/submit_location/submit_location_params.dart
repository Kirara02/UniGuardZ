class SubmitLocationParams {
  final String token;
  final String buildCode;
  final String deviceName;
  final String deviceId;
  final double latitude;
  final double longitude;

  SubmitLocationParams({
    required this.token,
    required this.buildCode,
    required this.deviceName,
    required this.deviceId,
    required this.latitude,
    required this.longitude,
  });
}
