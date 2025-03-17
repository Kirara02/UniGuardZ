part of '../router_config.dart';

@TypedShellRoute<ShellRoute>(
  routes: [
    // Nested Routes
    TypedGoRoute<MainpageRoute>(path: Routes.mainpage),
    TypedGoRoute<HomeRoute>(path: Routes.home),
    TypedGoRoute<HistoryRoute>(path: Routes.history, routes: [
      TypedGoRoute<HistoryDetailRoute>(path: Routes.historyDetail),
    ]),
  ],
)
class ShellRoute extends ShellRouteData {
  const ShellRoute();

  static final $navigatorKey = _shellNavigatorKey;

  @override
  Widget builder(context, state, navigator) => ShellScreen(child: navigator);
}

class MainpageRoute extends GoRouteData {
  const MainpageRoute();
  @override
  FutureOr<String?> redirect(context, state) => Routes.home;
}