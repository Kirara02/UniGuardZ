import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/home/data/interface/forms_repository.dart';
import 'package:ugz_app/src/features/home/data/repository/forms_repository_impl.dart';
import 'package:ugz_app/src/features/home/domain/model/activity_model.dart';
import 'package:ugz_app/src/utils/misc/result.dart';
import 'package:ugz_app/src/utils/misc/usecase.dart';

part 'get_activity_by_id_usecase.g.dart';

class GetActivityById implements UseCase<Result<ActivityModel>, String> {
  final FormsRepository _formsRepository;

  GetActivityById({required FormsRepository formsRepository})
    : _formsRepository = formsRepository;

  @override
  Future<Result<ActivityModel>> call(String params) async {
    final response = await _formsRepository.getActivityById(id: params);

    if (response.success && response.data != null) {
      return Result.success(response.data!);
    }
    return Result.failed(response.message);
  }
}

@riverpod
GetActivityById getActivityById(GetActivityByIdRef ref) =>
    GetActivityById(formsRepository: ref.watch(formsRepositoryProvider));
