part of '../router_config.dart';

@TypedGoRoute<ScanRoute>(path: Routes.scan)
class ScanRoute extends GoRouteData {
  const ScanRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => ScanScreen();
}
