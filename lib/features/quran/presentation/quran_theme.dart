import 'package:flutter/material.dart';

class QuranUiTheme {
  static const LinearGradient heroGradient = LinearGradient(
    colors: <Color>[Color(0xFF074736), Color(0xFF0E6A52), Color(0xFF16A073)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient panelGradient = LinearGradient(
    colors: <Color>[Color(0xFF0A3025), Color(0xFF0E4A3A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient softBackground = LinearGradient(
    colors: <Color>[Color(0xFFEFFBF4), Color(0xFFFFF9EE)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const Color accent = Color(0xFFD4A62A);
  static const Color accentDark = Color(0xFF0B5B44);
}
