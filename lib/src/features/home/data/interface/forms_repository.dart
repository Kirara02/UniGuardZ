import 'package:dio/dio.dart';
import 'package:ugz_app/src/features/home/domain/model/activity_model.dart';
import 'package:ugz_app/src/features/home/domain/model/activity_submit_model.dart';
import 'package:ugz_app/src/features/home/domain/model/form_model.dart';
import 'package:ugz_app/src/features/home/domain/model/form_submit_model.dart';
import 'package:ugz_app/src/features/home/domain/model/task_model.dart';
import 'package:ugz_app/src/features/home/domain/model/task_submit_model.dart';
import 'package:ugz_app/src/utils/storage/dio/api_response.dart';

abstract interface class FormsRepository {
  Future<ApiResponse<List<ActivityModel>>> getActivities({
    int? limit,
    int? page,
  });
  Future<ApiResponse<List<TaskModel>>> getTasks({int? limit, int? page});
  Future<ApiResponse<List<FormModel>>> getForms({int? limit, int? page});
  Future<ApiResponse<ActivityModel>> getActivityById({required String id});
  Future<ApiResponse<TaskModel>> getTaskById({required String id});
  Future<ApiResponse<FormModel>> getFormById({required String id});
  Future<ApiResponse<ActivitySubmitModel>> submitActivity({
    required FormData data,
    required String id,
  });
  Future<ApiResponse<TaskSubmitModel>> submitTask({
    required FormData data,
    required String id,
  });
  Future<ApiResponse<FormSubmitModel>> submitForm({
    required FormData data,
    required String id,
  });
}
