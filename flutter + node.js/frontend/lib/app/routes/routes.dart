part of 'app_routes.dart';

/// Path definitions for use throughout the app
class AppPaths {
  // Private constructor
  AppPaths._();
  static const String auth = '/auth';
  static const String dashboard = '/dashboard';
}

class AppRouteNames {
  static const String auth = 'auth';
  static const String dashboard = 'dashboard';
}

/// -----------------------------------------------------------------------------
/// Device route definition
/// -----------------------------------------------------------------------------
@TypedGoRoute<DashboardRoute>(path: AppPaths.dashboard, name: AppRouteNames.dashboard)
class DashboardRoute extends GoRouteData {
  const DashboardRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => DashboardScreen();
}

/// -----------------------------------------------------------------------------
/// Auth route definition
/// -----------------------------------------------------------------------------
@TypedGoRoute<AuthRoute>(path: AppPaths.auth, name: AppRouteNames.auth)
class AuthRoute extends GoRouteData {
  const AuthRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const AuthScreen();
}
