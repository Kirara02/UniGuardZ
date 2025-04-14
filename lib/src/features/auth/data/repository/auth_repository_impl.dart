import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/auth/data/interface/auth_repository.dart';
import 'package:ugz_app/src/features/auth/domain/model/login_response.dart';
import 'package:ugz_app/src/features/auth/domain/model/user.dart';
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
      "web-api/account/profile",
      converter: (json) => User.fromJson(json),
    );
  }

  @override
  Future<ApiResponse<LoginResponse>> login({
    required LoginParams params,
  }) async {
    return await _dioClient.postApiResponse<LoginResponse>(
      "web-api/auth/login",
      data: {
        "email": params.email.trimEndSpaces,
        "password": params.password.trimEndSpaces,
      },
      converter: (json) => LoginResponse.fromJson(json),
    );
  }
}

@riverpod
AuthRepository authRepository(ref) =>
    AuthRepositoryImpl(dioClient: ref.watch(dioClientKeyProvider));
