import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizzle_starter/src/core/localization/localization.dart';
import 'package:sizzle_starter/src/core/router/routes.dart';
import 'package:sizzle_starter/src/feature/auth/logic/auth_interceptor.dart';
import 'package:sizzle_starter/src/feature/auth/widget/auth_scope.dart';

final _themeData = ThemeData(
  useMaterial3: true,
  textTheme: GoogleFonts.rubikTextTheme(),
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
);

/// {@template material_context}
/// [MaterialContext] is an entry point to the material context.
///
/// This widget sets locales, themes and routing.
/// {@endtemplate}
class MaterialContext extends StatefulWidget {
  /// {@macro material_context}
  const MaterialContext({super.key});

  // This global key is needed for [MaterialApp]
  // to work properly when Widgets Inspector is enabled.
  static final _globalKey = GlobalKey();

  @override
  State<MaterialContext> createState() => _MaterialContextState();
}

class _MaterialContextState extends State<MaterialContext> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      initialLocation: '/login',
      routes: $appRoutes,
      redirect: (context, state) {
        final scope = AuthScope.of(context);
        final loggingIn = state.matchedLocation == '/login';

        if (scope.status == AuthenticationStatus.unauthenticated) {
          return '/login';
        }

        if (loggingIn) {
          return '/dashboard';
        }

        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        key: MaterialContext._globalKey,
        theme: _themeData,
        routerConfig: _router,
        localizationsDelegates: Localization.localizationDelegates,
        supportedLocales: Localization.supportedLocales,
        builder: (context, child) => MediaQuery.withClampedTextScaling(
          minScaleFactor: 1.0,
          maxScaleFactor: 2.0,
          child: child!,
        ),
      );
}
