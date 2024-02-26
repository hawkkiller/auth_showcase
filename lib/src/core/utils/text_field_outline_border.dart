import 'package:flutter/material.dart';

class TextFieldOutlineBorder extends MaterialStateOutlineInputBorder {
  /// {@macro text_field_outline_border}
  const TextFieldOutlineBorder({
    required this.scheme,
  });

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
