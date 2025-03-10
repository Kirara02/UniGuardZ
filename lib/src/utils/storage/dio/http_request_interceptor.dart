import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:ugz_app/src/constants/enum.dart';
import 'package:ugz_app/src/features/auth/providers/user_data_provider.dart';
import 'package:ugz_app/src/global_providers/global_providers.dart';
import 'package:ugz_app/src/routes/router_config.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';

class HttpRequestInterceptor extends Interceptor {
  final DioClientKeyRef ref;
  final Dio dio;

  HttpRequestInterceptor(this.ref, this.dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final credentials = ref.read(credentialsProvider);
    final authType = ref.read(authTypeKeyProvider);

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

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final authType = ref.read(authTypeKeyProvider);

    // Handle token expiration
    if (err.response?.statusCode == 401 &&
        authType == AuthType.bearer &&
        !err.requestOptions.path.contains('/login')) {
      final userDataNotifier = ref.read(userDataProvider.notifier);
      final context = rootNavigatorKey.currentContext;

      userDataNotifier.logout();
      if (context != null) {
        LoginRoute().go(context);
      }

      Logger().i(err.response?.data['message']);
    }

    return handler.next(err);
  }
}
