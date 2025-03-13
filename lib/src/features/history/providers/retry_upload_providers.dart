import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/constants/enum.dart';
import 'package:ugz_app/src/features/auth/providers/user_data_provider.dart';
import 'package:ugz_app/src/features/home/domain/usecase/submit_activity/submit_activity_params.dart';
import 'package:ugz_app/src/features/home/domain/usecase/submit_activity/submit_activity_usecase.dart';
import 'package:ugz_app/src/features/home/domain/usecase/submit_form/submit_form_params.dart';
import 'package:ugz_app/src/features/home/domain/usecase/submit_form/submit_form_usecase.dart';
import 'package:ugz_app/src/features/home/domain/usecase/submit_task/submit_task_params.dart';
import 'package:ugz_app/src/features/home/domain/usecase/submit_task/submit_task_usecase.dart';
import 'package:ugz_app/src/local/record/pending_forms_model.dart';
import 'package:ugz_app/src/local/repository/pending_forms_repository_impl.dart';
import 'package:ugz_app/src/local/usecases/get_pending_forms/get_pending_forms.dart';
import 'package:ugz_app/src/local/usecases/get_pending_forms/get_pending_forms_params.dart';
import 'package:ugz_app/src/utils/misc/print.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';

part 'retry_upload_providers.g.dart';

class UploadResult {
  final bool isSuccess;
  final String? errorMessage;

  UploadResult({required this.isSuccess, this.errorMessage});
}

class RetryUploadState {
  final bool isUploading;
  final int? currentItemId;
  final String? error;

  RetryUploadState({this.isUploading = false, this.currentItemId, this.error});

  RetryUploadState copyWith({
    bool? isUploading,
    int? currentItemId,
    String? error,
  }) {
    return RetryUploadState(
      isUploading: isUploading ?? this.isUploading,
      currentItemId: currentItemId ?? this.currentItemId,
      error: error,
    );
  }
}

@riverpod
class RetryUploadStateNotifier extends _$RetryUploadStateNotifier {
  @override
  RetryUploadState build() => RetryUploadState();

  void setUploading(bool isUploading, {int? itemId, String? error}) {
    state = state.copyWith(
      isUploading: isUploading,
      currentItemId: itemId,
      error: error,
    );
  }
}

@riverpod
class RetryUpload extends _$RetryUpload {
  @override
  void build() {}

  Future<UploadResult> retryUploadSingle(PendingFormsModel form) async {
    final pendingFormsRepo = ref.read(pendingFormsRepositoryProvider);

    // Set uploading state
    ref
        .read(retryUploadStateNotifierProvider.notifier)
        .setUploading(true, itemId: form.id);

    try {
      final category = PendingFormCategory.fromValue(form.category);
      bool success = false;

      // Call the appropriate upload function based on category
      switch (category) {
        case PendingFormCategory.forms:
          success = await _uploadForm(form);
          break;
        case PendingFormCategory.tasks:
          success = await _uploadTask(form);
          break;
        case PendingFormCategory.activity:
          success = await _uploadActivity(form);
          break;
        default:
          throw Exception("Unknown form category: ${form.category}");
      }

      if (success) {
        print("success");
        // Delete from local DB if upload was successful
        await pendingFormsRepo.deleteById(form.id);
        ref.read(retryUploadStateNotifierProvider.notifier).setUploading(false);
        return UploadResult(isSuccess: true);
      } else {
        print("failed");

        ref
            .read(retryUploadStateNotifierProvider.notifier)
            .setUploading(false, error: "Failed to upload to server");
        return UploadResult(
          isSuccess: false,
          errorMessage: "Network error or server not responding",
        );
      }
    } catch (e) {
      printIfDebug("Error uploading form: $e");
      ref
          .read(retryUploadStateNotifierProvider.notifier)
          .setUploading(false, error: e.toString());
      return UploadResult(
        isSuccess: false,
        errorMessage: "Error: ${e.toString()}",
      );
    }
  }

