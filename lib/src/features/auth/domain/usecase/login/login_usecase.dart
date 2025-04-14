import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/auth/data/interface/auth_repository.dart';
import 'package:ugz_app/src/features/auth/data/repository/auth_repository_impl.dart';
import 'package:ugz_app/src/features/auth/domain/model/login_response.dart';
import 'package:ugz_app/src/features/auth/domain/usecase/login/login_params.dart';
import 'package:ugz_app/src/utils/misc/result.dart';
import 'package:ugz_app/src/utils/misc/usecase.dart';

part 'login_usecase.g.dart';

class Login implements UseCase<Result<LoginResponse>, LoginParams> {
  final AuthRepository _authRepository;

  Login({required AuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Result<LoginResponse>> call(LoginParams params) async {
    var response = await _authRepository.login(params: params);

    if (response.success && response.data != null) {
      final loginResponse = response.data;
      if (loginResponse?.user.mobileAccess == true) {
        return Result.success(loginResponse!);
      } else {
        return const Result.failed("Access denied: mobile access required.");
      }
    } else {
      return Result.failed(response.message);
    }
  }
}

@riverpod
Login login(ref) => Login(authRepository: ref.watch(authRepositoryProvider));
