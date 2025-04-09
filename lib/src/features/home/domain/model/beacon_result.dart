class BeaconResult {
  final String name;
  final String uuid;
  final String macAddress;
  final String major;
  final String minor;
  final String distance;
  final String proximity;
  final String scanTime;
  final String rssi;
  final String txPower;

  BeaconResult({
    required this.name,
    required this.uuid,
    required this.macAddress,
    required this.major,
    required this.minor,
    required this.distance,
    required this.proximity,
    required this.scanTime,
    required this.rssi,
    required this.txPower,
  });

  factory BeaconResult.fromJson(Map<String, dynamic> json) {
    return BeaconResult(
      name: json['name'] ?? '',
      uuid: json['uuid'] ?? '',
      macAddress: json['macAddress'] ?? '',
      major: json['major']?.toString() ?? '',
      minor: json['minor']?.toString() ?? '',
      distance: json['distance']?.toString() ?? '',
      proximity: json['proximity'] ?? '',
      scanTime: json['scanTime'] ?? '',
      rssi: json['rssi']?.toString() ?? '',
      txPower: json['txPower']?.toString() ?? '',
    );
  }
}
