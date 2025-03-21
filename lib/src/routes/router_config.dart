import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/constants/enum.dart';
import 'package:ugz_app/src/features/auth/presentation/forgot_password/forgot_password_screen.dart';
import 'package:ugz_app/src/features/auth/presentation/login/login_screen.dart';
import 'package:ugz_app/src/features/auth/presentation/splash/splash_screen.dart';
import 'package:ugz_app/src/features/history/presentation/history/history_screen.dart';
import 'package:ugz_app/src/features/history/presentation/history_detail/history_detail_screen.dart';
import 'package:ugz_app/src/features/home/presentation/activities/activities_screen.dart';
import 'package:ugz_app/src/features/home/presentation/activity/activity_screen.dart';
import 'package:ugz_app/src/features/home/presentation/form/form_screen.dart';
import 'package:ugz_app/src/features/home/presentation/forms/forms_screen.dart';
import 'package:ugz_app/src/features/home/presentation/home/home_screen.dart';
import 'package:ugz_app/src/features/home/presentation/scan/scan_screen.dart';
import 'package:ugz_app/src/features/home/presentation/task/task_screen.dart';
import 'package:ugz_app/src/features/home/presentation/tasks/tasks_screen.dart';
import 'package:ugz_app/src/features/settings/presentation/about/about_screen.dart';
import 'package:ugz_app/src/features/settings/presentation/change_password/change_password_screen.dart';
import 'package:ugz_app/src/features/settings/presentation/profile/profile_screen.dart';
import 'package:ugz_app/src/features/settings/presentation/settings/settings_screen.dart';
import 'package:ugz_app/src/widgets/shell/shell_screen.dart';

part 'router_config.g.dart';
part 'sub_routes/auth_routes.dart';
part 'sub_routes/shell_routes.dart';
part 'sub_routes/home_routes.dart';
part 'sub_routes/history_routes.dart';
part 'sub_routes/settings_routes.dart';
part 'sub_routes/scan_routes.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'shell',
);

abstract class Routes {
  static const splash = '/';
  static const login = '/login';
  static const forgot_password = '/forgot-password';

  static const mainpage = '/main';
  static const home = '/home';

  static const formRoute = '/form';
  static const taskRoute = '/task';
  static const activityRoute = '/activity';

  static const task = 'task/:taskId';
  static const form = 'form/:formId';
  static const activity = 'activity/:activityId';

  static const history = '/history';
  static const historyDetail = 'history/:historyId/:historyType';

  static const scan = '/scan';

  static const settings = '/settings';
  static const profile = 'profile';
  static const about = 'about';
  static const change_password = 'change-password';
}

@riverpod
GoRouter routerConfig(ref) {
  return GoRouter(
    routes: $appRoutes,
    debugLogDiagnostics: true,
    initialLocation: Routes.splash,
    navigatorKey: rootNavigatorKey,
  );
}
