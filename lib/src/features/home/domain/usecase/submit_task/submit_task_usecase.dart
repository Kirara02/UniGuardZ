import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/home/data/interface/forms_repository.dart';
import 'package:ugz_app/src/features/home/data/repository/forms_repository_impl.dart';
import 'package:ugz_app/src/features/home/domain/usecase/submit_task/submit_task_params.dart';
import 'package:ugz_app/src/utils/misc/result.dart';
import 'package:ugz_app/src/utils/misc/usecase.dart';

part 'submit_task_usecase.g.dart';

class SubmitTask implements UseCase<Result<String>, SubmitTaskParams> {
  final FormsRepository _formsRepository;

  SubmitTask({required FormsRepository formsRepository})
    : _formsRepository = formsRepository;

  @override
  Future<Result<String>> call(SubmitTaskParams params) async {
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

      final response = await _formsRepository.submitTask(
        id: params.id,
        data: formData,
      );

      if (response.success && response.data != null) {
        return Result.success(response.message);
      }
      return Result.failed(response.message, code: response.error?.code);
    } catch (e) {
      throw Exception("Failed to submit task: $e");
    }
  }
}

@riverpod
SubmitTask submitTask(ref) =>
    SubmitTask(formsRepository: ref.watch(formsRepositoryProvider));
