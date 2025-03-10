import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/home/domain/model/activity_model.dart';
import 'package:ugz_app/src/features/home/domain/usecase/get_activities/get_activities.dart';
import 'package:ugz_app/src/utils/misc/result.dart';

part 'activities_controller.g.dart';

@riverpod
class ActivitiesController extends _$ActivitiesController {
  @override
  FutureOr<List<ActivityModel>> build() => [];

  Future<void> getActivities() async {
    state = const AsyncLoading();

    GetActivities getActivities = ref.read(getActivitiesProvider);
    final result = await getActivities(null);

    if (!ref.exists(activitiesControllerProvider)) return;

    switch (result) {
      case Success(value: final activities):
        state = AsyncData(activities);

      case Failed(message: _):
        state = const AsyncData([]);
    }
  }
}
