import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/constants/endpoint.dart';
import 'package:ugz_app/src/features/auth/data/interface/auth_repository.dart';
import 'package:ugz_app/src/features/auth/domain/model/forgot_password_response.dart';
import 'package:ugz_app/src/features/auth/domain/model/login_response.dart';
import 'package:ugz_app/src/features/auth/domain/model/user.dart';
import 'package:ugz_app/src/features/auth/domain/usecase/forgot_password/forgot_password_params.dart';
import 'package:ugz_app/src/features/auth/domain/usecase/login/login_params.dart';
import 'package:ugz_app/src/global_providers/global_providers.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';
import 'package:ugz_app/src/utils/storage/dio/api_response.dart';
import 'package:ugz_app/src/utils/storage/dio/dio_client.dart';

part 'auth_repository_impl.g.dart';

class AuthRepositoryImpl implements AuthRepository {
  final DioClient _dioClient;

  AuthRepositoryImpl({required DioClient dioClient}) : _dioClient = dioClient;
  @override
  Future<ApiResponse<User>> getUser() async {
    return await _dioClient.getApiResponse<User>(
      AuthUrl.profile,
      converter: (json) => User.fromJson(json),
    );
  }

  @override
  Future<ApiResponse<LoginResponse>> login({
    required LoginParams params,
  }) async {
    return await _dioClient.postApiResponse<LoginResponse>(
      AuthUrl.login,
      data: {
        "email": params.email.trimEndSpaces,
        "password": params.password.trimEndSpaces,
      },
      converter: (json) => LoginResponse.fromJson(json),
    );
  }

  @override
  Future<ApiResponse<ForgotPasswordResponse>> forgotPassword({
    required ForgotPasswordParams params,
  }) async {
    return await _dioClient.postApiResponse<ForgotPasswordResponse>(
      AuthUrl.forgot_password,
      data: {"email": params.email.trimEndSpaces},
      converter: (json) => ForgotPasswordResponse.fromJson(json),
    );
  }
}

@riverpod
AuthRepository authRepository(ref) =>
    AuthRepositoryImpl(dioClient: ref.watch(dioClientKeyProvider));