  Future<UploadResult> retryUploadAll() async {
    final pendingFormsRepo = ref.read(pendingFormsRepositoryProvider);

    // Set uploading state
    ref.read(retryUploadStateNotifierProvider.notifier).setUploading(true);

    try {
      final user = ref.read(userDataProvider).valueOrNull;

      // Get all pending forms
      final pendingForms = ref.read(dbGetPendingFormsProvider);
      final result = await pendingForms(
        GetPendingFormsParams(userId: user?.id.toInt ?? 0),
      );

      int successCount = 0;
      List<String> errors = [];

      // Process each form with a delay between requests to avoid overwhelming the server
      for (final form in result) {
        ref
            .read(retryUploadStateNotifierProvider.notifier)
            .setUploading(true, itemId: form.id);

        try {
          final category = PendingFormCategory.fromValue(form.category);
          bool success = false;

          // Call the appropriate upload function based on category
          switch (category) {
            case PendingFormCategory.forms:
              success = await _uploadForm(form);
              break;
            case PendingFormCategory.tasks:
              success = await _uploadTask(form);
              break;
            case PendingFormCategory.activity:
              success = await _uploadActivity(form);
              break;
            default:
              throw Exception("Unknown form category: ${form.category}");
          }

          if (success) {
            // Delete from local DB if upload was successful
            await pendingFormsRepo.deleteById(form.id);
            successCount++;
          } else {
            errors.add("Failed to upload ${form.description} (network error)");
          }

          // Add a small delay between requests to avoid overwhelming the server
          await Future.delayed(const Duration(milliseconds: 500));
        } catch (e) {
          errors.add("Error uploading ${form.description}: $e");
        }
      }

      ref.read(retryUploadStateNotifierProvider.notifier).setUploading(false);

      if (errors.isEmpty) {
        return UploadResult(isSuccess: true);
      } else {
        return UploadResult(
          isSuccess: successCount > 0,
          errorMessage: errors.join(", "),
        );
      }
    } catch (e) {
      printIfDebug("Error uploading all forms: $e");
      ref
          .read(retryUploadStateNotifierProvider.notifier)
          .setUploading(false, error: e.toString());
      return UploadResult(isSuccess: false, errorMessage: e.toString());
    }
  }

  // Separate function for uploading forms
  Future<bool> _uploadForm(PendingFormsModel form) async {
    try {
      final submitFormUseCase = ref.read(submitFormProvider);

      // Extract fields and photos from form data
      final fields = _extractFormFields(form.data);
      final photos = _extractFormPhotos(form.data);

      final params = SubmitFormParams(
        id: form.formId.toString(),
        longitude: form.longitude ?? 0,
        latitude: form.latitude ?? 0,
        timestamp: form.timestamp.toIso8601String(),
        fields: fields,
        photos: photos,
      );

      final result = await submitFormUseCase(params);
      printIfDebug("submit form: ${result.resultValue}");

      return result.isSuccess;
    } catch (e) {
      printIfDebug("Error in _uploadForm: $e");
      return false;
    }
  }

  // Separate function for uploading tasks
  Future<bool> _uploadTask(PendingFormsModel form) async {
    try {
      final submitTaskUseCase = ref.read(submitTaskProvider);

      // Extract fields and photos from form data
      final fields = _extractTaskFields(form.data);
      final photos = _extractTaskPhotos(form.data);

      final params = SubmitTaskParams(
        id: form.formId.toString(),
        longitude: form.longitude ?? 0,
        latitude: form.latitude ?? 0,
        timestamp: form.timestamp.toIso8601String(),
        fields: fields,
        photos: photos,
      );

      final result = await submitTaskUseCase(params);
      printIfDebug("submit task: ${result.resultValue}");

      return result.isSuccess;
    } catch (e) {
      printIfDebug("Error in _uploadTask: $e");
      return false;
    }
  }

