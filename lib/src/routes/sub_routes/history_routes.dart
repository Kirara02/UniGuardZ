part of '../router_config.dart';

class HistoryRoute extends GoRouteData {
  const HistoryRoute();
  
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      const NoTransitionPage(
        child: HistoryScreen(),
      );
}