import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:sizzle_starter/src/feature/auth/widget/login_screen.dart';
import 'package:sizzle_starter/src/feature/dashboard/widget/dashboard_screen.dart';

part 'routes.g.dart';

/// LoginRoute is a route for the login screen.
@TypedGoRoute<LoginRoute>(path: '/login')
class LoginRoute extends GoRouteData {
  /// LoginRoute constructor
  const LoginRoute();

  @override
  Widget build(
    BuildContext context,
    GoRouterState state,
  ) =>
      const LoginScreen();
}

/// DashboardRoute is a route for the dashboard screen.
@TypedGoRoute<DashboardRoute>(path: '/dashboard')
class DashboardRoute extends GoRouteData {
  /// DashboardRoute constructor
  const DashboardRoute();

  @override
  Widget build(
    BuildContext context,
    GoRouterState state,
  ) =>
      const DashboardScreen();
}
