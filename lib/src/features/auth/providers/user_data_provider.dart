import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/auth/domain/model/user.dart';
import 'package:ugz_app/src/features/auth/domain/usecase/get_user/get_user_usecase.dart';
import 'package:ugz_app/src/features/auth/domain/usecase/login/login_params.dart';
import 'package:ugz_app/src/features/auth/domain/usecase/login/login_usecase.dart';
import 'package:ugz_app/src/global_providers/global_providers.dart';
import 'package:ugz_app/src/utils/misc/result.dart';

part 'user_data_provider.g.dart';

@Riverpod(keepAlive: true)
class UserData extends _$UserData {
  @override
  FutureOr<User?> build() async {
    final credentials = ref.read(credentialsProvider);

    if (credentials == null) return null;

    GetUser getLoggedInUser = ref.read(getUserProvider);

    var result = await getLoggedInUser(null);

    switch (result) {
      case Success(value: final user):
        return user;
      case Failed(message: _):
        return null;
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();

    Login login = ref.read(loginProvider);

    var result = await login(LoginParams(email: email, password: password));

    switch (result) {
      case Success(value: final data):
        ref.read(credentialsProvider.notifier).update(data.accessToken);
        state = AsyncData(data.user);
      case Failed(:final message):
        state = AsyncError(FlutterError(message), StackTrace.current);
        state = const AsyncData(null);
    }
  }

  Future<void> logout() async {
    try {
      state = const AsyncData(null);

      ref.read(credentialsProvider.notifier).update(null);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      state = const AsyncData(null);
    }
  }
}
