import 'package:ugz_app/src/features/auth/domain/model/login_response.dart';
import 'package:ugz_app/src/features/auth/domain/model/user.dart';
import 'package:ugz_app/src/features/auth/domain/usecase/login/login_params.dart';
import 'package:ugz_app/src/utils/storage/dio/api_response.dart';

abstract interface class AuthRepository {
  Future<ApiResponse<LoginResponse>> login({required LoginParams params});
  Future<ApiResponse<User>> getUser();
}
