import 'package:flutter/material.dart';

/// {@template text_field_outline_border}
/// A custom [MaterialStateOutlineInputBorder] that changes the color of the
/// outline based on the current state of the [TextField].
/// {@endtemplate}
class TextFieldOutlineBorder extends MaterialStateOutlineInputBorder {
  /// {@macro text_field_outline_border}
  const TextFieldOutlineBorder({
    required this.scheme,
  });

  /// The color scheme used to resolve the color of the outline.
  final ColorScheme scheme;

  @override
  InputBorder resolve(Set<MaterialState> states) {
    final isFocused = states.contains(MaterialState.focused);

    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: isFocused ? scheme.primary : scheme.outline,
        width: 1.5,
      ),
    );
  }
}
