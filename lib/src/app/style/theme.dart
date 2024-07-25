import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginTheme {
  Color selectedColor = Color(0xFF4AC8EA);
  Color drawerBackgroundColor = Color(0xFF272D34);

  static const Color gradientStart = const Color(0xFF33D2FF);
  static const Color gradientEnd = const Color(0xFF6FACCE);

  static const primaryGradient = const LinearGradient(
    colors: const [gradientStart, gradientEnd],
    stops: const [0.0, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
