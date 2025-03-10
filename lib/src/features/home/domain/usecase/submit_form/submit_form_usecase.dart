import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/home/data/interface/forms_repository.dart';
import 'package:ugz_app/src/features/home/data/repository/forms_repository_impl.dart';
import 'package:ugz_app/src/features/home/domain/usecase/submit_form/submit_form_params.dart';
import 'package:ugz_app/src/utils/misc/result.dart';
import 'package:ugz_app/src/utils/misc/usecase.dart';

part 'submit_form_usecase.g.dart';

class SubmitForm implements UseCase<Result<String>, SubmitFormParams> {
  final FormsRepository _formsRepository;

  SubmitForm({required FormsRepository formsRepository})
    : _formsRepository = formsRepository;

  @override
  Future<Result<String>> call(SubmitFormParams params) async {
    try {
      final multipartFiles = await params.toMultipartFiles();

      // Konversi params ke FormData
      final formData = FormData.fromMap({
        "data": json.encode({
          "longitude": params.longitude,
          "latitude": params.latitude,
          "original_submitted_time": params.timestamp,
          "fields": params.fields.map((field) => field.toJson()).toList(),
        }),
        ...multipartFiles,
      });

      final response = await _formsRepository.submitForm(
        id: params.id,
        data: formData,
      );

      if (response.success && response.data != null) {
        return Result.success(response.message);
      }
      return Result.failed(response.message);
    } catch (e) {
      throw Exception("Failed to submit form: $e");
    }
  }
}

@riverpod
SubmitForm submitForm(SubmitFormRef ref) =>
    SubmitForm(formsRepository: ref.watch(formsRepositoryProvider));
