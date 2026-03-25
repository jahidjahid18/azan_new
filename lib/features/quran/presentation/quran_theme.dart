import 'package:flutter/material.dart';

class QuranUiTheme {
  static const LinearGradient heroGradient = LinearGradient(
    colors: <Color>[Color(0xFF063B2A), Color(0xFF0F766E), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient panelGradient = LinearGradient(
    colors: <Color>[Color(0xFF0B1426), Color(0xFF10213A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient softBackground = LinearGradient(
    colors: <Color>[Color(0xFFEFFBF4), Color(0xFFF8FCFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const Color accent = Color(0xFF10B981);
  static const Color accentDark = Color(0xFF065F46);
}
