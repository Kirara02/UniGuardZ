class SubmitCheckpointParams {
  final String type;
  BeaconData? beaconData;
  NfcData? nfcData;
  final double latitude;
  final double longitude;
  final String submitTime;
  final String token;
  final String buildCode;
  final String deviceName;
  final String deviceId;

  SubmitCheckpointParams({
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.submitTime,
    this.beaconData,
    this.nfcData,
    required this.token,
    required this.buildCode,
    required this.deviceName,
    required this.deviceId,
  });
}

class BeaconData {
  final String minor;
  final String major;
  final int battery;

  BeaconData({required this.minor, required this.major, required this.battery});

  Map<String, dynamic> toJson() => {
    "minor_value": minor,
    "major_value": major,
    "battery_level": battery,
  };
}

class NfcData {
  final String hex;

  NfcData({required this.hex});

  Map<String, dynamic> toJson() => {"hex": hex};
}
