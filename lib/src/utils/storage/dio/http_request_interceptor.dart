import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:ugz_app/src/constants/enum.dart';
import 'package:ugz_app/src/features/auth/providers/user_data_provider.dart';
import 'package:ugz_app/src/global_providers/global_providers.dart';
import 'package:ugz_app/src/routes/router_config.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';
import 'package:ugz_app/src/utils/misc/toast/toast.dart';

class HttpRequestInterceptor extends Interceptor {
  final Ref ref;
  final Dio dio;

  HttpRequestInterceptor(this.ref, this.dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final credentials = ref.read(credentialsProvider);
    final authType = ref.read(authTypeKeyProvider);
    final appBuild = ref.read(packageInfoProvider).buildNumber;
    final deviceName = ref.read(deviceNameProvider);
    final deviceId = ref.read(deviceIdProvider);

    options.headers['x-app-build'] = appBuild;
    options.headers['x-device-name'] = deviceName;
    options.headers['x-device-uid'] = deviceId;

    if (authType == AuthType.basic) {
      if (credentials.isNotBlank) {
        options.headers.putIfAbsent(
          "Authorization",
          () => 'Basic $credentials',
        );
      } else {
        if (kDebugMode) {
          debugPrint('Basic credentials are null');
        }
      }
    } else if (authType == AuthType.bearer) {
      if (credentials.isNotBlank) {
        options.headers.putIfAbsent(
          "Authorization",
          () => 'Bearer $credentials',
        );
      } else {
        if (kDebugMode) {
          debugPrint('Bearer token is null');
        }
      }
    }

    Logger().i("request to path: ${options.path}");

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Handle token expiration
    if (response.statusCode == 401 &&
        ref.read(authTypeKeyProvider) == AuthType.bearer &&
        !response.requestOptions.path.contains('/login')) {
      final userDataNotifier = ref.read(userDataProvider.notifier);
      final context = rootNavigatorKey.currentContext;

      userDataNotifier.logout();
      if (context != null) {
        final toast = ref.read(toastProvider(context));
        toast.show(response.data['message'], withMicrotask: true);
        LoginRoute().go(context);
      }

      Logger().i(response.data['message']);
    }

    super.onResponse(response, handler);
  }
}