  // Separate function for uploading activities
  Future<bool> _uploadActivity(PendingFormsModel form) async {
    try {
      final submitActivityUseCase = ref.read(submitActivityProvider);

      // Extract comment and photo from form data
      final comment = _extractComment(form.data);
      final photo = _extractPhoto(form.data);
      final params = SubmitActivityParams(
        id: form.formId.toString(), // Add null check here
        latitude: form.latitude ?? 0.0,
        longitude: form.longitude ?? 0.0,
        comment: comment ?? "", // Ensure comment is never null
        photo:
            photo != null && photo.isNotEmpty
                ? File(photo)
                : null, // Add empty check
        timestamp: form.timestamp,
      );

      final result = await submitActivityUseCase(params);

      printIfDebug("submit activity: ${result.resultValue}");

      return result.isSuccess;
    } catch (e) {
      printIfDebug("Error in _uploadActivity: $e");
      return false;
    }
  }

  // Helper methods to extract data from the pending form
  List<FormField> _extractFormFields(Map<String, dynamic> data) {
    final List<FormField> fields = [];

    if (data.containsKey('comments') && data['comments'] is List) {
      final commentsList = data['comments'] as List;
      for (var comment in commentsList) {
        fields.add(
          FormField(
            id: comment['id'].toString(),
            fieldTypeId: "2", // Text
            fieldTypeName: "text",
            formFieldName: comment['inputName'] ?? "Comment",
            value: comment['value'] ?? "",
          ),
        );
      }
    }

    if (data.containsKey('switches') && data['switches'] is List) {
      final switchesList = data['switches'] as List;
      for (var switchItem in switchesList) {
        fields.add(
          FormField(
            id: switchItem['id'].toString(),
            fieldTypeId: "3", // Checkbox
            fieldTypeName: "checkbox",
            formFieldName: switchItem['inputName'] ?? "Switch",
            value:
                (switchItem['value'] == "true" || switchItem['value'] == "1")
                    ? "1"
                    : "0",
          ),
        );
      }
    }

    if (data.containsKey('photos') && data['photos'] is List) {
      final photosList = data['photos'] as List;
      for (var photo in photosList) {
        fields.add(
          FormField(
            id: photo['id'].toString(),
            fieldTypeId: "4",
            fieldTypeName: "image",
            formFieldName: photo['inputName'] ?? "Photo",
            value: "file_${photo['id']}",
          ),
        );
      }
    }

    if (data.containsKey('signatures') && data['signatures'] is List) {
      final signaturesList = data['signatures'] as List;
      for (var signature in signaturesList) {
        fields.add(
          FormField(
            id: signature['id'].toString(),
            fieldTypeId: "5",
            fieldTypeName: "signature",
            formFieldName: "Signature ${signature['id']}",
            value: "signature_${signature['id']}",
          ),
        );
      }
    }

    if (data.containsKey('selects') && data['selects'] is List) {
      final selectsList = data['selects'] as List;
      for (var select in selectsList) {
        fields.add(
          FormField(
            id: select['id'].toString(),
            fieldTypeId: "6",
            fieldTypeName: "options",
            formFieldName: select['inputName'] ?? "Select",
            value: select['value'] ?? "",
          ),
        );
      }
    }

    return fields;
  }

  List<FormPhoto> _extractFormPhotos(Map<String, dynamic> data) {
    final List<FormPhoto> photos = [];

    if (data.containsKey('photos') && data['photos'] is List) {
      final photosList = data['photos'] as List;
      for (var photo in photosList) {
        if (photo['value'] != null) {
          photos.add(
            FormPhoto(
              id: photo['id'].toString(),
              filePath: photo['value'].toString(),
            ),
          );
        }
      }
    }

    if (data.containsKey('signatures') && data['signatures'] is List) {
      final signaturesList = data['signatures'] as List;
      for (var signature in signaturesList) {
        if (signature['value'] != null) {
          photos.add(
            FormPhoto(
              id: signature['id'].toString(),
              filePath: signature['value'].toString(),
            ),
          );
        }
      }
    }

    return photos;
  }

