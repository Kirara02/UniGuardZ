import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/constants/enum.dart';
import 'package:ugz_app/src/features/home/domain/model/form_model.dart';
import 'package:ugz_app/src/features/home/domain/usecase/get_form_by_id/get_form_by_id_usecase.dart';
import 'package:ugz_app/src/features/home/domain/usecase/submit_form/submit_form_params.dart';
import 'package:ugz_app/src/features/home/domain/usecase/submit_form/submit_form_usecase.dart';
import 'package:ugz_app/src/local/record/form_data.dart';
import 'package:ugz_app/src/local/record/form_submit_record.dart';
import 'package:ugz_app/src/local/usecases/insert_pending_form/insert_pending_form.dart';
import 'package:ugz_app/src/local/usecases/insert_pending_form/insert_pending_form_params.dart';
import 'package:ugz_app/src/utils/misc/result.dart';

part 'form_controller.g.dart';

class CustomFormState {
  final FormModel? form;
  final bool isSubmitting;
  final bool isSubmitSuccess;
  final String? error;
  final bool isLoading;

  const CustomFormState({
    this.form,
    this.isSubmitting = false,
    this.isSubmitSuccess = false,
    this.error,
    this.isLoading = false,
  });

  CustomFormState copyWith({
    FormModel? form,
    bool? isSubmitting,
    bool? isSubmitSuccess,
    String? error,
    bool? isLoading,
  }) {
    return CustomFormState(
      form: form ?? this.form,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSubmitSuccess: isSubmitSuccess ?? this.isSubmitSuccess,
      error: error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

@riverpod
class FormController extends _$FormController {
  @override
  CustomFormState build(String? formId) {
    if (formId != null) {
      _fetchFormDetail(formId);
    }
    return const CustomFormState(isLoading: true);
  }

  Future<void> _fetchFormDetail(String formId) async {
    try {
      final getFormDetail = ref.read(getFormByIdProvider);
      final result = await getFormDetail(formId);

      switch (result) {
        case Success(value: final form):
          state = state.copyWith(form: form, isLoading: false);
        case Failed(message: final message):
          state = state.copyWith(error: message, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> submit({
    required String partitionKey,
    required String timestamp,
    required double? latitude,
    required double? longitude,
    required String description,
    required String formId,
    required FormData data,
  }) async {
    // Set submitting state
    state = state.copyWith(
      isSubmitting: true,
      isSubmitSuccess: false,
      error: null,
    );

    final List<FormField> fields = [];
    final List<FormPhoto> photos = [];

    // Handle comments (Text Input)
    fields.addAll(
      data.comments.map(
        (e) => FormField(
          id: e.id.toString(),
          fieldTypeId: e.typeId!, // Text
          fieldTypeName: "text",
          formFieldName: e.inputName!,
          value: e.value ?? "",
        ),
      ),
    );

    // Handle switches (Checkbox/Toggle)
    fields.addAll(
      data.switches.map(
        (e) => FormField(
          id: e.id.toString(),
          fieldTypeId: e.typeId!, // Checkbox
          fieldTypeName: "checkbox",
          formFieldName: e.inputName!,
          value: (e.value == "true" || e.value == "1") ? "true" : "false",
        ),
      ),
    );

    // Handle photos
    photos.addAll(
      data.photos.map(
        (e) => FormPhoto(
          id: e.id.toString(),
          filePath: e.value ?? "",
          type: FileType.File,
        ),
      ),
    );

    // Add photos to fields as references
    fields.addAll(
      data.photos.map(
        (e) => FormField(
          id: e.id.toString(),
          fieldTypeId: e.typeId!,
          fieldTypeName: "image",
          formFieldName: e.inputName!,
          value: "file_${e.id}",
        ),
      ),
    );

    // Handle signatures (treated like photos)
    photos.addAll(
      data.signatures.map(
        (e) => FormPhoto(
          id: e.id.toString(),
          filePath: e.value ?? "",
          type: FileType.Signature,
        ),
      ),
    );

    fields.addAll(
      data.signatures.map(
        (e) => FormField(
          id: e.id.toString(),
          fieldTypeId: e.typeId!,
          fieldTypeName: "signature",
          formFieldName: e.inputName!,
          value: "file_${e.id}",
        ),
      ),
    );

    // Handle selects (Dropdown, Radio, etc.)
    fields.addAll(
      data.selects.map(
        (e) => FormField(
          id: e.id.toString(),
          fieldTypeId: e.typeId!,
          fieldTypeName: "options",
          formFieldName: e.inputName!,
          value: e.value ?? "",
        ),
      ),
    );

    try {
      // Try submitting to API
      final success = await submitToApi(
        id: formId,
        latitude: latitude ?? 0.0,
        longitude: longitude ?? 0.0,
        timestamp: timestamp,
        fields: fields,
        photos: photos,
      );

      if (success) {
        state = state.copyWith(isSubmitting: false, isSubmitSuccess: true);
      } else {
        // If API fails, store in local DB
        await insertTask(
          params: InsertPendingFormParams(
            record: FormSubmitRecord(
              formId: formId,
              partitionKey: partitionKey,
              timestamp: timestamp,
              latitude: latitude,
              longitude: longitude,
              description: description,
              data: data,
            ),
          ),
        );
        state = state.copyWith(isSubmitting: false, isSubmitSuccess: true);
      }
    } catch (e) {
      // On error, store in local DB
      try {
        await insertTask(
          params: InsertPendingFormParams(
            record: FormSubmitRecord(
              formId: formId,
              partitionKey: partitionKey,
              timestamp: timestamp,
              latitude: latitude,
              longitude: longitude,
              description: description,
              data: data,
            ),
          ),
        );
        state = state.copyWith(isSubmitting: false, isSubmitSuccess: true);
      } catch (innerError) {
        state = state.copyWith(
          isSubmitting: false,
          error: "Failed to submit: $innerError",
        );
      }
    }
  }

  Future<void> insertTask({required InsertPendingFormParams params}) async {
    final insert = ref.read(dbInsertPendingFormProvider);
    await insert(params);
  }

  Future<bool> submitToApi({
    required String id,
    required double latitude,
    required double longitude,
    required String timestamp,
    required List<FormField> fields,
    required List<FormPhoto> photos,
  }) async {
    final submitFormUseCase = ref.read(submitFormProvider);

    try {
      final result = await submitFormUseCase(
        SubmitFormParams(
          id: id,
          latitude: latitude,
          longitude: longitude,
          timestamp: timestamp,
          fields: fields,
          photos: photos,
        ),
      );

      switch (result) {
        case Success(value: _):
          return true;
        case Failed(message: _):
          return false;
      }
    } catch (e) {
      return false;
    }
  }
}
