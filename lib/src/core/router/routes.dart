import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:sizzle_starter/src/feature/login/widget/login_screen.dart';

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
