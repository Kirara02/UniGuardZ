import 'db_keys.dart';

abstract class Endpoints {
  // base url
  static String baseApi({
    String? baseUrl,
    int? port,
    bool addPort = true,
    bool appendApiToUrl = true,
  }) =>
      "${baseUrl ?? DBKeys.serverUrl.initial}"
      "${port != null && addPort ? ":$port" : ''}"
      "${appendApiToUrl ? '/' : ''}";

  // receiveTimeout
  static const Duration receiveTimeout = Duration(minutes: 1);

  // connectTimeout
  static const Duration connectionTimeout = Duration(minutes: 1);
}

abstract class AuthUrl {
  static const String login = 'web-api/auth/login';
  static const String forgot_password = 'web-api/auth/forgot-password';
  static const String profile = 'web-api/account/profile';
}

abstract class LogUrl {
  static const String logs = "mobile-api/admin/log-alert";
  static String withId(String logId) => "$logs/$logId";
}

abstract class AlarmUrl {
  static const String start = "mobile-api/admin/alarm/log/start";
  static String stop(String startId) =>
      "mobile-api/admin/alarm/log/stop/$startId";
}

abstract class CheckpointUrl {
  static const String submit = "mobile-api/admin/checkpoint/log";
  static const String get = "mobile-api/admin/checkpoint";
}

abstract class FormUrl {
  static const String activity = "mobile-api/admin/activity";
  static const String form = "mobile-api/admin/form";
  static const String task = "mobile-api/admin/task";

  static String activityWithId(String activityId) => "$activity/$activityId";
  static String formWithId(String formId) => "$form/$formId";
  static String taskWithId(String taskId) => "$task/$taskId";

  static String submitActivity(String activityId) =>
      "$activity/log/$activityId";
  static String submitForm(String formId) => "$form/log/$formId";
  static String submitTask(String taskId) => "$task/log/$taskId";
}
