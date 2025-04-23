import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/auth/domain/model/forgot_password_response.dart';
import 'package:ugz_app/src/features/auth/domain/usecase/forgot_password/forgot_password_params.dart';
import 'package:ugz_app/src/features/auth/domain/usecase/forgot_password/forgot_password_usecase.dart';
import 'package:ugz_app/src/utils/misc/result.dart';

part 'forgot_password_controller.g.dart';

@riverpod
class ForgotPasswordController extends _$ForgotPasswordController {
  @override
  FutureOr<ForgotPasswordResponse?> build() => null;

  Future<void> submit({required String email}) async {
    state = const AsyncLoading();

    ForgotPassword forgotPassword = ref.read(forgotPasswordProvider);

    var result = await forgotPassword(ForgotPasswordParams(email: email));

    switch (result) {
      case Success(value: final data):
        state = AsyncData(data);
      case Failed(:final message):
        state = AsyncError(FlutterError(message), StackTrace.current);
        state = const AsyncData(null);
    }
  }
}
