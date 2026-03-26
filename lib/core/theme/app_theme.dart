import 'package:azan_app/features/theme/theme_style_option.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemeColors {
  static const Color deepGreen = Color(0xFF0A5C45);
  static const Color emerald = Color(0xFF118C68);
  static const Color softTeal = Color(0xFF2DB58A);
  static const Color forestDark = Color(0xFF06261D);
  static const Color forestMid = Color(0xFF0B3C2F);
  static const Color gold = Color(0xFFD4A62A);
  static const Color softGold = Color(0xFFE8C96B);
}

class AppGradients {
  static const LinearGradient primary = LinearGradient(
    colors: <Color>[
      AppThemeColors.deepGreen,
      AppThemeColors.emerald,
      AppThemeColors.softTeal,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient alternative = LinearGradient(
    colors: <Color>[
      AppThemeColors.forestDark,
      AppThemeColors.forestMid,
      AppThemeColors.deepGreen,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lightBackgroundPrimary = LinearGradient(
    colors: <Color>[Color(0xFFF1FBF6), Color(0xFFFAF7ED), Color(0xFFFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient lightBackgroundAlternative = LinearGradient(
    colors: <Color>[Color(0xFFEEF9F4), Color(0xFFFFF9EE), Color(0xFFFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkBackgroundPrimary = LinearGradient(
    colors: <Color>[Color(0xFF041610), Color(0xFF08251D), Color(0xFF0D3529)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkBackgroundAlternative = LinearGradient(
    colors: <Color>[Color(0xFF041510), Color(0xFF0A2A21), Color(0xFF0D3A2D)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppTheme {
  static ThemeData light(ThemeStyleOption style) {
    final colors = _palette(style);
    final scheme =
        ColorScheme.fromSeed(
          seedColor: colors.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: colors.primary,
          secondary: colors.accent,
          tertiary: AppThemeColors.softGold,
          surface: const Color(0xFFFBFCF9),
        );
    return _baseTheme(
      brightness: Brightness.light,
      colorScheme: scheme,
      textTheme: style == ThemeStyleOption.muslimPro
          ? GoogleFonts.cairoTextTheme()
          : GoogleFonts.poppinsTextTheme(),
      scaffoldBackgroundColor: const Color(0xFFFBFCF9),
      cardColor: Colors.white,
    );
  }

  static ThemeData dark(ThemeStyleOption style) {
    final colors = _palette(style);
    final scheme =
        ColorScheme.fromSeed(
          seedColor: colors.primary,
          brightness: Brightness.dark,
        ).copyWith(
          primary: colors.primary,
          secondary: colors.accent,
          tertiary: AppThemeColors.softGold,
        );
    return _baseTheme(
      brightness: Brightness.dark,
      colorScheme: scheme,
      textTheme: style == ThemeStyleOption.muslimPro
          ? GoogleFonts.cairoTextTheme(
              ThemeData(brightness: Brightness.dark).textTheme,
            )
          : GoogleFonts.poppinsTextTheme(
              ThemeData(brightness: Brightness.dark).textTheme,
            ),
      scaffoldBackgroundColor: const Color(0xFF061A14),
      cardColor: const Color(0xFF0D2A21),
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
          fontSize: 23,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.light
            ? Colors.white
            : cardColor.withValues(alpha: 0.94),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colorScheme.secondary, width: 1.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: const StadiumBorder(),
          textStyle: (textTheme.titleSmall ?? const TextStyle()).copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: const StadiumBorder(),
          side: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.55),
            width: 1.2,
          ),
          textStyle: (textTheme.titleSmall ?? const TextStyle()).copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: colorScheme.secondary,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: const StadiumBorder(),
          elevation: 0,
          textStyle: (textTheme.titleSmall ?? const TextStyle()).copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: brightness == Brightness.light
            ? const Color(0xFFFCFEFD)
            : const Color(0xFF0C241D),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: true,
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
        height: 74,
        labelTextStyle: WidgetStatePropertyAll(
          (textTheme.bodySmall ?? const TextStyle()).copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        indicatorShape: const StadiumBorder(),
        indicatorColor: colorScheme.secondary.withValues(alpha: 0.22),
        backgroundColor: Colors.transparent,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: 0.3),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: brightness == Brightness.light
            ? const Color(0xFF173A31)
            : const Color(0xFF173A31),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
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
        primary: AppThemeColors.deepGreen,
        accent: AppThemeColors.gold,
      ),
      ThemeStyleOption.glassBlue => const _ThemePalette(
        primary: Color(0xFF0B5A45),
        accent: Color(0xFFCC9C1F),
      ),
      ThemeStyleOption.emerald => const _ThemePalette(
        primary: Color(0xFF0A664D),
        accent: Color(0xFFD4A62A),
      ),
      ThemeStyleOption.sunset => const _ThemePalette(
        primary: Color(0xFF0C5A43),
        accent: Color(0xFFDAA63D),
      ),
      ThemeStyleOption.monochrome => const _ThemePalette(
        primary: Color(0xFF214238),
        accent: Color(0xFFB69034),
      ),
    };
  }
}

class _ThemePalette {
  const _ThemePalette({required this.primary, required this.accent});

  final Color primary;
  final Color accent;
}
