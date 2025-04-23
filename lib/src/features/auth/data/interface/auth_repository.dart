import 'package:ugz_app/src/features/auth/domain/model/forgot_password_response.dart';
import 'package:ugz_app/src/features/auth/domain/model/login_response.dart';
import 'package:ugz_app/src/features/auth/domain/model/user.dart';
import 'package:ugz_app/src/features/auth/domain/usecase/forgot_password/forgot_password_params.dart';
import 'package:ugz_app/src/features/auth/domain/usecase/login/login_params.dart';
import 'package:ugz_app/src/utils/storage/dio/api_response.dart';

abstract interface class AuthRepository {
  Future<ApiResponse<LoginResponse>> login({required LoginParams params});
  Future<ApiResponse<ForgotPasswordResponse>> forgotPassword({
    required ForgotPasswordParams params,
  });
  Future<ApiResponse<User>> getUser();
}
