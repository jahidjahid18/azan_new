import 'package:azan_app/features/theme/theme_style_option.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemeColors {
  static const Color darkGreen = Color(0xFF064E3B);
  static const Color emerald = Color(0xFF10B981);
  static const Color softTeal = Color(0xFF34D399);

  static const Color darkBlue = Color(0xFF0F172A);
  static const Color purple = Color(0xFF4F46E5);
  static const Color indigo = Color(0xFF6366F1);

  static const Color gold = Color(0xFFF59E0B);
}

class AppGradients {
  static const LinearGradient primary = LinearGradient(
    colors: <Color>[
      AppThemeColors.darkGreen,
      AppThemeColors.emerald,
      AppThemeColors.softTeal,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient alternative = LinearGradient(
    colors: <Color>[
      AppThemeColors.darkBlue,
      AppThemeColors.purple,
      AppThemeColors.indigo,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lightBackgroundPrimary = LinearGradient(
    colors: <Color>[Color(0xFFF2FBF7), Color(0xFFEFF8FF), Color(0xFFFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient lightBackgroundAlternative = LinearGradient(
    colors: <Color>[Color(0xFFF3F5FF), Color(0xFFEFF4FF), Color(0xFFFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkBackgroundPrimary = LinearGradient(
    colors: <Color>[Color(0xFF03140F), Color(0xFF083126), Color(0xFF0B3A2F)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkBackgroundAlternative = LinearGradient(
    colors: <Color>[Color(0xFF0B1020), Color(0xFF1A1B43), Color(0xFF26276A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppTheme {
  static ThemeData light(ThemeStyleOption style) {
    if (style == ThemeStyleOption.muslimPro) {
      final scheme =
          ColorScheme.fromSeed(
            seedColor: AppThemeColors.darkBlue,
            brightness: Brightness.light,
          ).copyWith(
            primary: AppThemeColors.darkBlue,
            secondary: AppThemeColors.emerald,
            tertiary: AppThemeColors.gold,
            surface: const Color(0xFFF7FAFC),
          );
      return _baseTheme(
        brightness: Brightness.light,
        colorScheme: scheme,
        textTheme: GoogleFonts.cairoTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFF7FAFC),
        cardColor: Colors.white,
      );
    }

    final colors = _palette(style);
    final scheme =
        ColorScheme.fromSeed(
          seedColor: colors.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: colors.primary,
          secondary: colors.accent,
          tertiary: AppThemeColors.gold,
          surface: const Color(0xFFF8FAFC),
        );
    return _baseTheme(
      brightness: Brightness.light,
      colorScheme: scheme,
      textTheme: GoogleFonts.poppinsTextTheme(),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      cardColor: Colors.white,
    );
  }

  static ThemeData dark(ThemeStyleOption style) {
    if (style == ThemeStyleOption.muslimPro) {
      final scheme =
          ColorScheme.fromSeed(
            seedColor: AppThemeColors.darkBlue,
            brightness: Brightness.dark,
          ).copyWith(
            primary: const Color(0xFF1D2A47),
            secondary: AppThemeColors.softTeal,
            tertiary: AppThemeColors.gold,
          );
      return _baseTheme(
        brightness: Brightness.dark,
        colorScheme: scheme,
        textTheme: GoogleFonts.cairoTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
        scaffoldBackgroundColor: const Color(0xFF070E1A),
        cardColor: const Color(0xFF0F1A31),
      );
    }

    final colors = _palette(style);
    final scheme =
        ColorScheme.fromSeed(
          seedColor: colors.primary,
          brightness: Brightness.dark,
        ).copyWith(
          primary: colors.primary,
          secondary: colors.accent,
          tertiary: AppThemeColors.gold,
        );
    return _baseTheme(
      brightness: Brightness.dark,
      colorScheme: scheme,
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData(brightness: Brightness.dark).textTheme,
      ),
      scaffoldBackgroundColor: const Color(0xFF050A14),
      cardColor: const Color(0xFF0D1422),
    );
  }

  static ThemeData _baseTheme({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required Color scaffoldBackgroundColor,
    required Color cardColor,
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      textTheme: textTheme.copyWith(
        headlineMedium: textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
        ),
        headlineSmall: textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        titleMedium: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(height: 1.35),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: brightness == Brightness.light
            ? colorScheme.primary
            : colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: (textTheme.titleLarge ?? const TextStyle()).copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: brightness == Brightness.light
              ? colorScheme.primary
              : colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.light
            ? Colors.white
            : cardColor.withValues(alpha: 0.94),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.secondary, width: 1.4),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.secondary;
          }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.secondary.withValues(alpha: 0.45);
          }
          return null;
        }),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 72,
        labelTextStyle: WidgetStatePropertyAll(
          (textTheme.bodySmall ?? const TextStyle()).copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        indicatorColor: colorScheme.secondary.withValues(alpha: 0.2),
        backgroundColor: brightness == Brightness.light
            ? Colors.white.withValues(alpha: 0.98)
            : const Color(0xFF0B1220),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static _ThemePalette _palette(ThemeStyleOption style) {
    return switch (style) {
      ThemeStyleOption.muslimPro => const _ThemePalette(
        primary: AppThemeColors.darkBlue,
        accent: AppThemeColors.emerald,
      ),
      ThemeStyleOption.glassBlue => const _ThemePalette(
        primary: AppThemeColors.darkBlue,
        accent: AppThemeColors.softTeal,
      ),
      ThemeStyleOption.emerald => const _ThemePalette(
        primary: AppThemeColors.darkGreen,
        accent: AppThemeColors.emerald,
      ),
      ThemeStyleOption.sunset => const _ThemePalette(
        primary: Color(0xFF2A1A0F),
        accent: Color(0xFFF59E0B),
      ),
      ThemeStyleOption.monochrome => const _ThemePalette(
        primary: Color(0xFF111827),
        accent: Color(0xFF4B5563),
      ),
    };
  }
}

class _ThemePalette {
  const _ThemePalette({required this.primary, required this.accent});

  final Color primary;
  final Color accent;
}
