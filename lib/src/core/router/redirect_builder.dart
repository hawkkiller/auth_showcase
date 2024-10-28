import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A builder for the redirect function.
final class RedirectBuilder {
  final Set<RedirectGuard> _guards;

  /// Creates a [RedirectBuilder] with a list of [RedirectGuard]s.
  const RedirectBuilder(this._guards);

  /// Redirects the user to a new location based on the [RedirectGuard]s.
  ///
  /// If the location matches the [RedirectGuard.matchPattern],
  /// the [RedirectGuard.redirect] function will be called.
  String? call(BuildContext context, GoRouterState state) {
    for (final guard in _guards) {
      final matched =
          guard.matchPattern.matchAsPrefix(state.matchedLocation) != null;

      // If location matches and invert is false, redirect.
      // If location doesn't match and invert is true, redirect.
      if (matched != guard.invertMatch) {
        final result = guard.redirect(context, state);

        if (result != null) return result;
      }
    }

    return null;
  }
}

/// A guard is a function that is called before the route is built.
abstract base class RedirectGuard {
  /// The pattern to match the location.
  Pattern get matchPattern;

  /// If true, the [redirect] function will be called
  /// when the location does not match the [matchPattern].
  ///
  /// If false, the [redirect] function will be called
  /// when the location matches the [matchPattern].
  bool get invertMatch => false;

  /// The redirect function to be called when
  /// the location matches the [matchPattern].
  String? redirect(BuildContext context, GoRouterState state);
}
