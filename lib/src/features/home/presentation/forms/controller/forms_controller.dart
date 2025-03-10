import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/home/domain/model/form_model.dart';
import 'package:ugz_app/src/features/home/domain/usecase/get_forms/get_forms_usecase.dart';
import 'package:ugz_app/src/utils/misc/result.dart';

part 'forms_controller.g.dart';

@riverpod
class FormsController extends _$FormsController {
  @override
  FutureOr<List<FormModel>> build() => [];

  Future<void> getForms() async {
    state = const AsyncLoading();

    GetForms getForms = ref.read(getFormsProvider);
    final result = await getForms(null);

    if (!ref.exists(formsControllerProvider)) return;

    switch (result) {
      case Success(value: final forms):
        state = AsyncData(forms);

      case Failed(message: _):
        state = const AsyncData([]);
    }
  }
}
