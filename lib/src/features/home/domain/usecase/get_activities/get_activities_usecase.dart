import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/home/data/interface/forms_repository.dart';
import 'package:ugz_app/src/features/home/data/repository/forms_repository_impl.dart';
import 'package:ugz_app/src/features/home/domain/model/activity_model.dart';
import 'package:ugz_app/src/features/home/domain/usecase/get_activities/get_activities_params.dart';
import 'package:ugz_app/src/utils/misc/result.dart';
import 'package:ugz_app/src/utils/misc/usecase.dart';

part 'get_activities_usecase.g.dart';

class GetActivities
    implements UseCase<Result<List<ActivityModel>>, GetActivitiesParams> {
  final FormsRepository _formsRepository;

  GetActivities({required FormsRepository formsRepository})
    : _formsRepository = formsRepository;

  @override
  Future<Result<List<ActivityModel>>> call(GetActivitiesParams params) async {
    final response = await _formsRepository.getActivities(
      limit: params.limit,
      page: params.page,
    );

    if (response.success && response.data != null) {
      return Result.success(response.data!, meta: response.meta);
    }

    return Result.failed(response.message);
  }
}

@riverpod
GetActivities getActivities(ref) =>
    GetActivities(formsRepository: ref.watch(formsRepositoryProvider));
