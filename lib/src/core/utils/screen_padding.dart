import 'dart:math' as math;

import 'package:flutter/material.dart';

/// {@template scaffold_padding}
/// ScaffoldPadding is a utility class that provides a consistent padding
/// {@endtemplate}
class ScreenPadding extends EdgeInsets {
  const ScreenPadding._(final double value)
      : super.symmetric(horizontal: value);

  /// {@macro scaffold_padding}
  factory ScreenPadding.of(BuildContext context, [int size = 768]) =>
      ScreenPadding._(
        math.max(
          (MediaQuery.sizeOf(context).width - size) / 2,
          16,
        ),
      );

  /// {@macro scaffold_padding}
  static Widget widget(
    BuildContext context, {
    Widget? child,
    int size = 768,
  }) =>
      Padding(
        padding: ScreenPadding.of(context, size),
        child: child,
      );

  /// {@macro scaffold_padding}
  static Widget sliver(
    BuildContext context, {
    Widget? sliver,
    int size = 768,
  }) =>
      SliverPadding(
        padding: ScreenPadding.of(context, size),
        sliver: sliver,
      );
}
