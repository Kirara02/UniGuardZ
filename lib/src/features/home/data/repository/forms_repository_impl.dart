import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/home/data/interface/forms_repository.dart';
import 'package:ugz_app/src/features/home/domain/model/activity_model.dart';
import 'package:ugz_app/src/features/home/domain/model/activity_submit_model.dart';
import 'package:ugz_app/src/features/home/domain/model/form_model.dart';
import 'package:ugz_app/src/features/home/domain/model/form_submit_model.dart';
import 'package:ugz_app/src/features/home/domain/model/task_model.dart';
import 'package:ugz_app/src/features/home/domain/model/task_submit_model.dart';
import 'package:ugz_app/src/global_providers/global_providers.dart';
import 'package:ugz_app/src/utils/storage/dio/api_response.dart';
import 'package:ugz_app/src/utils/storage/dio/dio_client.dart';

part 'forms_repository_impl.g.dart';

class FormsRepositoryImpl implements FormsRepository {
  final DioClient _dioClient;

  FormsRepositoryImpl({required DioClient dioClient}) : _dioClient = dioClient;
  @override
  Future<ApiResponse<List<ActivityModel>>> getActivities() async {
    return await _dioClient.getApiListResponse<ActivityModel>(
      'mobile-api/admin/activity',
      itemConverter: (json) {
        return ActivityModel.fromJson(json);
      },
    );
  }

  @override
  Future<ApiResponse<List<FormModel>>> getForms() async {
    return await _dioClient.getApiListResponse<FormModel>(
      'mobile-api/admin/form',
      itemConverter: (json) {
        return FormModel.fromJson(json);
      },
    );
  }

  @override
  Future<ApiResponse<List<TaskModel>>> getTasks() async {
    return await _dioClient.getApiListResponse<TaskModel>(
      'mobile-api/admin/task',
      itemConverter: (json) {
        return TaskModel.fromJson(json);
      },
    );
  }

  @override
  Future<ApiResponse<ActivitySubmitModel>> submitActivity({
    required FormData data,
    required String id,
  }) async {
    return await _dioClient.postApiResponse<ActivitySubmitModel>(
      "mobile-api/admin/activity/log/$id",
      data: data,
      converter: (json) => ActivitySubmitModel.fromJson(json),
    );
  }

  @override
  Future<ApiResponse<FormSubmitModel>> submitForm({
    required FormData data,
    required String id,
  }) async {
    return await _dioClient.postApiResponse<FormSubmitModel>(
      "mobile-api/admin/form/log/$id",
      data: data,
      converter: (json) => FormSubmitModel.fromJson(json),
    );
  }

  @override
  Future<ApiResponse<TaskSubmitModel>> submitTask({
    required FormData data,
    required String id,
  }) async {
    return await _dioClient.postApiResponse<TaskSubmitModel>(
      "mobile-api/admin/task/log/$id",
      data: data,
      converter: (json) => TaskSubmitModel.fromJson(json),
    );
  }

  @override
  Future<ApiResponse<ActivityModel>> getActivityById({
    required String id,
  }) async {
    return await _dioClient.getApiResponse(
      "mobile-api/admin/activity/$id",
      converter: (json) => ActivityModel.fromJson(json),
    );
  }

  @override
  Future<ApiResponse<FormModel>> getFormById({required String id}) async {
    return await _dioClient.getApiResponse(
      "mobile-api/admin/form/$id",
      converter: (json) => FormModel.fromJson(json),
    );
  }

  @override
  Future<ApiResponse<TaskModel>> getTaskById({required String id}) async {
    return await _dioClient.getApiResponse(
      "mobile-api/admin/task/$id",
      converter: (json) => TaskModel.fromJson(json),
    );
  }
}

@riverpod
FormsRepository formsRepository(FormsRepositoryRef ref) =>
    FormsRepositoryImpl(dioClient: ref.watch(dioClientKeyProvider));
