import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizzle_starter/src/core/localization/localization.dart';
import 'package:sizzle_starter/src/core/router/routes.dart';

const _colorScheme = ColorScheme.light(
  primary: Color(0xFF4C7EDE),
  outline: Color(0xFFE2E2E2),
  onSurface: Color(0xFF5D5E64),
  onBackground: Color(0xFF141319),
);

final _themeData = ThemeData(
  useMaterial3: true,
  colorScheme: _colorScheme,
  textTheme: GoogleFonts.rubikTextTheme(),
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
    );
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
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