  List<TaskField> _extractTaskFields(Map<String, dynamic> data) {
    final List<TaskField> fields = [];

    if (data.containsKey('comments') && data['comments'] is List) {
      final commentsList = data['comments'] as List;
      for (var comment in commentsList) {
        fields.add(
          TaskField(
            id: comment['id'].toString(),
            fieldTypeId: "2", // Text
            fieldTypeName: "text",
            taskFieldName: comment['inputName'] ?? "Comment",
            value: comment['value'] ?? "",
          ),
        );
      }
    }

    if (data.containsKey('switches') && data['switches'] is List) {
      final switchesList = data['switches'] as List;
      for (var switchItem in switchesList) {
        fields.add(
          TaskField(
            id: switchItem['id'].toString(),
            fieldTypeId: "3", // Checkbox
            fieldTypeName: "checkbox",
            taskFieldName: switchItem['inputName'] ?? "Switch",
            value:
                (switchItem['value'] == "true" || switchItem['value'] == "1")
                    ? "1"
                    : "0",
          ),
        );
      }
    }

    if (data.containsKey('photos') && data['photos'] is List) {
      final photosList = data['photos'] as List;
      for (var photo in photosList) {
        fields.add(
          TaskField(
            id: photo['id'].toString(),
            fieldTypeId: "4",
            fieldTypeName: "image",
            taskFieldName: photo['inputName'] ?? "Photo",
            value: "file_${photo['id']}",
          ),
        );
      }
    }

    if (data.containsKey('signatures') && data['signatures'] is List) {
      final signaturesList = data['signatures'] as List;
      for (var signature in signaturesList) {
        fields.add(
          TaskField(
            id: signature['id'].toString(),
            fieldTypeId: "5",
            fieldTypeName: "signature",
            taskFieldName: "Signature ${signature['id']}",
            value: "signature_${signature['id']}",
          ),
        );
      }
    }

    if (data.containsKey('selects') && data['selects'] is List) {
      final selectsList = data['selects'] as List;
      for (var select in selectsList) {
        fields.add(
          TaskField(
            id: select['id'].toString(),
            fieldTypeId: "6",
            fieldTypeName: "options",
            taskFieldName: select['inputName'] ?? "Select",
            value: select['value'] ?? "",
          ),
        );
      }
    }

    return fields;
  }

  List<TaskPhoto> _extractTaskPhotos(Map<String, dynamic> data) {
    final List<TaskPhoto> photos = [];

    if (data.containsKey('photos') && data['photos'] is List) {
      final photosList = data['photos'] as List;
      for (var photo in photosList) {
        if (photo['value'] != null) {
          photos.add(
            TaskPhoto(
              id: photo['id'].toString(),
              filePath: photo['value'].toString(),
            ),
          );
        }
      }
    }

    if (data.containsKey('signatures') && data['signatures'] is List) {
      final signaturesList = data['signatures'] as List;
      for (var signature in signaturesList) {
        if (signature['value'] != null) {
          photos.add(
            TaskPhoto(
              id: signature['id'].toString(),
              filePath: signature['value'].toString(),
            ),
          );
        }
      }
    }

    return photos;
  }

  String? _extractComment(Map<String, dynamic> data) {
    if (data.containsKey('comments') &&
        data['comments'] is List &&
        data['comments'].isNotEmpty) {
      final comments = data['comments'] as List;
      if (comments.isNotEmpty && comments[0].containsKey('value')) {
        return comments[0]['value'].toString();
      }
    }
    return null;
  }

  String? _extractPhoto(Map<String, dynamic> data) {
    if (data.containsKey('photos') &&
        data['photos'] is List &&
        data['photos'].isNotEmpty) {
      final photos = data['photos'] as List;
      if (photos.isNotEmpty && photos[0].containsKey('value')) {
        final photoPath = photos[0]['value'].toString();
        return photoPath;
      }
    }
    return null;
  }
}
