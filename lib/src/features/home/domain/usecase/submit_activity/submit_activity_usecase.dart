import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/home/data/interface/forms_repository.dart';
import 'package:ugz_app/src/features/home/data/repository/forms_repository_impl.dart';
import 'package:ugz_app/src/features/home/domain/usecase/submit_activity/submit_activity_params.dart';
import 'package:ugz_app/src/utils/misc/print.dart';
import 'package:ugz_app/src/utils/misc/result.dart';
import 'package:ugz_app/src/utils/misc/usecase.dart';

part 'submit_activity_usecase.g.dart';

class SubmitActivity implements UseCase<Result<String>, SubmitActivityParams> {
  final FormsRepository _formsRepository;

  SubmitActivity({required FormsRepository formsRepository})
    : _formsRepository = formsRepository;

  @override
  Future<Result<String>> call(SubmitActivityParams params) async {
    final Map<String, dynamic> formDataMap = {
      if (params.latitude != null) "latitude": params.latitude,
      if (params.longitude != null) "longitude": params.longitude,
      if (params.comment != null) "comment": params.comment,
      "original_submitted_time": params.timestamp.toIso8601String(),
    };

    if (params.photo != null && params.photo!.path.isNotEmpty) {
      final File file = File(params.photo!.path);
      if (file.existsSync()) {
        String originalFilename = path.basename(params.photo!.path);
        printIfDebug("✅ Photo found: $originalFilename");

        formDataMap["photo"] = await MultipartFile.fromFile(
          file.path,
          filename: originalFilename,
        );
      }
    }

    final formData = FormData.fromMap(formDataMap);

    final response = await _formsRepository.submitActivity(
      data: formData,
      id: params.id,
    );

    if (response.success) {
      return Result.success(response.message);
    }
    return Result.failed(response.message);
  }
}

@riverpod
SubmitActivity submitActivity(SubmitActivityRef ref) =>
    SubmitActivity(formsRepository: ref.watch(formsRepositoryProvider));
