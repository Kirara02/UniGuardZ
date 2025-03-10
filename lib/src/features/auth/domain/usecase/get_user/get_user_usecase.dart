import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/auth/data/interface/auth_repository.dart';
import 'package:ugz_app/src/features/auth/data/repository/auth_repository_impl.dart';
import 'package:ugz_app/src/features/auth/domain/model/user.dart';
import 'package:ugz_app/src/utils/misc/result.dart';
import 'package:ugz_app/src/utils/misc/usecase.dart';

part 'get_user_usecase.g.dart';

class GetUser implements UseCase<Result<User>, void> {
  final AuthRepository _authRepository;

  GetUser({required AuthRepository authRepository})
    : _authRepository = authRepository;
  @override
  Future<Result<User>> call(void params) async {
    var userResult = await _authRepository.getUser();

    if (userResult.success && userResult.data != null) {
      return Result.success(userResult.data!);
    } else {
      return Result.failed(userResult.message);
    }
  }
}

@riverpod
GetUser getUser(GetUserRef ref) =>
    GetUser(authRepository: ref.watch(authRepositoryProvider));
