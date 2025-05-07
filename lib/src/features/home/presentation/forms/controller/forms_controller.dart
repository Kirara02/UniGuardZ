import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/home/domain/model/form_model.dart';
import 'package:ugz_app/src/features/home/domain/usecase/get_forms/get_forms_params.dart';
import 'package:ugz_app/src/features/home/domain/usecase/get_forms/get_forms_usecase.dart';
import 'package:ugz_app/src/utils/misc/result.dart';

part 'forms_controller.g.dart';

class FormsState {
  final List<FormModel> forms;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final int totalPages;
  final bool hasMore;

  const FormsState({
    this.forms = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasMore = true,
  });

  FormsState copyWith({
    List<FormModel>? forms,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
  }) {
    return FormsState(
      forms: forms ?? this.forms,
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
class FormsController extends _$FormsController {
  @override
  FormsState build() {
    return const FormsState();
  }

  Future<void> getForms() async {
    state = state.copyWith(isLoading: true, error: null);

    GetForms getForms = ref.read(getFormsProvider);
    final result = await getForms(GetFormsParams(limit: 10, page: 1));

    if (!ref.exists(formsControllerProvider)) return;

    switch (result) {
      case Success(value: final forms, meta: final meta):
        state = state.copyWith(
          forms: forms,
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

    GetForms getForms = ref.read(getFormsProvider);
    final result = await getForms(
      GetFormsParams(limit: 10, page: state.currentPage + 1),
    );

    if (!ref.exists(formsControllerProvider)) return;

    switch (result) {
      case Success(value: final forms, meta: final meta):
        state = state.copyWith(
          forms: [...state.forms, ...forms],
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
