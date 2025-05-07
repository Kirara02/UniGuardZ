import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/home/domain/model/activity_model.dart';
import 'package:ugz_app/src/features/home/domain/usecase/get_activities/get_activities_params.dart';
import 'package:ugz_app/src/features/home/domain/usecase/get_activities/get_activities_usecase.dart';
import 'package:ugz_app/src/utils/misc/result.dart';

part 'activities_controller.g.dart';

class ActivitiesState {
  final List<ActivityModel> activities;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final int totalPages;
  final bool hasMore;

  const ActivitiesState({
    this.activities = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasMore = true,
  });

  ActivitiesState copyWith({
    List<ActivityModel>? activities,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
  }) {
    return ActivitiesState(
      activities: activities ?? this.activities,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

@riverpod
class ActivitiesController extends _$ActivitiesController {
  @override
  ActivitiesState build() {
    return const ActivitiesState();
  }

  Future<void> getActivities() async {
    state = state.copyWith(isLoading: true, error: null);

    GetActivities getActivities = ref.read(getActivitiesProvider);
    final result = await getActivities(GetActivitiesParams(limit: 10, page: 1));

    if (!ref.exists(activitiesControllerProvider)) return;

    switch (result) {
      case Success(value: final activities, meta: final meta):
        state = state.copyWith(
          activities: activities,
          isLoading: false,
          currentPage: 1,
          totalPages: meta?.total_pages ?? 1,
          hasMore:
              meta?.page != null &&
              meta?.total_pages != null &&
              meta!.page! < meta.total_pages!,
        );

      case Failed(message: final message):
        state = state.copyWith(isLoading: false, error: message);
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    GetActivities getActivities = ref.read(getActivitiesProvider);
    final result = await getActivities(
      GetActivitiesParams(limit: 10, page: state.currentPage + 1),
    );

    if (!ref.exists(activitiesControllerProvider)) return;

    switch (result) {
      case Success(value: final activities, meta: final meta):
        state = state.copyWith(
          activities: [...state.activities, ...activities],
          isLoadingMore: false,
          currentPage: state.currentPage + 1,
          totalPages: meta?.total_pages ?? state.totalPages,
          hasMore:
              meta?.page != null &&
              meta?.total_pages != null &&
              meta!.page! < meta.total_pages!,
        );

      case Failed(message: final message):
        state = state.copyWith(isLoadingMore: false, error: message);
    }
  }
}
