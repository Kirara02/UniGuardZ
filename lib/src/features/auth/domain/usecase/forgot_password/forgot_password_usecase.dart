import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/auth/data/interface/auth_repository.dart';
import 'package:ugz_app/src/features/auth/data/repository/auth_repository_impl.dart';
import 'package:ugz_app/src/features/auth/domain/model/forgot_password_response.dart';
import 'package:ugz_app/src/features/auth/domain/model/user.dart';
import 'package:ugz_app/src/features/auth/domain/usecase/forgot_password/forgot_password_params.dart';
import 'package:ugz_app/src/utils/misc/result.dart';
import 'package:ugz_app/src/utils/misc/usecase.dart';

part 'forgot_password_usecase.g.dart';

class ForgotPassword
    implements UseCase<Result<ForgotPasswordResponse>, ForgotPasswordParams> {
  final AuthRepository _authRepository;

  ForgotPassword({required AuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Result<ForgotPasswordResponse>> call(
    ForgotPasswordParams params,
  ) async {
    var result = await _authRepository.forgotPassword(params: params);

    if (result.success && result.data != null) {
      return Result.success(result.data!);
    } else {
      return Result.failed(result.message);
    }
  }
}

@riverpod
ForgotPassword forgotPassword(ref) =>
    ForgotPassword(authRepository: ref.watch(authRepositoryProvider));
