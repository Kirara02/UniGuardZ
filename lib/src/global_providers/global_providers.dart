import 'dart:convert';
import 'dart:io';

import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/constants/db_keys.dart';
import 'package:ugz_app/src/constants/enum.dart';
import 'package:ugz_app/src/channel/uniguard_service.dart';
import 'package:ugz_app/src/local/db/uniguard_db.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';
import 'package:ugz_app/src/utils/mixin/shared_preferences_client_mixin.dart';
import 'package:ugz_app/src/utils/storage/dio/background_network_module.dart';
import 'package:ugz_app/src/utils/storage/dio/dio_client.dart';
import 'package:ugz_app/src/utils/storage/dio/network_module.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'global_providers.g.dart';

@riverpod
DioClient dioClientKey(DioClientKeyRef ref) => DioClient(
  dio: ref
      .watch(networkModuleProvider)
      .provideDio(
        baseUrl: DBKeys.serverUrl.initial,
        authType: ref.watch(authTypeKeyProvider) ?? DBKeys.authType.initial,
        hiveCacheStore: ref.watch(hiveCacheStoreProvider),
        ref: ref,
      ),
);

@riverpod
DioClient backgroundDioClientKey(BackgroundDioClientKeyRef ref) => DioClient(
  dio: ref
      .watch(backgroundNetworkModuleProvider)
      .provideDio(baseUrl: DBKeys.serverUrl.initial),
);

@riverpod
class AuthTypeKey extends _$AuthTypeKey
    with SharedPreferenceEnumClientMixin<AuthType> {
  @override
  AuthType? build() => initialize(DBKeys.authType, enumList: AuthType.values);
}

@riverpod
class Credentials extends _$Credentials
    with SharedPreferenceClientMixin<String> {
  @override
  String? build() => initialize(DBKeys.credentials);

  void updateBasicAuth({required String username, required String password}) {
    final basicAuth =
        'Basic ${base64.encode(utf8.encode('$username:$password'))}';
    update(basicAuth);
  }

  void updateBearerToken(String token) {
    update(token);
  }
}

@riverpod
class DeviceName extends _$DeviceName with SharedPreferenceClientMixin<String> {
  @override
  String? build() => initialize(DBKeys.deviceName);
}

@riverpod
class DeviceId extends _$DeviceId with SharedPreferenceClientMixin<String> {
  @override
  String? build() => initialize(DBKeys.deviceId);
}

@riverpod
class L10n extends _$L10n with SharedPreferenceClientMixin<Locale> {
  Map<String, String> toJson(Locale locale) => {
    if (locale.countryCode.isNotBlank) "countryCode": locale.countryCode!,
    if (locale.languageCode.isNotBlank) "languageCode": locale.languageCode,
    if (locale.scriptCode.isNotBlank) "scriptCode": locale.scriptCode!,
  };
  Locale? fromJson(dynamic json) =>
      json is! Map<String, dynamic> || (json["languageCode"] == null)
          ? null
          : Locale.fromSubtags(
            languageCode: json["languageCode"]!.toString(),
            scriptCode: json["scriptCode"]?.toString(),
            countryCode: json["countryCode"]?.toString(),
          );
  @override
  Locale? build() =>
      initialize(DBKeys.l10n, fromJson: fromJson, toJson: toJson);
}

@riverpod
UniguardDB appDatabase(AppDatabaseRef ref) {
  return UniguardDB.instance();
}

@riverpod
SharedPreferences sharedPreferences(ref) => throw UnimplementedError();

@riverpod
Directory? appDirectory(ref) => throw UnimplementedError();

@riverpod
PackageInfo packageInfo(ref) => throw UnimplementedError();

@riverpod
HiveCacheStore hiveCacheStore(HiveCacheStoreRef ref) =>
    HiveCacheStore(ref.watch(appDirectoryProvider)?.path);

@riverpod
UniguardService uniguardService(ref) => UniguardService();
