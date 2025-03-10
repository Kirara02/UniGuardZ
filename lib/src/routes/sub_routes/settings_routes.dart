part of '../router_config.dart';

@TypedGoRoute<SettingsRoute>(
  path: Routes.settings,
  routes: [
    TypedGoRoute<AboutRoute>(path: Routes.about),
    TypedGoRoute<ProfileRoute>(path: Routes.profile),
    TypedGoRoute<ChangePasswordRoute>(path: Routes.change_password),
  ],
)
class SettingsRoute extends GoRouteData {
  const SettingsRoute();

  static final $parentNavigatorKey = rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SettingsScreen();
}

class AboutRoute extends GoRouteData {
  const AboutRoute();


  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const AboutScreen();
}

class ProfileRoute extends GoRouteData {
  const ProfileRoute();


  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ProfileScreen();
}


class ChangePasswordRoute extends GoRouteData {
  const ChangePasswordRoute();


  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ChangePasswordScreen();
}