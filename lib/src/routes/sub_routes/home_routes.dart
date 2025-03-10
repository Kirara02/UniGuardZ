part of '../router_config.dart';

class HomeRoute extends GoRouteData {
  const HomeRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      const NoTransitionPage(child: HomeScreen());
}

@TypedGoRoute<ActivitiesRoute>(
  path: Routes.activityRoute,
  routes: [TypedGoRoute<ActivityRoute>(path: Routes.activity)],
)
class ActivitiesRoute extends GoRouteData {
  const ActivitiesRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => ActivitiesScreen();
}

class ActivityRoute extends GoRouteData {
  const ActivityRoute({required this.activityId});
  final String activityId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ActivityScreen(activityId: activityId);
}

@TypedGoRoute<TasksRoute>(
  path: Routes.taskRoute,
  routes: [TypedGoRoute<TaskRoute>(path: Routes.task)],
)
class TasksRoute extends GoRouteData {
  const TasksRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => TasksScreen();
}

class TaskRoute extends GoRouteData {
  const TaskRoute({required this.taskId});
  final String taskId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      TaskScreen(taskId: taskId);
}

@TypedGoRoute<FormsRoute>(
  path: Routes.formRoute,
  routes: [TypedGoRoute<FormRoute>(path: Routes.form)],
)
class FormsRoute extends GoRouteData {
  const FormsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => FormsScreen();
}

class FormRoute extends GoRouteData {
  const FormRoute({required this.formId});
  final String formId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      FormScreen(formId: formId);
}
