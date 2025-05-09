import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/constants/endpoint.dart';
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
  Future<ApiResponse<List<ActivityModel>>> getActivities({
    int? limit,
    int? page,
  }) async {
    final queryParameters = <String, dynamic>{
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
    };

    return await _dioClient.getApiListResponse<ActivityModel>(
      FormUrl.activity,
      queryParameters: queryParameters,
      itemConverter: (json) {
        return ActivityModel.fromJson(json);
      },
    );
  }

  @override
  Future<ApiResponse<List<FormModel>>> getForms({int? limit, int? page}) async {
    final queryParameters = <String, dynamic>{
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
    };

    return await _dioClient.getApiListResponse<FormModel>(
      FormUrl.form,
      queryParameters: queryParameters,
      itemConverter: (json) {
        return FormModel.fromJson(json);
      },
    );
  }

  @override
  Future<ApiResponse<List<TaskModel>>> getTasks({int? limit, int? page}) async {
    final queryParameters = <String, dynamic>{
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
    };

    return await _dioClient.getApiListResponse<TaskModel>(
      FormUrl.task,
      queryParameters: queryParameters,
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
      FormUrl.submitActivity(id),
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
      FormUrl.submitForm(id),
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
      FormUrl.submitTask(id),
      data: data,
      converter: (json) => TaskSubmitModel.fromJson(json),
    );
  }

  @override
  Future<ApiResponse<ActivityModel>> getActivityById({
    required String id,
  }) async {
    return await _dioClient.getApiResponse(
      FormUrl.activityWithId(id),
      converter: (json) => ActivityModel.fromJson(json),
    );
  }

  @override
  Future<ApiResponse<FormModel>> getFormById({required String id}) async {
    return await _dioClient.getApiResponse(
      FormUrl.formWithId(id),
      converter: (json) => FormModel.fromJson(json),
    );
  }

  @override
  Future<ApiResponse<TaskModel>> getTaskById({required String id}) async {
    return await _dioClient.getApiResponse(
      FormUrl.taskWithId(id),
      converter: (json) => TaskModel.fromJson(json),
    );
  }
}

@riverpod
FormsRepository formsRepository(ref) =>
    FormsRepositoryImpl(dioClient: ref.watch(dioClientKeyProvider));
