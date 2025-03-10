part of '../router_config.dart';


@TypedGoRoute<SplashRoute>(path: Routes.splash)
class SplashRoute extends GoRouteData {
  const SplashRoute();

  static final $parentNavigatorKey = rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) => const SplashScreen();
}

@TypedGoRoute<LoginRoute>(path: Routes.login)
class LoginRoute extends GoRouteData {
  const LoginRoute();

  static final $parentNavigatorKey = rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) => const LoginScreen();
}

@TypedGoRoute<ForgotPasswordRoute>(path: Routes.forgot_password)
class ForgotPasswordRoute extends GoRouteData {
  const ForgotPasswordRoute();

  static final $parentNavigatorKey = rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) => const ForgotPasswordScreen();
}