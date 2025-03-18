import 'package:flutter/material.dart';

import 'enum.dart';

enum DBKeys {
  serverUrl("https://ugz-api-668795567730.asia-southeast1.run.app"),
  serverPort(null),
  themeMode(ThemeMode.system),
  authType(AuthType.bearer),
  credentials(null),
  refreshCredentials(null),
  l10n(Locale('en')),
  alarm(false),
  alarmId(null),
  buildCode(0),
  deviceId(null),
  deviceName(null);

  const DBKeys(this.initial);

  final dynamic initial;
}
