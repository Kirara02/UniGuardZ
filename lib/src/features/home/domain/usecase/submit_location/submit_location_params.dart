class SubmitLocationParams {
  final String token;
  final String buildCode;
  final double latitude;
  final double longitude;

  SubmitLocationParams({
    required this.token,
    required this.buildCode,
    required this.latitude,
    required this.longitude,
  });
}
